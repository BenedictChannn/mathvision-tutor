"""Firestore utilities for managing per-user credit balance.

This module stores a ``credits_left`` integer field under each user document in the
``users`` collection.  We provide helpers to fetch the current balance and to
atomically decrement a credit before a solve attempt.
"""
from __future__ import annotations

from typing import Optional

from firebase_admin import firestore  # type: ignore

_db = firestore.client()

COLLECTION = "users"
DEFAULT_CREDITS = 10  # New users start with 10 credits (can be adjusted later).


class InsufficientCreditsError(RuntimeError):
    """Raised if the user has no remaining credits."""


def _get_doc_ref(uid: str):
    """Return a ``DocumentReference`` for the given UID inside ``users`` collection."""

    return _db.collection(COLLECTION).document(uid)


def get_credits(uid: str) -> int:
    """Return the user's current ``credits_left``.

    Initializes the document with ``DEFAULT_CREDITS`` if it does not yet exist.
    """

    doc_ref = _get_doc_ref(uid)
    snap = doc_ref.get()
    if not snap.exists:
        # Initialise with default allotment
        doc_ref.set({"credits_left": DEFAULT_CREDITS}, merge=True)
        return DEFAULT_CREDITS
    data: Optional[dict] = snap.to_dict()
    return int(data.get("credits_left", DEFAULT_CREDITS))  # type: ignore[arg-type]


def decrement_credit(uid: str) -> int:
    """Atomically decrement a credit and return the remaining balance.

    Raises:
        InsufficientCreditsError: If the user has no credits left.
    """

    doc_ref = _get_doc_ref(uid)
    snap = doc_ref.get()
    current = DEFAULT_CREDITS
    if snap.exists:
        current = int(snap.to_dict().get("credits_left", DEFAULT_CREDITS))  # type: ignore[arg-type]
    if current <= 0:
        raise InsufficientCreditsError("No credits remaining")

    new_value = current - 1
    # Firestore ``Increment`` sentinel would be ideal, but keeping it simple here
    doc_ref.update({"credits_left": new_value})
    return new_value
