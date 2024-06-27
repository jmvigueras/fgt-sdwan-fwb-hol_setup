####################################################################
# Script to generete users json file and csv
#
# jvigueras@fortinet.com
####################################################################
import json
import csv
import random
import string

#------------------------------------------------------------------------------
# VARIABLES
#------------------------------------------------------------------------------
# Number of users to generate
NUM_USERS = 3

JSON_OUTPUT_FILE = "users.json"
CSV_OUTPUT_FILE = "users.csv"
PREFIX = "fortixpert"           # FortiCloud IAM users prefix
DOMAIN = "@fortidemoscloud.com" # Fortimail domain
PASSWORD = "xxxxx"              # update with password assigned to FortiCloudUsers or use generate_password() function

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------
# Function to generate a random password
def generate_password():
    characters = string.ascii_letters + string.digits + '!@#$%&*'
    return ''.join(random.choice(characters) for i in range(12))

#------------------------------------------------------------------------------
# Code
#------------------------------------------------------------------------------
# Start of JSON
users = {}
# Start of CSV
csv_rows = [["User name", "Password", "Display"]]

# Generate JSON for each user
for i in range(1, NUM_USERS + 1):
    username = f"{PREFIX}{i}"
    email = f"{username}{DOMAIN}"
    #password = generate_password()
    password = PASSWORD

    # JSON data
    users[username] = {
        "username": username,
        "email": email,
        "password": password
    }
    # CSV data
    csv_rows.append([email, password, username])

# Write JSON to file
with open(JSON_OUTPUT_FILE, 'w') as f:
    json.dump(users, f, indent=2)

print(f"JSON generated successfully: {JSON_OUTPUT_FILE}")

# Write CSV to file
with open(CSV_OUTPUT_FILE, 'w', newline='') as csv_file:
    csv_writer = csv.writer(csv_file)
    csv_writer.writerows(csv_rows)

print(f"CSV generated successfully: {CSV_OUTPUT_FILE}")