"""Firestore SolveRecord model utilities."""
from __future__ import annotations

from datetime import datetime
from typing import Dict, Any

from firebase_admin import firestore  # type: ignore

_db = firestore.client()

COLLECTION = "solve_records"


def save_record(uid: str, data: Dict[str, Any]) -> None:
    """Persist a solve record under /solve_records/{autoId}.

    Args:
        uid: Firebase UID of the user.
        data: Additional fields to store.
    """
    doc = {
        "uid": uid,
        "created_at": firestore.SERVER_TIMESTAMP,
        **data,
    }
    _db.collection(COLLECTION).add(doc)
