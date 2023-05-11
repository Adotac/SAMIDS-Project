import asyncio
import os
import cv2
import time
import json
import base64
import numpy as np
#from dotenv import load_dotenv

from fastapi import FastAPI, BackgroundTasks, Path, Query
from pydantic import BaseModel

import requests
from collections import defaultdict
from ImagePredictor import ImagePredictor
from mqtt_client import MQTTClient
from Logger import logger


Remarks = {
        0: "Pending",
        1: "OnTime", 
        2: "Late", 
        3: "Cutting", 
        4: "Absent" 
}

backend_url = "https://localhost:7170"

headers = {
    'Cache-Control': 'no-cache'
    #'Content-Type': 'application/json'
}
headers2 = {
    'Cache-Control': 'no-cache',
    'Content-Type': 'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW'
}



app = FastAPI()

mqtt = MQTTClient()
mqtt.start_loop()

# svm_path = './j-notebooks/svm-rbf_classifier-95-rand-200.pkl'
# svm_path = './models/svm_classifier-400-rand.pkl'
svm_path = './j-notebooks/svm-rbf_classifier.pkl'
# svm_path = './j-notebooks/sgdr_new_92.pkl'
# svm_path = './models/svm_classifier - 93.pkl'


predictor = ImagePredictor(svm_path=svm_path)


# results = defaultdict(str)


class ESP32Data(BaseModel):
    ip_address: str
    rfid_string: str
    device_id: str
    taptime: str


rfidData = {
    "message": "",
    "displayFlag": False,
}


def elapsedTime(start_time):
    # End the timer
    end_time = time.time()

    # Calculate the elapsed time
    elapsed_time = end_time - start_time

    # Print the elapsed time in seconds
    print(f"\nElapsed time: {elapsed_time:.2f} seconds")

    


@app.get("/")
async def root():
    return {"message": "Hello, World!"}


@app.get("/connected")
async def connected():
    return {"message": "Connected to server"}


@app.post("/log/attendance")
async def log_attendance(background_tasks: BackgroundTasks, data: ESP32Data):
    ip_address = data.ip_address
    rfid_string = data.rfid_string
    device_id = data.device_id
    tap_time = data.taptime
    # print(data)

    background_tasks.add_task(process_image, background_tasks, ip_address, rfid_string, device_id, tap_time)

    return {"status": "success", "message": "image processed"}


async def process_image(background_tasks: BackgroundTasks, ip_address: str, rfid_string: str, device_id: str, tap_time: str):
    url = f'http://{ip_address}/800x600.jpg'
    cap = cv2.VideoCapture(url)

    ret, frame = cap.read()
    cap.release()

    if not ret:
        print("Camera failed")
    else:
        label_name = predictor.predict_label(frame)
        print(f'The predicted label of the image is: {label_name}')
 
        student_id = label_name.split("-")[0]

        # Encode the image into JPEG format
        _, buffer = cv2.imencode('.jpg', frame)
        image_data_base64 = base64.b64encode(buffer).decode('utf-8')
        # Convert the buffer to bytes
        #jpg_as_text = buffer.tobytes()


        try:
            response = requests.get(backend_url + f"/api/Student?rfid={rfid_string}", headers=headers, verify=False)
            if response.status_code == 200:
                data = response.json()
                # input_rfid = str(data["data"][0]["rfid"])
                input_student= int(data["data"][0]["studentNo"])

                print(str(input_student) + " | " + str(student_id))

                
                if str(student_id) == str(input_student):
                    print("Add attendance here")
                    background_tasks.add_task(add_attendance, 
                                              background_tasks,
                                              std_id=student_id,
                                              room_id=device_id,
                                              tap_time=tap_time,
                                              rfid=rfid_string,
                                              frame=image_data_base64)
                else:
                    raise ValueError("Rfid data doesn't match")
            else:
                rfidData["message"] = "Server Error:" + str(response.status_code)
                rfidData["displayFlag"] = True
                mqtt.publish(device_id=device_id, message=json.dumps(rfidData))
                print("Error: " + str(response.status_code) + " | " + rfid_string)
                print(response.text)
                logger.error(f"Server Error: {str(response.status_code)}", extra={'user_id': student_id, 'rfid': rfid_string, 'tap_time':tap_time, 'room':device_id})

        except Exception as e:
            rfidData["message"] = "RFID not-match!"
            rfidData["displayFlag"] = True
            mqtt.publish(device_id=device_id, message=json.dumps(rfidData))
            print(f"An error occurred: {str(e)}")
            logger.error(f"An error occured: {str(e)}", extra={'user_id': student_id, 'rfid': rfid_string, 'tap_time':tap_time, 'room':device_id})

    


