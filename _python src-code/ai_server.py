import asyncio
import os
import ConvertFromVideotoDataset as CFVD

from dotenv import load_dotenv

from typing import Annotated
from fastapi import FastAPI, WebSocket, BackgroundTasks, Path
from concurrent.futures import ThreadPoolExecutor

import requests

url = "https://localhost:7170"

headers = {
    "Authorization": str(os.getenv('API-TOKEN'))
}

app = FastAPI()
executor = ThreadPoolExecutor(max_workers=5)
face_cropper = CFVD.FaceCropper("dummy_path", "dummy_path")

@app.get("/")
async def root():
    return {"message": "Hello, World!"}

@app.get("/connected")
async def connected():
    return {"message": "Connected to server"}

@app.get("/test")
async def test():
    response = requests.get(url + "/api/Student", headers=headers, verify=False)
    if response.status_code == 200:
        data = response.json()
        print(data)
    else:
        print("Error:", response.status_code)

# ===================================================================#

# Functions for asynchronous workers
def process_cropface_task(websocket: WebSocket, video_path: str, output_dir: str):
    face_cropper.update_paths(video_path, output_dir)
    try:
        loop = asyncio.new_event_loop()
        result = loop.run_until_complete(face_cropper.process_videos())
        loop.run_until_complete(websocket.send_text(f"Processing completed. Result: {result}"))
    except Exception as e:
        loop.run_until_complete(websocket.send_text(f"Error: {str(e)}"))
    finally:
        loop.run_until_complete(asyncio.sleep(2))  # Add a delay before closing the connection
        loop.run_until_complete(websocket.close())
        loop.close()


# ===================================================================#
# Websocket endpoints
@app.websocket("/ws/dataset/preprocess/cropfaces")
async def cropfaces(websocket: WebSocket, background_tasks: BackgroundTasks):
    await websocket.accept()
    await websocket.send_text("Waiting for video_path and output_dir")

    data = await websocket.receive_text()
    video_path, output_dir = data.split(',')

    await websocket.send_text("Starting video processing in the background")
    background_tasks.add_task(process_cropface_task, websocket, video_path, output_dir)





