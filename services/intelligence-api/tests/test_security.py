import base64
import hashlib
import hmac
import json
import time

from enqivra.core.middleware import _validate_token


def _encoded(value: dict) -> str:
    return base64.urlsafe_b64encode(json.dumps(value).encode()).rstrip(b"=").decode()


def test_shared_core_token_validation():
    secret = "a-production-grade-secret-with-32-characters"
    header = _encoded({"alg": "HS256", "typ": "JWT"})
    payload = _encoded({"sub": "user-1", "exp": int(time.time()) + 60})
    signature = (
        base64.urlsafe_b64encode(
            hmac.new(secret.encode(), f"{header}.{payload}".encode(), hashlib.sha256).digest()
        )
        .rstrip(b"=")
        .decode()
    )
    assert _validate_token(f"Bearer {header}.{payload}.{signature}", secret) == "user-1"
    assert _validate_token(f"Bearer {header}.{payload}.invalid", secret) is None


def test_expired_token_is_rejected():
    secret = "a-production-grade-secret-with-32-characters"
    header = _encoded({"alg": "HS256"})
    payload = _encoded({"sub": "user-1", "exp": 1})
    signature = (
        base64.urlsafe_b64encode(
            hmac.new(secret.encode(), f"{header}.{payload}".encode(), hashlib.sha256).digest()
        )
        .rstrip(b"=")
        .decode()
    )
    assert _validate_token(f"Bearer {header}.{payload}.{signature}", secret) is None
