####################################################################
# Script to generete FortiCloud IAM user from JSON file
#
# jvigueras@fortinet.com
####################################################################
import json
import requests
from urllib.parse import unquote

#------------------------------------------------------------------------------
# VARIABLES
#------------------------------------------------------------------------------
# External JSON file containing values for users, example: {"user1": {"username": "user1","email": "user1@example.com","password": "Fortinet01-"}}
JSON_FILE = "users.json"
# FortiCloud API endpoints
API_CREATE_USER_URL = "https://support.fortinet.com/app/iam/api/users/cre"
RESET_PWD_URL = "https://support.fortinet.com/app/iam/api/nonesec/cred/resetPwd"
# FortiCloud IAM variables to allocate created users
GROUPID = 173333
NODEID = 1143333
PERMPROFILEID = 13333
DESCRIPTION = "HoL user"
PHONE = "+34 666666666"
# Authorization variables (Caputure from Chrome DevTools)
AUTHORIZATION = "xxxxx"
# Password for users
#PASSWORD = "Fortinet1!"
#------------------------------------------------------------------------------

# Function to extract key value from link
def extract_key(link):
    return link.split("key=")[1]

# Function to decode URL-encoded characters
def decode_key(key):
    return unquote(key)

# Array of headers
headers = {
    "Content-Type": "application/json",
    "Authorization": AUTHORIZATION,
    #"Cookie": COOKIES,
    "Origin": "https://support.fortinet.com",
    "Referer": "https://support.fortinet.com/iam/"
}

# Read JSON data from the file
with open(JSON_FILE) as f:
    data = json.load(f)

# Iterate over each user data
for user_data in data.values():
    # Payload for create user
    create_user_payload = {
        "userType": "IAMUser",
        "iAMId": user_data["username"],
        "username": user_data["username"],
        "email": user_data["email"],
        "phone": PHONE,
        "description": DESCRIPTION,
        "groupId": GROUPID,
        "nodeId": NODEID,
        "permProfileId": PERMPROFILEID,
        "isForOU": "false",
        "subUserId": 0
    }
    # Make the POST request
    response = requests.post(API_CREATE_USER_URL, headers=headers, json=create_user_payload)

    # Extract key value from response if needed
    if response.status_code == 200:
        response_data = response.json()
        key = extract_key(response_data["result"]["userCredential"]["link"])
        decoded_key = decode_key(key)
        print("Create user: ", user_data["username"])
    else:
        print("Failed to create user:", response.text)
    
    # Payload for reset password
    reset_pwd_payload = {
        "password": user_data["password"],
        "token": decoded_key,
    }
    # Make the POST request to reset password
    response = requests.post(RESET_PWD_URL, headers=headers, json=reset_pwd_payload)

    # Extract key value from response if needed
    if response.status_code == 200:
        response_data = response.json()
        print("Set password for user: ", user_data["username"])
    else:
        print("Failed to set password:", response.text)
