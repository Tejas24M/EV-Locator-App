import requests

# Define the login URL
#login_url = "http://192.168.1.101:3000/auth/login"
login_url = "http://13.126.188.82:3000/auth/login"

# Common password for all users
password = "1234"

# Loop through usernames Simulation1 to Simulation5 and retrieve tokens
tokens = []  # List to store the tokens
for i in range(1, 6):
    username = f"Simulation{i}"  # Generate usernames Simulation1, Simulation2, etc.

    # Create a dictionary for the login data
    login_data = {
        "username": username,
        "password": password
    }

    # Send the POST request to the login endpoint
    response = requests.post(login_url, json=login_data)

    # Check if the request was successful (status code 200)
    if response.status_code == 200:
        try:
            # Parse the response JSON and extract the token
            response_data = response.json()
            token = response_data.get("token")
            
            if token:
                print(f"Login successful for {username}! Token: {token}")
                tokens.append(token)  # Store the token in the list
            else:
                print(f"Token not found in the response for {username}.")
        except ValueError:
            print(f"Error: Failed to parse JSON response for {username}.")
    else:
        print(f"Login failed for {username} with status code: {response.status_code}")

# Ensure we have exactly 5 tokens (one for each Simulation user)
if len(tokens) != 5:
    print("Error: Failed to retrieve all tokens. Exiting...")
    exit()

# Debug: Print tokens to ensure they were retrieved correctly
print(f"Retrieved tokens: {tokens}")

# Write the tokens to the websocket_client.py script file
websocket_client_path = 'websocket_client.py'

# Read the original websocket_client.py file
with open(websocket_client_path, 'r') as file:
    websocket_client_code = file.read()

# Debug: Print the first 1000 characters to ensure we're reading it correctly
print("Read websocket_client.py content:")
print(websocket_client_code[:1000])

# Replace token1 to token5 placeholders with actual tokens
updated_code = websocket_client_code.replace("<token1>", tokens[0])
updated_code = updated_code.replace("<token2>", tokens[1])
updated_code = updated_code.replace("<token3>", tokens[2])
updated_code = updated_code.replace("<token4>", tokens[3])
updated_code = updated_code.replace("<token5>", tokens[4])

# Debug: Print the first 1000 characters of updated code to ensure replacement
print("Updated websocket_client.py content (first 1000 chars):")
print(updated_code[:1000])

# Write the updated code back to the websocket_client.py
with open(websocket_client_path, 'w') as file:
    file.write(updated_code)

print("Tokens have been written to websocket_client.py.")
