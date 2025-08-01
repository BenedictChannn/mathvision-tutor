"""Wrapper around Google Gemini 2.5 Pro (Generative AI) for math problem solving."""
from __future__ import annotations

import os
from typing import List, Optional, Dict

try:
    import google.generativeai as genai  # type: ignore
except ImportError:  # pragma: no cover – handled at runtime
    genai = None  # type: ignore


MODEL_NAME = "gemini-2.5-pro"


def _init_client() -> None:
    if genai is None:
        raise RuntimeError("google-generativeai not installed")
    api_key = os.getenv("GOOGLE_GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("GOOGLE_GEMINI_API_KEY env var missing")
    genai.configure(api_key=api_key)


_prompt_template = (
    "You are a step-by-step math tutor. Given the problem text below, "
    "provide a JSON object with two keys: 'answer' (short) and 'steps' (array of strings).\n"  # noqa: E501
    "Problem: \n{problem}\n"
)


def solve_math(problem_text: str, *, image_bytes: Optional[bytes] = None) -> Dict[str, object]:
    """Call Gemini to get answer + steps JSON. If image_bytes provided, use multimodal input."""
    _init_client()

    prompt = _prompt_template.format(problem=problem_text.strip())

    if image_bytes is not None:
        response = genai.generate_content(  # type: ignore[attr-defined]
            model=MODEL_NAME,
            contents=[
                prompt,
                {
                    "mime_type": "image/jpeg",
                    "data": image_bytes,
                },
            ],
            generation_config={"response_mime_type": "application/json"},
        )
    else:
        response = genai.generate_content(  # type: ignore[attr-defined]
            model=MODEL_NAME,
            contents=[prompt],
            generation_config={"response_mime_type": "application/json"},
        )

    if response.candidates:  # type: ignore[attr-defined]
        import json

        try:
            return json.loads(response.text)  # type: ignore[attr-defined]
        except Exception:  # pragma: no cover
            raise RuntimeError("Gemini returned non-JSON response")
    raise RuntimeError("No candidates from Gemini")
