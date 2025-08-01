"""Image quality assessment utilities.

We apply two simple heuristics:
1. Blur score via variance of Laplacian – lower variance ⇒ blurrier.
2. Brightness via mean pixel intensity in grayscale – too dark or too bright are rejected.

Thresholds are empirically chosen for MVP and can be tuned later.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Tuple

import cv2
import numpy as np

BLUR_THRESHOLD = 100.0  # Variance-of-Laplacian below this is considered blurry
BRIGHTNESS_RANGE: Tuple[float, float] = (40, 220)  # acceptable mean intensity


@dataclass
class QualityReport:
    blur_score: float
    brightness: float
    is_blurry: bool
    is_dark: bool
    is_bright: bool

    @property
    def is_acceptable(self) -> bool:  # noqa: D401 (property is fine)
        """Return True if image passes all quality gates."""
        return not (self.is_blurry or self.is_dark or self.is_bright)


def assess(image_bytes: bytes) -> QualityReport:
    """Evaluate blur & brightness on JPEG/PNG bytes.

    Returns a QualityReport; caller decides what to do with it.
    """
    # Decode bytes to BGR numpy array
    np_arr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    if img is None:
        raise ValueError("Unable to decode image file")

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Blur score
    laplacian_var = cv2.Laplacian(gray, cv2.CV_64F).var()
    is_blurry = laplacian_var < BLUR_THRESHOLD

    # Brightness
    mean_intensity = float(gray.mean())
    is_dark = mean_intensity < BRIGHTNESS_RANGE[0]
    is_bright = mean_intensity > BRIGHTNESS_RANGE[1]

    return QualityReport(
        blur_score=laplacian_var,
        brightness=mean_intensity,
        is_blurry=is_blurry,
        is_dark=is_dark,
        is_bright=is_bright,
    )
