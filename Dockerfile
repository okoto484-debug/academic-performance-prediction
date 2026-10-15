FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

COPY bundle.part* /tmp/

RUN python -c "import base64,glob; data=''.join(open(p, encoding='utf-8').read() for p in sorted(glob.glob('/tmp/bundle.part*'))); open('/tmp/runtime_bundle.tar.gz','wb').write(base64.b64decode(data))" \
    && tar -xzf /tmp/runtime_bundle.tar.gz -C /app \
    && rm -f /tmp/bundle.part* /tmp/runtime_bundle.tar.gz \
    && pip install --upgrade pip \
    && pip install -r requirements.txt

RUN useradd --create-home --shell /usr/sbin/nologin appuser \
    && chown -R appuser:appuser /app

USER appuser

EXPOSE 10000

CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-10000} --workers 1"]
