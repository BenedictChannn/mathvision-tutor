import io
from types import SimpleNamespace

import pytest
from flask.testing import FlaskClient

# Import the Flask app
from backend.api.app import app as flask_app

# Dummy image bytes (simple 1x1 pixel JPEG)
DUMMY_IMG = (
    b"\xff\xd8\xff\xdb\x00C\x00\x08\x06\x06\x07\x06\x05\x08\x07\x07\x07\x09\x09\x08\n\x0c\x14\r\x0c\x0b\x0b\x0c\x19\x12\x13\x0f"  # noqa: E501
    b"\x14\x1d\x1a\x1f\x1e\x1d\x1a\x1c\x1c $.' ,#\x1c\x1c("  # noqa: E501
    b"\x37),01444\x1f'\x1d%\x21\x21\xff\xc0\x00\x11\x08\x00\x01\x00\x01\x03\x01\x11\x00\x02\x11\x01\x03\x11\x01\xff\xc4\x00\x14\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xda\x00\x0c\x03\x01\x00\x02\x11\x03\x11\x00?\x00\xd2\xcf \xff\xd9"
)


@pytest.fixture()
def client() -> FlaskClient:
    flask_app.config.update(TESTING=True)
    from firebase_admin import auth as _auth, firestore as _fs
    _auth.verify_id_token = lambda _: {"uid": "test"}  # type: ignore
    # Stub Firestore client to avoid credential lookup
    _fs.client = lambda *_, **__: SimpleNamespace(
        collection=lambda *_args, **_kwargs: SimpleNamespace(
            add=lambda *_: None,
            document=lambda *_: SimpleNamespace(
                get=lambda transaction=None: SimpleNamespace(exists=True, to_dict=lambda: {"credits_left": 10}),
                update=lambda *_: None,
                set=lambda *_1, **_2: None,
            ),
        )
    )  # type: ignore
    return flask_app.test_client()


def test_happy_path(monkeypatch, client):
    # Monkeypatch services to return acceptable quality, math text, and gemini result
    monkeypatch.setattr(
        "backend.services.quality_service.assess",
        lambda _: SimpleNamespace(is_acceptable=True, blur_score=150, brightness=120),
    )
    monkeypatch.setattr(
        "backend.services.ocr_service.extract_text",
        lambda _: ("2+2?", 0.95),
    )
    monkeypatch.setattr(
        "backend.services.validation_service.is_math_text",
        lambda txt: True,
    )
    from backend.agents import gemini_solve_agent
    from backend.graph import solver_graph
    monkeypatch.setattr(gemini_solve_agent, "solve_with_gemini", lambda _state: {"answer": "4", "steps": ["Add 2 and 2"]})
    monkeypatch.setattr(solver_graph, "solve_with_gemini", lambda _state: {"answer": "4", "steps": ["Add 2 and 2"]})
    monkeypatch.setattr(
        "backend.models.solve_record.save_record",
        lambda uid, data: None,
    )

    rv = client.post(
        "/api/solve",
        data={"image": (io.BytesIO(DUMMY_IMG), "img.jpg")},
        headers={"Authorization": "Bearer test"},
    )
    assert rv.status_code == 200
    json = rv.get_json()
    assert json["answer"] == "4"
    assert json["steps"] == ["Add 2 and 2"]


def test_low_quality(monkeypatch, client):
    monkeypatch.setattr(
        "backend.services.quality_service.assess",
        lambda _: SimpleNamespace(is_acceptable=False, blur_score=10, brightness=50),
    )

    rv = client.post(
        "/api/solve",
        data={"image": (io.BytesIO(DUMMY_IMG), "img.jpg")},
        headers={"Authorization": "Bearer test"},
    )
    assert rv.status_code == 400


def test_invalid_math(monkeypatch, client):
    monkeypatch.setattr(
        "backend.services.quality_service.assess",
        lambda _: SimpleNamespace(is_acceptable=True, blur_score=150, brightness=120),
    )
    monkeypatch.setattr(
        "backend.services.ocr_service.extract_text",
        lambda _: ("Hello world", 0.9),
    )
    monkeypatch.setattr(
        "backend.services.validation_service.is_math_text",
        lambda txt: False,
    )
    from backend.agents import validation_agent
    monkeypatch.setattr(validation_agent, "is_math_text", lambda txt: False)

    rv = client.post(
        "/api/solve",
        data={"image": (io.BytesIO(DUMMY_IMG), "img.jpg")},
        headers={"Authorization": "Bearer test"},
    )
    assert rv.status_code == 400


def test_gemini_failure(monkeypatch, client):
    monkeypatch.setattr(
        "backend.services.quality_service.assess",
        lambda _: SimpleNamespace(is_acceptable=True, blur_score=150, brightness=120),
    )
    monkeypatch.setattr(
        "backend.services.ocr_service.extract_text",
        lambda _: ("2+2?", 0.95),
    )
    monkeypatch.setattr(
        "backend.services.validation_service.is_math_text",
        lambda txt: True,
    )
    from backend.agents import gemini_solve_agent
    from backend.graph import solver_graph
    monkeypatch.setattr(gemini_solve_agent, "solve_with_gemini", lambda _state: (_ for _ in ()).throw(RuntimeError("LLM down")))
    monkeypatch.setattr(solver_graph, "solve_with_gemini", lambda _state: (_ for _ in ()).throw(RuntimeError("LLM down")))

    rv = client.post(
        "/api/solve",
        data={"image": (io.BytesIO(DUMMY_IMG), "img.jpg")},
        headers={"Authorization": "Bearer test"},
    )
    assert rv.status_code == 502
