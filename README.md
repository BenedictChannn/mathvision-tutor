# MathVision Tutor

A Python-based project for mathematics and computer vision tutoring.

## Project Structure

```
mathvision-tutor/
├── src/             # Source code
├── .gitignore       # Git ignore file
└── README.md        # Project documentation
```

## Getting Started

1. Clone the repository
2. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
3. Install dependencies (once requirements.txt is available):
   ```bash
   pip install -r requirements.txt
   ```

## Development

More details about development setup and guidelines will be added as the project evolves.

## Running the LangGraph solver locally

Before running the graph you need a Google Gemini API key.  Set it in your shell:

```bash
# macOS / Linux
export GOOGLE_GEMINI_API_KEY="YOUR-KEY"
# Windows (cmd)
set GOOGLE_GEMINI_API_KEY=YOUR-KEY
```

With the virtual environment active, execute the following one-off script:

```python
# run_graph.py (example)
from backend.graph.graph_factory import build_graph

graph = build_graph(provider="gemini")

with open("sample.jpg", "rb") as img:
    result = graph.run({"image_bytes": img.read()})

print(result)
```

You should see a dictionary similar to:

```text
{'answer': '42', 'steps': ['Step 1', 'Step 2'], 'solve_id': 'abc123'}
```

This demonstrates that the LangGraph pipeline can execute end-to-end locally without the Flask API.


## License

[License information to be added]