async def add_attendance(background_tasks: BackgroundTasks, std_id: int, room_id: str, tap_time: str, rfid: str, frame:any):
    # Define your query parameters
    
    try:
        # Define the data you want to send as a dictionary
        body = {
            "studentNo": std_id,
            "room": str("BCL " + room_id),
            "imageString": frame
        }

        # Convert dictionary to JSON string
        json_str = json.dumps(body)
        print(json_str)
        # print(frame)
        print("Entering")
        response = requests.post(backend_url + "/api/Attendance", json=body, headers=headers, verify=False)
        data = response.json()
        print('I am here')
        print(data)
        print("jpeg file now parsed")
        if response.status_code == 200 and data["success"]:
            if int(data['data']) is not ValueError:
                rfidData["message"] = f"Attendance { Remarks.get( data['data']['remarks'] ) }"
            elif "404" in data['data']:
                rfidData["message"] = f"Error 404"
            else:
                rfidData["message"] = f"Shouldn't be here"

            # Convert the bytes to a numpy array
            image_np = np.frombuffer(frame, dtype=np.uint8)
            # Read the image using cv2.imdecode()
            image = cv2.imdecode(image_np, cv2.IMREAD_COLOR)

            # Save the image to a file
            cv2.imwrite(f'/bin/{str(std_id)}.jpg', image)

            rfidData["displayFlag"] = True
            mqtt.publish(device_id=room_id, message=json.dumps(rfidData))
            logger.info(f"{ rfidData['message'] }", extra={'user_id': std_id, 'rfid': rfid, 'tap_time':tap_time, 'room':room_id})

        else:
            if "404" in data['data'] or response.status_code == 404:
                rfidData["message"] = f"Error 404"
            else:
                rfidData["message"] = "Attendance Failed!"
                background_tasks.add_task(save_failattendance, 
                            std_id=std_id,
                            rfid=rfid,
                            frame=frame)
    
            rfidData["displayFlag"] = True
            print(rfidData)
            print("Error: " + str(response.status_code) + " | Can't add attendance")
            print(response.text)
            mqtt.publish(device_id=room_id, message=json.dumps(rfidData))
            logger.info(f"Attendance failed to record, Error Code: {str(response.status_code)}", 
                        extra={'user_id': std_id, 'rfid': rfid, 'tap_time':tap_time, 'room':room_id})


    except Exception as e:
        print(f"An error occurred: {str(e)}")
        logger.error(f"An error occured = {str(e)}", 
            extra={'user_id': std_id, 'rfid': rfid, 'tap_time':tap_time, 'room':room_id})

async def save_failattendance(std_id:int, rfid: str, frame: any):
    #files = {"image": ("image.jpg", frame)}

    body = {
        "imageString": frame,
        "rfid": int(rfid)
    }
    json_str = json.dumps(body)
    print(json_str)
    response = requests.post(backend_url + "/api/Attendance/upload-image", json=body, headers=headers, verify=False)
    data = response.json()
    print("failed attendance image")
    print(data)
    if response.status_code == 200 and data["success"]:
        print("Negative image saved!")

        # Convert the bytes to a numpy array
        image_np = np.frombuffer(frame, dtype=np.uint8)
        # Read the image using cv2.imdecode()
        image = cv2.imdecode(image_np, cv2.IMREAD_COLOR)

        # Save the image to a file
        cv2.imwrite(f'/bin/{str(std_id)}.jpg', image)
    else:   
        print(rfidData)
        print("Error: " + str(response.status_code) + " | Can't add attendance")
        print(response.text)
