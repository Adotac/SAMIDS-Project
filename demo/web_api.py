import requests
import os
from dotenv import load_dotenv

load_dotenv()

class API():
    def __init__(self):
        self.head = { 'X-API-KEY': str(os.getenv('X-API-KEY')) } # Local URL
        self.url = "http://localhost:4000/"   # Deployed URL
        # self.url = "http://localhost:5000/facial-recognition-syste-c82ae/us-central1"  # Local URL

    def get_account(self, id):
        return requests.get(url=self.url + "accounts/get/" + str(id), headers=self.head, auth=None)


    # If ID/Account doesn't exist
    # {
    # 	"success": false,
    # 	"data": "This ID does not exist"
    # }#

    def add_attendance(self, body):
        return requests.post(url=self.url + "attendance/add", json=body, headers=self.head, auth=None)

    def get_all_attendance(self):
        return requests.get(url=self.url + "accounts/get/all", headers=self.head, auth=None)

    def check_if_account_exists(self, id):
        response = self.get_account(str(id))
        # print(response)
        data = response.json()
        print(data)
        # print(type(data))
        # print(data)
        try:
            if data['success']:
                return True
            else:
                return False
        except:
            return False

    def crosscheck_face_name_to_db(self, id, username):
        response = self.get_account(str(id))
        data = response.json()
        print(data['data']['firstName'])
        tempName = data['data']['firstName']+'-'+data['data']['lastName']
        # tempName = '-'.join(tempName).lower()
        tempName = tempName.lower()
        print(tempName)
        try:
            if tempName == username:
                return True
            else:
                return False
        except:
            return False


    def get_all_schedule(self):
        response = requests.get(url=self.url + "attendance/get/all", headers=self.head, auth=None)
        data = response.json()
        return data
