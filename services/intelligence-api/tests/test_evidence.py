import io
import wave

import numpy as np
from PIL import Image

from enqivra.services.evidence import analyze


def test_image_analysis_returns_quality_signals():
    buffer = io.BytesIO()
    Image.new("RGB", (80, 60), color=(120, 120, 120)).save(buffer, format="PNG")

    result = analyze("IMAGE", buffer.getvalue(), "label.png")

    assert result.analyzer == "enqivra-vision"
    assert any(signal.name == "width" and signal.value == 80 for signal in result.signals)


def test_wav_analysis_returns_audio_features():
    buffer = io.BytesIO()
    samples = (np.sin(np.linspace(0, 20, 8000)) * 1000).astype(np.int16)
    with wave.open(buffer, "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(8000)
        output.writeframes(samples.tobytes())

    result = analyze("AUDIO", buffer.getvalue(), "motor.wav")

    assert result.status == "COMPLETED"
    assert any(signal.name == "duration" and signal.value == 1.0 for signal in result.signals)


def test_telemetry_analysis_summarizes_numeric_columns():
    result = analyze("TELEMETRY", b"time,temp\n0,20\n1,21\n2,40\n", "readings.csv")

    assert result.analyzer == "enqivra-sense"
    assert any(signal.name == "temp.mean" and signal.value == 27.0 for signal in result.signals)
