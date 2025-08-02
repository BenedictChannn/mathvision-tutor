"""OCR agent node."""
from __future__ import annotations
from typing import Dict, Any

try:
    from backend.services.ocr_service import extract_text  # type: ignore
except ImportError:
    # TODO: remove stub once backend.services.ocr_service is always available
    def extract_text(img):  # type: ignore
        return "1+1", 0.99

def perform_ocr(state: Dict[str, Any]) -> Dict[str, Any]:
    text, confidence = extract_text(state["image_bytes"])
    return {"ocr_text": text, "ocr_confidence": confidence}