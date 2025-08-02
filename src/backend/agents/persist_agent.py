"""Persist agent node."""
from __future__ import annotations
from typing import Dict, Any

try:
    from backend.models.solve_record import save_record  # type: ignore
except ImportError:
    # TODO: remove stub once backend.models.solve_record is always available
    def save_record(uid, data):  # type: ignore
        return "dummy-id"

def persist_result(state: Dict[str, Any]) -> Dict[str, Any]:
    """Persist successful results or propagate errors without modification."""
    if "error" in state:
        # Skip persistence for failed solves.
        return state

    # In real flow we'd get uid from auth context; here we use a stub.
    solve_id = save_record("anon", {"answer": state.get("answer")})
    # Preserve the rest of the state while injecting the generated ID.
    return {**state, "solve_id": solve_id}