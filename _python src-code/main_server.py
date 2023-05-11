import uvicorn
import os

if __name__ == "__main__":
    os.makedirs("./bin", exist_ok=True)
    uvicorn.run("ai_server:app", host="0.0.0.0", port=1412, reload=True)

