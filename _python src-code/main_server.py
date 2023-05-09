import uvicorn

if __name__ == "__main__":
    uvicorn.run("ai_server:app", host="0.0.0.0", port=1412, reload=True)

