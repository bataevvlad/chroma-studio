#!/bin/sh
# Starts ComfyUI on http://127.0.0.1:8188 (localhost only).
# The two memory flags cut swap during Wan video renders by about half on a 64 GB Mac.
cd "$(dirname "$0")/ComfyUI" || exit 1
PYTORCH_ENABLE_MPS_FALLBACK=1 exec .venv/bin/python main.py \
    --listen 127.0.0.1 --port "${PORT:-8188}" \
    --extra-model-paths-config ../extra_model_paths.yaml \
    --reserve-vram 24 --disable-smart-memory
