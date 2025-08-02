import sys, types
import pytest

# --- Global stubs for Firebase (imported via conftest) already applied ---

from backend.graph.graph_factory import build_graph


def _patch_quality(monkeypatch, acceptable: bool):
    from types import SimpleNamespace
    from backend.services import quality_service
    monkeypatch.setattr(
        quality_service,
        "assess",
        lambda _: SimpleNamespace(is_acceptable=acceptable, blur_score=100, brightness=120),
    )


def test_solver_graph_success(monkeypatch):
    _patch_quality(monkeypatch, True)
    graph = build_graph(provider="gemini")
    result = graph.run({"image_bytes": b"dummy"})

    assert result["answer"] == "42"
    assert result["steps"] == ["Step 1", "Step 2"]
    assert result["solve_id"] == "dummy-id"


def test_solver_graph_error(monkeypatch):
    _patch_quality(monkeypatch, False)
    graph = build_graph(provider="gemini")
    result = graph.run({"image_bytes": b"dummy"})

    assert result["error"] == "low_quality"