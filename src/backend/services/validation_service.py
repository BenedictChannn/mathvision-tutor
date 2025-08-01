"""Simple heuristics to decide if OCR text looks like a math problem."""
from __future__ import annotations

import re

# Pattern that matches at least one math-related symbol or digit.
_MATH_REGEX = re.compile(r"[0-9]|[+\-*/^=]|\\sqrt|\\frac|\\int|\\sum|\\lim|\\theta|π|\(|\)")


def is_math_text(text: str) -> bool:
    """Return True if the text appears to contain mathematical content."""
    return bool(_MATH_REGEX.search(text))
