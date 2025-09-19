import json
import ssl
import websockets
import numpy as np
import soundfile as sf
from pydub import AudioSegment
import os
from .config import FUNASR_SERVER, USE_SSL


def convert_to_pcm16(audio_bytes: bytes, filename: str) -> bytes:
    """支持 mp3/wav → 16kHz 单声道 PCM16"""
    ext = os.path.splitext(filename)[-1].lower()
    if ext == ".mp3":
        with open("temp.mp3", "wb") as f:
            f.write(audio_bytes)
        audio = AudioSegment.from_mp3("temp.mp3")
        os.remove("temp.mp3")
        audio = audio.set_frame_rate(16000).set_channels(1).set_sample_width(2)
        samples = np.frombuffer(audio.raw_data, dtype=np.int16)
        return samples.tobytes()
    elif ext == ".wav":
        with open("temp.wav", "wb") as f:
            f.write(audio_bytes)
        data, samplerate = sf.read("temp.wav", dtype="int16")
        os.remove("temp.wav")
        if samplerate != 16000:
            audio = AudioSegment.from_wav("temp.wav")
            audio = audio.set_frame_rate(16000).set_channels(1).set_sample_width(2)
            samples = np.frombuffer(audio.raw_data, dtype=np.int16)
            return samples.tobytes()
        if len(data.shape) > 1 and data.shape[1] > 1:
            data = data[:, 0]
        return data.tobytes()
    else:
        raise ValueError("只支持 mp3 或 wav 文件")


async def asr_request(audio_bytes: bytes, filename: str = "upload.wav") -> str:
    """调用 FunASR 服务"""
    ssl_ctx = None
    if USE_SSL:
        ssl_ctx = ssl.create_default_context()
        ssl_ctx.check_hostname = False
        ssl_ctx.verify_mode = ssl.CERT_NONE

    async with websockets.connect(FUNASR_SERVER, subprotocols=["binary"], ssl=ssl_ctx) as ws:
        start_msg = {
            "mode": "offline",
            "chunk_size": [5, 10, 5],
            "chunk_interval": 10,
            "audio_fs": 16000,
            "wav_name": filename,
            "wav_format": "pcm",
            "is_speaking": True,
            "itn": True
        }
        await ws.send(json.dumps(start_msg))
        await ws.send(audio_bytes)
        await ws.send(json.dumps({"mode": "offline", "is_speaking": False, "wav_name": filename}))

        final_text = ""
        while True:
            try:
                msg = await ws.recv()
                resp = json.loads(msg)
                text = resp.get("text", "")
                if text.strip():
                    final_text = text
                    if resp.get("is_final", False) or resp.get("mode") == "offline":
                        break
            except websockets.ConnectionClosed:
                break
        return final_text
