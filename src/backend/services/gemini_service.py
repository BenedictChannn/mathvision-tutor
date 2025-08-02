"""Gemini 2.5 Pro helpers for solver and follow-up flows."""
from __future__ import annotations

import os
import json
from pathlib import Path
from typing import Dict, Any, Optional

from jinja2 import Template

try:
    import google.generativeai as genai  # type: ignore
except ImportError:  # pragma: no cover
    genai = None  # type: ignore

MODEL_NAME = "gemini-2.5-pro"
PROMPTS_DIR = Path(__file__).parent.parent / "prompts"


def _init_client() -> None:
    if genai is None:
        raise RuntimeError("google-generativeai not installed")
    api_key = os.getenv("GOOGLE_GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("GOOGLE_GEMINI_API_KEY env var missing")
    genai.configure(api_key=api_key)


def _render(template_file: str, context: Dict[str, Any]) -> str:
    """Render a Jinja template with the provided context."""
    template_path = PROMPTS_DIR / template_file
    tpl = Template(template_path.read_text())
    return tpl.render(**context)


# ---------------------------------------------------------------------------
# Main solve
# ---------------------------------------------------------------------------

def solve_math(problem_text: str, *, image_bytes: Optional[bytes] = None) -> Dict[str, Any]:
    """Generate answer + steps for a new problem."""
    _init_client()

    prompt = _render("gemini_solver_prompt.jinja", {"problem_text": problem_text})

    response = genai.generate_content(  # type: ignore[attr-defined]
        model=MODEL_NAME,
        contents=[prompt],
        generation_config={"response_mime_type": "application/json"},
    )

    if not response.candidates:
        raise RuntimeError("No candidates from Gemini")

    try:
        return json.loads(response.text)  # type: ignore[attr-defined]
    except Exception as exc:
        raise RuntimeError("Gemini returned non-JSON response") from exc


# ---------------------------------------------------------------------------
# Follow-up answer
# ---------------------------------------------------------------------------

def answer_follow_up(ctx: Dict[str, Any]) -> Dict[str, Any]:
    """Generate an answer to a follow-up question using prior context."""
    _init_client()

    prompt = _render("gemini_followup_prompt.jinja", ctx)

    response = genai.generate_content(  # type: ignore[attr-defined]
        model=MODEL_NAME,
        contents=[prompt],
        generation_config={"response_mime_type": "application/json"},
    )

    if not response.candidates:
        raise RuntimeError("No candidates from Gemini")

    try:
        return json.loads(response.text)  # type: ignore[attr-defined]
    except Exception as exc:
        raise RuntimeError("Gemini returned non-JSON response") from exc
