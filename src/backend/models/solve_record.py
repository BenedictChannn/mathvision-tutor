"""Firestore SolveRecord model utilities."""
from __future__ import annotations

from datetime import datetime
from typing import Dict, Any

from firebase_admin import firestore  # type: ignore

_db = firestore.client()

COLLECTION = "solve_records"


def save_record(uid: str, data: Dict[str, Any]) -> str:
    """Persist a solve record under /solve_records/{autoId}.

    Returns the created document ID so callers can reference it later.
    """
    doc_ref = _db.collection(COLLECTION).add(
        {
            "uid": uid,
            "created_at": firestore.SERVER_TIMESTAMP,
            **data,
        }
    )[1]
    return doc_ref.id


def add_follow_up(solve_id: str, qa: Dict[str, Any]) -> None:
    """Append a follow-up Q&A under /solve_records/{solve_id}/follow_ups/"""
    _db.collection(COLLECTION).document(solve_id).collection("follow_ups").add(
        {
            "created_at": firestore.SERVER_TIMESTAMP,
            **qa,
        }
    )
