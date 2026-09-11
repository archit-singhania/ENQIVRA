import csv
import io
import re
import shutil
import tempfile
import wave
from pathlib import Path

import cv2
import numpy as np
import pytesseract
from PIL import Image, ImageStat

from enqivra.schemas.evidence import AnalysisResult, Signal

MAX_BYTES = 20 * 1024 * 1024


def analyze(evidence_type: str, content: bytes, filename: str) -> AnalysisResult:
    if not content:
        raise ValueError("Evidence file is empty")
    if len(content) > MAX_BYTES:
        raise ValueError("Evidence exceeds the 20 MB analysis limit")
    kind = evidence_type.upper()
    if kind == "IMAGE":
        return _image(content)
    if kind == "AUDIO":
        return _audio(content)
    if kind == "VIDEO":
        return _video(content, Path(filename).suffix)
    if kind == "TELEMETRY":
        return _telemetry(content)
    raise ValueError("Supported analysis types are IMAGE, AUDIO, VIDEO, and TELEMETRY")


def _image(content: bytes) -> AnalysisResult:
    image = Image.open(io.BytesIO(content)).convert("RGB")
    stat = ImageStat.Stat(image)
    grayscale = np.asarray(image.convert("L"))
    focus = float(cv2.Laplacian(grayscale, cv2.CV_64F).var())
    brightness = float(sum(stat.mean) / 3)
    observations = []
    if brightness < 45:
        observations.append("Image is very dark; capture again with more light.")
    if focus < 45:
        observations.append("Image appears blurred; steady the camera and capture again.")
    text = None
    limitations = []
    if shutil.which("tesseract"):
        text = pytesseract.image_to_string(image).strip() or None
    else:
        limitations.append(
            "Local Tesseract OCR is not installed; visual quality signals are available."
        )
    candidates = _equipment_candidates(text or "")
    return AnalysisResult(
        analyzer="enqivra-vision",
        evidence_type="IMAGE",
        status="COMPLETED" if text is not None else "PARTIAL",
        signals=[
            Signal(name="width", value=image.width, unit="px"),
            Signal(name="height", value=image.height, unit="px"),
            Signal(name="brightness", value=round(brightness, 2), unit="0-255"),
            Signal(name="focus_score", value=round(focus, 2)),
        ],
        observations=observations,
        extracted_text=text,
        equipment_candidates=candidates,
        limitations=limitations,
    )


def _audio(content: bytes) -> AnalysisResult:
    try:
        with wave.open(io.BytesIO(content), "rb") as audio:
            frames = audio.readframes(audio.getnframes())
            width = audio.getsampwidth()
            dtype = {1: np.uint8, 2: np.int16, 4: np.int32}.get(width)
            if dtype is None:
                raise ValueError("Unsupported WAV sample width")
            samples = np.frombuffer(frames, dtype=dtype).astype(np.float64)
            if audio.getnchannels() > 1:
                samples = samples.reshape(-1, audio.getnchannels()).mean(axis=1)
            rms = float(np.sqrt(np.mean(np.square(samples)))) if samples.size else 0.0
            duration = audio.getnframes() / audio.getframerate()
            return AnalysisResult(
                analyzer="enqivra-echo",
                evidence_type="AUDIO",
                status="COMPLETED",
                signals=[
                    Signal(name="duration", value=round(duration, 3), unit="s"),
                    Signal(name="sample_rate", value=audio.getframerate(), unit="Hz"),
                    Signal(name="channels", value=audio.getnchannels()),
                    Signal(name="rms_energy", value=round(rms, 3)),
                ],
                observations=["Audio features are descriptive and are not a fault diagnosis."],
            )
    except wave.Error as exc:
        return AnalysisResult(
            analyzer="enqivra-echo",
            evidence_type="AUDIO",
            status="UNSUPPORTED",
            limitations=[f"Phase 3 local audio analysis currently requires PCM WAV: {exc}"],
        )


def _video(content: bytes, suffix: str) -> AnalysisResult:
    with tempfile.NamedTemporaryFile(suffix=suffix or ".mp4") as temporary:
        temporary.write(content)
        temporary.flush()
        capture = cv2.VideoCapture(temporary.name)
        if not capture.isOpened():
            return AnalysisResult(
                analyzer="enqivra-vision",
                evidence_type="VIDEO",
                status="UNSUPPORTED",
                limitations=["Video codec could not be decoded locally."],
            )
        frames = int(capture.get(cv2.CAP_PROP_FRAME_COUNT))
        fps = float(capture.get(cv2.CAP_PROP_FPS))
        width = int(capture.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
        duration = frames / fps if fps > 0 else 0
        capture.release()
    return AnalysisResult(
        analyzer="enqivra-vision",
        evidence_type="VIDEO",
        status="COMPLETED",
        signals=[
            Signal(name="duration", value=round(duration, 3), unit="s"),
            Signal(name="fps", value=round(fps, 3)),
            Signal(name="frames", value=frames),
            Signal(name="width", value=width, unit="px"),
            Signal(name="height", value=height, unit="px"),
        ],
        observations=[
            "Video motion classification is deferred until validated domain models exist."
        ],
    )


def _telemetry(content: bytes) -> AnalysisResult:
    text = content.decode("utf-8-sig")
    rows = list(csv.DictReader(io.StringIO(text)))
    if not rows:
        raise ValueError("Telemetry CSV must contain a header and at least one row")
    signals = [Signal(name="row_count", value=len(rows))]
    observations = []
    for column in rows[0]:
        numeric = []
        for row in rows:
            try:
                numeric.append(float(row[column]))
            except (TypeError, ValueError):
                pass
        if len(numeric) >= 2:
            values = np.asarray(numeric)
            signals.extend(
                [
                    Signal(name=f"{column}.min", value=round(float(values.min()), 4)),
                    Signal(name=f"{column}.max", value=round(float(values.max()), 4)),
                    Signal(name=f"{column}.mean", value=round(float(values.mean()), 4)),
                    Signal(name=f"{column}.stddev", value=round(float(values.std()), 4)),
                ]
            )
            if values.std() > 0 and abs(values[-1] - values.mean()) > 2 * values.std():
                observations.append(
                    f"Latest {column} value is more than two standard deviations from its mean."
                )
    return AnalysisResult(
        analyzer="enqivra-sense",
        evidence_type="TELEMETRY",
        status="COMPLETED",
        signals=signals,
        observations=observations,
    )


def _equipment_candidates(text: str) -> list[str]:
    candidates = []
    upper = text.upper()
    for manufacturer in ("SAMSUNG", "LG", "DAIKIN", "VOLTAS", "TATA", "HONDA", "HYUNDAI"):
        if re.search(rf"\b{manufacturer}\b", upper):
            candidates.append(f"Manufacturer: {manufacturer.title()}")
    for match in re.finditer(
        r"(?:MODEL|MOD(?:EL)?\.?\s*NO\.?)\s*[:#-]?\s*([A-Z0-9][A-Z0-9._/-]{2,})", upper
    ):
        candidates.append(f"Model: {match.group(1)}")
    return candidates
