# SonicCanvas

SonicCanvas is a prompt-to-music web app with a FastAPI backend and a modern React + Vite frontend.

## Highlights

- Local open-source MusicGen generation without a paid API
- Clean React + Vite interface with prompt presets
- Generate, preview, and download WAV files locally
- FastAPI backend with CORS enabled for local app usage
- Demo mode for frontend-only checks without model generation

## Tech Stack

- Backend: FastAPI, Transformers, PyTorch, SciPy, python-dotenv
- Frontend: React, Vite

## Prerequisites

- Python 3.10 or newer
- Node.js 18 or newer
- Recommended RAM: 8 GB or more
- Internet connection for first-time model download

## Quick Start

### 1) Clone and enter project

```powershell
git clone <your-repo-url>
cd MusicAI
```

### 2) One-command setup and run

On Windows, the easiest option is to run the batch file from the project root. It will:

- detect a supported Python version (3.10+)
- create or reuse the local `.venv` inside the project
- copy the example `.env` files if they do not already exist
- install backend dependencies from [requirements.txt](requirements.txt)
- install frontend dependencies in [frontend/package.json](frontend/package.json)
- download the MusicGen model cache when it is missing
- launch the backend and frontend in separate windows

```powershell
.\run.bat
```

### 3) Manual backend setup

```powershell
python -m venv .venv
.venv\Scripts\activate
python -m pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
Copy-Item .env.example .env
```

### 4) Optional model pre-download

This downloads the MusicGen checkpoint into the local Hugging Face cache before the first request. It can reduce the first generation delay substantially, but it is optional.

```powershell
# inside the project venv
python download_model.py
```

This may take several minutes depending on bandwidth and hardware.

### 5) Frontend setup

```powershell
cd frontend
npm install
Copy-Item .env.example .env
cd ..
```

### 6) Manual run

Terminal A (backend):

```powershell
.venv\Scripts\activate
uvicorn app:app --reload --host 127.0.0.1 --port 8000
```

Terminal B (frontend):

```powershell
cd frontend
npm run dev -- --host 127.0.0.1 --port 5173
```

Then open: [http://127.0.0.1:5173](http://127.0.0.1:5173)

## Environment Configuration

### Backend .env

```env
LYRICS_MODEL=distilgpt2
MUSICGEN_MODEL=facebook/musicgen-small
FORCE_DEMO_MODE=false
ALLOWED_ORIGINS=http://127.0.0.1:5173,http://localhost:5173
```

### Frontend frontend/.env

```env
VITE_API_BASE_URL=http://127.0.0.1:8000
```

## API Endpoints

- GET / : API metadata
- GET /health : health status
- POST /generate-music : form data
  - prompt: string
  - duration: integer (1-20)

Response example:

```json
{
  "url": "http://127.0.0.1:8000/generated-audio/<id>.wav",
  "mode": "live",
  "message": "Music generated successfully."
}
```

## Model Details

- **Model**: facebook/musicgen-small (configured with the `MUSICGEN_MODEL` environment variable)
- **Cache**: `%USERPROFILE%\.cache\huggingface\hub\` on Windows
- **Download Size**: roughly 1.5 GB depending on the selected checkpoint
- **Device**: automatically uses CUDA when available, otherwise CPU
- **Pre-download**: optional; use `python download_model.py` to warm the cache before generation

## Notes

- The backend reads configuration from the project root `.env` file.
- The frontend reads `VITE_API_BASE_URL` from `frontend/.env`.
- Generated audio is saved in the local `generated_audio/` directory and is ignored by Git.
- Set `FORCE_DEMO_MODE=true` to use a demo audio response instead of local generation.
- The repo intentionally keeps only example environment files in version control; personal or sensitive values should stay out of the project folder.

## License

MIT
