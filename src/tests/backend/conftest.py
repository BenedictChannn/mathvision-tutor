"""Global test fixtures and stubs for backend tests."""
import sys
import types

# ---------------------------------------------------------------------------
# Stub Firebase Admin so tests run without real credentials or network.
# ---------------------------------------------------------------------------

stub_admin = types.ModuleType("firebase_admin")

class _AuthStub:  # minimal interface for verify_id_token
    @staticmethod
    def verify_id_token(token):
        return {"uid": "test"}

auth = _AuthStub()
credentials = types.ModuleType("credentials")

stub_admin.auth = auth  # type: ignore
stub_admin.credentials = credentials  # type: ignore
stub_admin._apps = [object()]  # marks app as initialised
stub_admin.initialize_app = lambda *a, **k: None

sys.modules["firebase_admin"] = stub_admin
sys.modules["firebase_admin.auth"] = auth  # type: ignore
sys.modules["firebase_admin.credentials"] = credentials  # type: ignore

# Firestore stub
fs_module = types.ModuleType("firebase_admin.firestore")
class _DummyDB:
    def collection(self, *_):
        return self
    def add(self, doc):
        class Ref:
            id = "dummy-id"
        return None, Ref()
    def document(self, *_):
        return self
    def set(self, *_ , **__):
        pass
    def snapshots(self):
        return iter([])
class _DummyFieldValue:
    @staticmethod
    def increment(val):
        return val

fs_module.SERVER_TIMESTAMP = "ts"
fs_module.FieldValue = _DummyFieldValue

fs_module.client = lambda: _DummyDB()

sys.modules["firebase_admin.firestore"] = fs_module

# ---------------------------------------------------------------------------
# Stub Google Vision and GEMINI for tests
# ---------------------------------------------------------------------------
import types
# Vision stub
g_vision = types.ModuleType("google.cloud.vision")
# make attribute directly accessible as in vision.ImageAnnotatorClient
class _DummyAnnotatorTop:
    def __init__(self,*_,**__):
        pass
    def text_detection(self,*_,**__):
        class _R: text_annotations=[{"description":"1+1"}]
        return _R()
g_vision.ImageAnnotatorClient = _DummyAnnotatorTop  # type: ignore
vision_services = types.ModuleType("google.cloud.vision_v1.services.image_annotator")
# Provide Image factory
class _DummyImage:
    def __init__(self, content=None):
        self.content = content
class _DummyAnnotator:  # noqa: D401
    def __init__(self, *_, **__):
        pass
    def text_detection(self, image):  # type: ignore
        class _Resp:
            text_annotations = [{"description": "1+1"}]
        return _Resp()
vision_services.ImageAnnotatorClient = _DummyAnnotator  # type: ignore
vision_services.Image = _DummyImage  # type: ignore

g_vision.Image = _DummyImage  # type: ignore
sys.modules["google.cloud.vision"] = g_vision
sys.modules["google.cloud.vision_v1"] = g_vision
sys.modules["google.cloud.vision_v1.services"] = vision_services
sys.modules["google.cloud.vision_v1.services.image_annotator"] = vision_services

import os
os.environ.setdefault("GOOGLE_GEMINI_API_KEY", "test-key")

# Gemini stub
genai_stub = types.ModuleType("google.generativeai")
class _Resp:
    text = '{"answer": "42", "steps": ["Step 1", "Step 2"]}'
    candidates = [1]

genai_stub.generate_content = lambda *a, **k: _Resp()  # type: ignore

genai_stub.configure = lambda *a, **k: None  # type: ignore
sys.modules["google.generativeai"] = genai_stub

# Stub extract_text to avoid vision dependency entirely
import types as _t
from types import SimpleNamespace as _SN
import importlib
ocr_service = importlib.import_module("backend.services.ocr_service")
setattr(ocr_service, "extract_text", lambda _bytes: ("1+1", 0.95))
