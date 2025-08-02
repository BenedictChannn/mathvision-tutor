"""Flask API entrypoint for MathVision Tutor backend."""

from __future__ import annotations

import os
import json
import logging
from functools import wraps
from typing import Callable, TypeVar, ParamSpec

from flask import Flask, jsonify, request
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

import firebase_admin
from firebase_admin import auth, credentials

# ---------------------------------------------------------------------------
# App & extensions
# ---------------------------------------------------------------------------

app = Flask(__name__)

# Structured logger. Cloud Run will emit these JSON lines to Cloud Logging.
logger = logging.getLogger("solver")
if not logger.handlers:
    handler = logging.StreamHandler()
    logger.addHandler(handler)
logger.setLevel(logging.INFO)


# Rate-limit: 30 requests/minute per IP (MVP default)
app.config["RATELIMIT_HEADERS_ENABLED"] = True
limiter = Limiter(key_func=get_remote_address, app=app, default_limits=["30/minute"])

# Initialise Firebase Admin SDK once. In production you'll load credentials from
# env / secret manager. For local dev, fallback to application-default creds.
if not firebase_admin._apps:  # pylint: disable=protected-access
    cred_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    if cred_path and os.path.exists(cred_path):
        cred = credentials.Certificate(cred_path)
    else:
        cred = credentials.ApplicationDefault()
    firebase_admin.initialize_app(cred)


# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------
RespT = TypeVar("RespT")
P = ParamSpec("P")


def require_auth(func: Callable[P, RespT]) -> Callable[P, RespT]:
    """Decorator that verifies Firebase ID token from Authorization header."""

    @wraps(func)
    def wrapper(*args: P.args, **kwargs: P.kwargs):  # type: ignore[override]
        auth_header = request.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            return jsonify({"error": "missing Bearer token"}), 401
        id_token = auth_header.split(" ", 1)[1]
        try:
            request.user = auth.verify_id_token(id_token)  # type: ignore[attr-defined]
        except Exception as exc:  # FirebaseError subclasses
            return jsonify({"error": "invalid token", "detail": str(exc)}), 401
        return func(*args, **kwargs)

    return wrapper  # type: ignore[return-value]


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------


@app.route("/api/solve", methods=["POST"])
@require_auth
def solve():
    """MVP placeholder endpoint.

    - Rate-limited to 30 req/min via Flask-Limiter
    - Requires valid Firebase ID token (see ``require_auth``)
    - Expects multipart/form-data with ``image`` field
    """
    if "image" not in request.files:
        return jsonify({"error": "image file missing"}), 400

    img_bytes = request.files["image"].read()

    # -------------------------------------------------------------------
    # Credit check (before expensive model call)
    # -------------------------------------------------------------------
    from backend.models.user_credits import decrement_credit, InsufficientCreditsError
    uid = request.user.get("uid")  # type: ignore[attr-defined]
    try:
        credits_remaining = decrement_credit(uid)
    except InsufficientCreditsError:
        return jsonify({"error": "no_credits", "detail": "Please top-up to continue."}), 402

    # -------------------------------------------------------------------
    # Run LangGraph pipeline
    # -------------------------------------------------------------------
    from backend.graph.graph_factory import build_graph
    import time

    graph = build_graph(provider="gemini")
    start_ts = time.perf_counter()
    try:
        result = graph.run({"image_bytes": img_bytes})
    except Exception as exc:  # pragma: no cover
        return jsonify({"error": "graph_failure", "detail": str(exc)}), 502
    latency_ms = (time.perf_counter() - start_ts) * 1000

    if "error" in result:
        # Remove raw bytes if present to make response JSON-safe
        result.pop("image_bytes", None)
        return jsonify(result), 400

    # Persist record remains handled inside graph's persist agent, but we return solve_id if present

    payload = {
        "status": "ok",
        "uid": uid,
        "answer": result.get("answer"),
        "steps": result.get("steps"),
        "latency_ms": latency_ms,
        "solve_id": result.get("solve_id"),
        "ocr_confidence": result.get("ocr_confidence"),
    }
    resp = jsonify(payload)

    # Credits header
    resp.headers["X-Credits-Remaining"] = str(credits_remaining)


    # Structured log for BigQuery sink
    logger.info(
        json.dumps({
            "uid": uid,
            "route": "solve",
            "latency_ms": latency_ms,
            "cost_usd": 0.0,
            "tokens": None,
        }),
        extra={"labels": {"app": "mathvision-solver", "route": "solve"}},
    )
    return resp, 200




@app.route("/api/follow_up", methods=["POST"])
@require_auth
def follow_up():
    """Handle a follow-up question for an existing solve record.

    Expects JSON body with:
      - solve_id: Firestore ID of the parent solve record
      - question: User follow-up question text
    """
    payload = request.get_json(silent=True) or {}
    solve_id = payload.get("solve_id")
    question = payload.get("question", "").strip()

    if not solve_id or not question:
        return jsonify({"error": "missing_fields"}), 400

    # Call Gemini (reuse solve_math for simplicity; in production you'd craft a
    # prompt that includes original context).
    from backend.services.gemini_service import solve_math

    try:
        from backend.services.gemini_service import answer_follow_up
        result = answer_follow_up({"follow_up": question})
    except Exception as exc:  # pragma: no cover
        return jsonify({"error": "gemini_failure", "detail": str(exc)}), 502

    # Persist follow-up under sub-collection.
    from backend.models.solve_record import add_follow_up

    add_follow_up(
        solve_id,
        {
            "uid": request.user.get("uid"),  # type: ignore[attr-defined]
            "question": question,
            "answer": result.get("answer"),
        },
    )

    # Structured log
    logger.info(
        json.dumps({
            "uid": request.user.get("uid"),
            "route": "follow_up",
            "solve_id": solve_id,
        }),
        extra={"labels": {"app": "mathvision-solver", "route": "follow_up"}},
    )
    return jsonify({
        "status": "ok",
        "answer": result.get("answer"),
    }), 200

# ---------------------------------------------------------------------------
# Local dev entrypoint
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
