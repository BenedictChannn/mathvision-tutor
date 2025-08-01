"""Flask API entrypoint for MathVision Tutor backend."""

from __future__ import annotations

import os
from functools import wraps
from typing import Callable, TypeVar, ParamSpec

from flask import Flask, jsonify, request
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

import firebase_admin
from firebase_admin import auth, credentials

# ---------------------------------------------------------------------------
# App & extensions
# ---------------------------------------------------------------------------

app = Flask(__name__)

# Rate-limit: 30 requests/minute per IP (MVP default)
app.config["RATELIMIT_HEADERS_ENABLED"] = True
limiter = Limiter(key_func=get_remote_address, app=app, default_limits=["30/minute"])

# Initialise Firebase Admin SDK once. In production you'll load credentials from
# env / secret manager. For local dev, fallback to application-default creds.
if not firebase_admin._apps:  # pylint: disable=protected-access
    cred_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    if cred_path and os.path.exists(cred_path):
        cred = credentials.Certificate(cred_path)
    else:
        cred = credentials.ApplicationDefault()
    firebase_admin.initialize_app(cred)


# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------
RespT = TypeVar("RespT")
P = ParamSpec("P")


def require_auth(func: Callable[P, RespT]) -> Callable[P, RespT]:
    """Decorator that verifies Firebase ID token from Authorization header."""

    @wraps(func)
    def wrapper(*args: P.args, **kwargs: P.kwargs):  # type: ignore[override]
        auth_header = request.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            return jsonify({"error": "missing Bearer token"}), 401
        id_token = auth_header.split(" ", 1)[1]
        try:
            request.user = auth.verify_id_token(id_token)  # type: ignore[attr-defined]
        except Exception as exc:  # FirebaseError subclasses
            return jsonify({"error": "invalid token", "detail": str(exc)}), 401
        return func(*args, **kwargs)

    return wrapper  # type: ignore[return-value]


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------


@app.route("/api/solve", methods=["POST"])
@require_auth
def solve():
    """MVP placeholder endpoint.

    - Rate-limited to 30 req/min via Flask-Limiter
    - Requires valid Firebase ID token (see ``require_auth``)
    - Expects multipart/form-data with ``image`` field
    """
    if "image" not in request.files:
        return jsonify({"error": "image file missing"}), 400

    img_bytes = request.files["image"].read()
    try:
        from backend.services.quality_service import assess  # local import to avoid cv2 overhead if unused

        report = assess(img_bytes)
    except ValueError as exc:
        return jsonify({"error": str(exc)}), 400

    if not report.is_acceptable:
        return (
            jsonify(
                {
                    "error": "low_quality",
                    "blur_score": report.blur_score,
                    "brightness": report.brightness,
                }
            ),
            422,
        )

    # OCR step
    from backend.services.ocr_service import extract_text  # inline import to keep cold-start fast

    text, confidence = extract_text(img_bytes)

    # Validation step
    from backend.services.validation_service import is_math_text

    if not is_math_text(text):
        return jsonify({"error": "invalid_input", "detail": "Not recognised as math"}), 400

    # Call Gemini solver
    from backend.services.gemini_service import solve_math

    import time
    start_ts = time.perf_counter()
    try:
        result = solve_math(text, image_bytes=img_bytes)
    except Exception as exc:  # pragma: no cover
        return jsonify({"error": "gemini_failure", "detail": str(exc)}), 502
    latency_ms = (time.perf_counter() - start_ts) * 1000

    # Persist record
    from backend.models.solve_record import save_record

    save_record(
        uid=request.user.get("uid"),  # type: ignore[attr-defined]
        data={
            "latency_ms": latency_ms,
            "ocr_confidence": confidence,
            # TODO: compute real token usage & cost once API exposes it
            "cost_usd": 0.0,
        },
    )

    payload = {
        "status": "ok",
        "uid": request.user.get("uid"),  # type: ignore[attr-defined]
        "ocr_text": text,
        "ocr_confidence": confidence,
        "answer": result.get("answer"),
        "steps": result.get("steps"),
        "latency_ms": latency_ms,
    }
    resp = jsonify(payload)

    # Placeholder credits logic – replace with real quota in task 3.x
    resp.headers["X-Credits-Remaining"] = request.user.get("credits_left", "N/A")  # type: ignore[attr-defined]
    return resp, 200


# ---------------------------------------------------------------------------
# Local dev entrypoint
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
