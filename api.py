from fastapi import FastAPI
import whisperx
import torch
import requests
from urllib.parse import urlparse
from pathlib import Path
import os
from pydantic import BaseModel

app = FastAPI()

class helper(BaseModel):
    url : str

def transcribe(helper):

        url = helper.url
        device = "cuda"
        r = requests.get(url)
        if r.status_code == 200:
            with open(Path(urlparse(url).path).name, 'wb') as f:
                f.write(r.content)
        else:
            print("Unexpected Status Code when downloading:", r.status_code)

        audio = whisperx.load_audio(Path(urlparse(url).path).name)
        model = whisperx.load_model("small", device, language="en", compute_type='float32')
        result = model.transcribe(audio, batch_size=16)
        os.remove(Path(urlparse(url).path).name)
        return result

@app.get("/audio_validation")
async def read_video(helper: helper):
    resp = transcribe(helper)
    return resp