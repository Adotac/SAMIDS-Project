import os
from dotenv import load_dotenv

from fastapi import FastAPI
import requests

url = "https://localhost:7170"

headers = {
    "Authorization": str(os.getenv('API-TOKEN'))
}

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello, World!"}

@app.get("/test")
async def test():
    response = requests.get(url + "/api/Student", headers=headers, verify=False)
    if response.status_code == 200:
        data = response.json()
        print(data)
    else:
        print("Error:", response.status_code)


