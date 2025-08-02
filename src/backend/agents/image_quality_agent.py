"""Image quality agent node."""
from __future__ import annotations

from typing import Dict, Any

# Stub using backend.services.quality_service if available
try:
    from backend.services.quality_service import assess  # type: ignore
except ImportError:  # pragma: no cover
    # TODO: remove stub once backend.services.quality_service is always available
    def assess(image_bytes: bytes):  # type: ignore
        class Report:  # simple stub
            is_acceptable = True
            blur_score = 0.0
            brightness = 0.0
        return Report()

def assess_quality(state: Dict[str, Any]) -> Dict[str, Any]:
    img = state["image_bytes"]
    # Import service lazily to pick up monkeypatches in tests
    from backend.services import quality_service as qs  # inline import
    report = qs.assess(img)
    if not report.is_acceptable:
        return {"error": "low_quality", "blur_score": report.blur_score, "brightness": report.brightness}
    return {"quality": "ok"}