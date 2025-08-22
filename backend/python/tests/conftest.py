import sys
from pathlib import Path

# Ensure backend/python is on sys.path so `from app import app` works in tests
ROOT = Path(__file__).resolve().parents[1]  # .../backend/python
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))
