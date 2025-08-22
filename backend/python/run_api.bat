@echo off
REM Convenience launcher for Windows
call .\.venv\Scripts\uvicorn.exe app:app --host 127.0.0.1 --port 8000 --reload
