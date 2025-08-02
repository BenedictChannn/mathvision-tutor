"""Validation agent node."""
from __future__ import annotations
from typing import Dict, Any

try:
    from backend.services.validation_service import is_math_text  # type: ignore
except ImportError:
    # TODO: remove stub once backend.services.validation_service is always available
    def is_math_text(txt):  # type: ignore
        return True

def validate_text(state: Dict[str, Any]) -> Dict[str, Any]:
    if not is_math_text(state.get("ocr_text", "")):
        return {"error": "invalid_input"}
    return {"validated": True}