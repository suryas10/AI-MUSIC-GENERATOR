#!/usr/bin/env python3
"""
Download and cache the MusicGen model locally before running the app.
This reduces the first API request time from 5-15 minutes to seconds.

Usage:
    python download_model.py

The model will be cached in ~/.cache/huggingface/hub/
"""

import os
import sys
import torch
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Get model ID from env or use default
MODEL_ID = os.getenv("MUSICGEN_MODEL", "facebook/musicgen-small")

print(f"🎵 MusicGen Model Downloader")
print(f"{'=' * 50}")
print(f"Model: {MODEL_ID}")
print(f"Cache Location: ~/.cache/huggingface/hub/")
print(f"{'=' * 50}\n")

# Detect device
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Device: {device.upper()}")
if device == "cuda":
    print(f"GPU: {torch.cuda.get_device_name(0)}")
print()

print("Downloading model components...")
print(f"This may take 10-20 minutes on first run (depending on internet speed).\n")

try:
    from transformers import AutoProcessor, MusicgenForConditionalGeneration

    print(f"[1/2] Downloading AutoProcessor from {MODEL_ID}...")
    processor = AutoProcessor.from_pretrained(MODEL_ID)
    print(f"✅ AutoProcessor downloaded and cached\n")

    print(f"[2/2] Downloading MusicGen model from {MODEL_ID}...")
    model = MusicgenForConditionalGeneration.from_pretrained(MODEL_ID)
    print(f"✅ MusicGen model downloaded and cached\n")

    # Move to device (doesn't require model weights to be re-downloaded)
    model = model.to(device)
    print(f"✅ Model loaded on {device.upper()}\n")

    print(f"{'=' * 50}")
    print(f"✅ SUCCESS: Model is ready!")
    print(f"{'=' * 50}")
    print(f"\nYou can now run the app with:")
    print(f"  python -m uvicorn app:app --reload")
    print(f"\nThe first API request will be instant! 🚀\n")

except Exception as e:
    print(f"❌ ERROR: Failed to download model")
    print(f"Error details: {e}\n")
    sys.exit(1)
