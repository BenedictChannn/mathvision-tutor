"""LangGraph solver chain definition.

This module wires together the individual agent/step nodes to achieve the
end-to-end solve flow:

• Image quality check ➜ OCR ➜ validation ➜ Gemini solve ➜ persist ➜ return.

The actual node implementations live in `backend.agents.*`.  For now we
construct a simple linear DAG; later tasks may refactor into conditional
branches.
"""
from __future__ import annotations

from typing import Dict, Any

try:
    from langgraph.graph import DAG, Node  # type: ignore
except ImportError:  # pragma: no cover – library not installed in all envs
    # Fallback stubs so static analysis passes.
    class Node:  # pylint: disable=too-few-public-methods
        def __init__(self, func):
            self.func = func

    class DAG:  # pylint: disable=too-few-public-methods
        def __init__(self):
            self.nodes = []

        def add(self, node: Node):  # type: ignore
            self.nodes.append(node)
            return self

        def run(self, input_: Dict[str, Any]):  # type: ignore
            state = input_.copy()
            for node in self.nodes:
                state.update(node.func(state))
            return state

# ---------------------------------------------------------------------------
# Import agent node functions
# ---------------------------------------------------------------------------
from backend.agents.image_quality_agent import assess_quality  # noqa: E402
from backend.agents.ocr_agent import perform_ocr  # noqa: E402
from backend.agents.validation_agent import validate_text  # noqa: E402
from backend.agents.gemini_solve_agent import solve_with_gemini  # noqa: E402
from backend.agents.persist_agent import persist_result  # noqa: E402

# ---------------------------------------------------------------------------
# Graph factory
# ---------------------------------------------------------------------------

def build_solver_graph() -> DAG:  # type: ignore
    """Constructs and returns the LangGraph DAG for the solver pipeline."""

    graph = DAG()

    # Wrap the pure functions into Node instances so LangGraph (or our stub)
    # can process them.
    graph.add(Node(assess_quality))
    graph.add(Node(perform_ocr))
    graph.add(Node(validate_text))
    graph.add(Node(solve_with_gemini))
    graph.add(Node(persist_result))

    return graph


def run(input_bytes: bytes) -> Dict[str, Any]:
    """Convenience wrapper: runs the graph and returns final state."""
    graph = build_solver_graph()
    return graph.run({"image_bytes": input_bytes})
