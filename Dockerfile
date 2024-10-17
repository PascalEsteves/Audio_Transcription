FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-runtime AS runtime

RUN apt-get update \
    && apt update \
    && apt-get install -y git libsndfile1 sox ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# USE LANGUAGES ARG: docker build -f Dockerfile.whisperX  -t try-whisper-x:latest . --build-arg LANGUAGES=es,zh
ARG LANGUAGES
ENV LANGUAGES $LANGUAGES

RUN python -c "import whisperx;[whisperx.load_align_model(language_code=language, device='cpu') for language in '${LANGUAGES}'.split(',')]"

RUN mkdir /app

#COPY ./aligner.py /app/
COPY . /app
WORKDIR /app
RUN python -m pip install -r requirements.txt

CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "1414"]
