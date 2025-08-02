"""Graph Factory
----------------
Provides helpers to construct LangGraph solver graphs with alternate nodes
based on provider choice (e.g., Gemini, OpenAI, etc.).

For now we support:
    • "gemini"   – default chain using Gemini 2.5 Pro (see solver_graph.py).
    • "vision"   – multimodal chain that skips OCR and feeds the image directly
                    to Gemini Vision (stubbed until task 6.4).

Usage:
    from backend.graph.graph_factory import build_graph
    graph = build_graph(provider="gemini")
    result = graph.run({"image_bytes": img})
"""
from __future__ import annotations

from typing import Literal

from backend.graph.solver_graph import build_solver_graph

Provider = Literal["gemini", "vision"]

def build_graph(provider: Provider = "gemini"):
    if provider == "gemini":
        return build_solver_graph()

    if provider == "vision":
        # Lazy import to avoid dependency issues until implemented.
        try:
            from backend.graph.vision_solver_graph import build_vision_graph  # type: ignore
        except ImportError:
            raise NotImplementedError("Vision provider not yet implemented") from None
        return build_vision_graph()

    raise ValueError(f"Unknown provider: {provider}")
