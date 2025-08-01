"""Google Vision OCR wrapper for MathVision Tutor."""
from __future__ import annotations

import io
from typing import Tuple

from google.cloud import vision


def extract_text(image_bytes: bytes) -> Tuple[str, float]:
    """Returns extracted text/LaTeX and average confidence.

    Args:
        image_bytes: Raw image bytes (JPEG/PNG).

    Returns:
        tuple(text, avg_confidence)
    """
    client = vision.ImageAnnotatorClient()
    image = vision.Image(content=image_bytes)
    response = client.document_text_detection(image=image)

    if response.error.message:
        raise RuntimeError(f"Vision API error: {response.error.message}")

    text_annotations = response.text_annotations
    if not text_annotations:
        return "", 0.0

    full_text = text_annotations[0].description  # entire text
    # Compute average confidence across pages / blocks
    confidences = []
    for page in response.full_text_annotation.pages:
        for block in page.blocks:
            confidences.append(block.confidence)
    avg_conf = sum(confidences) / len(confidences) if confidences else 0.0
    return full_text, avg_conf
