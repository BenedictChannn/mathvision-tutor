"""Gemini solve agent node."""
from __future__ import annotations
from typing import Dict, Any

try:
    from backend.services.gemini_service import solve_math  # type: ignore
except ImportError:
    # TODO: remove stub once backend.services.gemini_service is always available
    def solve_math(text, image_bytes=None):  # type: ignore
        return {"answer": "42", "steps": ["Step 1", "Step 2"]}

def solve_with_gemini(state: Dict[str, Any]) -> Dict[str, Any]:
    """Invoke Gemini unless an error already exists in the pipeline state."""
    if "error" in state:
        # Forward existing error without invoking the LLM.
        return state

    result = solve_math(state["ocr_text"])
    return {"answer": result.get("answer"), "steps": result.get("steps")}