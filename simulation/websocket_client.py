import websocket
import json
import time
import urllib.parse
import threading
import random
import time

# Define the tokens (these will be replaced by the login script)
token1 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiY2xpZW50VHlwZSI6ImRyaXZlciIsImlhdCI6MTczMjcwMjkwNiwiZXhwIjoxNzMyNzA2NTA2fQ.FvcKW4A3j3TfpmjE6MFKNax4XHfHA79nb8LT8GbXtfs"
token2 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwiY2xpZW50VHlwZSI6ImRyaXZlciIsImlhdCI6MTczMjcwMjkwNywiZXhwIjoxNzMyNzA2NTA3fQ.Lvt01b4UrO_UcmlEow_OHbCxRhoh6LSsEnbaprklF1E"
token3 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MywiY2xpZW50VHlwZSI6ImRyaXZlciIsImlhdCI6MTczMjcwMjkwNywiZXhwIjoxNzMyNzA2NTA3fQ.kVvHKQGXdooo9siAO8bT5iXAMj-qkTUdbuCJkep_Hqo"
token4 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NCwiY2xpZW50VHlwZSI6ImRyaXZlciIsImlhdCI6MTczMjcwMjkwNywiZXhwIjoxNzMyNzA2NTA3fQ.cIhKA_kNBPzBMI2-oPxbRycspnyxaACJFTNB5IdqVrg"
token5 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NSwiY2xpZW50VHlwZSI6ImRyaXZlciIsImlhdCI6MTczMjcwMjkwNywiZXhwIjoxNzMyNzA2NTA3fQ.OfTVSbW0jCbJ05P3wHq3JwguHVHWXKFLkEKl3kOAAiU"

#url = '192.168.1.101'
url = '13.126.188.82'

# Function to create the message to send to WebSocket
def create_message(coordinate, type, count):
    return json.dumps({
        "latitude": coordinate[0],
        "longitude": coordinate[1],
        "route": type,
        "count": count
    })

# Function to send coordinates via WebSocket
def send_coordinates(token, type, factor, start, thread_id):
    # Loading coordinates data (you should have a file named 'coordinates.json')
    with open('coordinates.json', 'r') as file:
        data = json.load(file)

    coordinates = data.get(f'path_{type}', [])
    count = 0

    def on_open(ws):
        print(f"WebSocket connection opened for Thread {thread_id}.")
        
        direction = 1  # 1 means forward, -1 means backward
        idx = start
        end = len(coordinates)
        count = 0  # Initialize the count variable
        
        while True:
            # Get the appropriate range of coordinates based on the direction
            if direction == 1:
                range_indices = range(idx, end)
            else:
                range_indices = range(end - 1, -1, -1)

            for i in range_indices:
                if i % factor == 0:
                    if ws.sock and ws.sock.connected:
                        # Create and send the message
                        msg = create_message(coordinates[i], type, count)
                        ws.send(msg)
                        print(f"Thread {thread_id}: Sent: {msg}")
                        
                        # Check for random chance to modify the count
                        if random.random() < 0.3:
                            rand_chance = random.random()
                            if rand_chance < 0.6:
                                if count < 10:
                                    count += 1
                                    print(f"Thread {thread_id}: Count increased to {count}")
                            elif rand_chance < 1.0:
                                if count > 0:
                                    count -= 1
                                    print(f"Thread {thread_id}: Count decreased to {count}")
                            
                            time.sleep(1)
                        
                    else:
                        print(f"Thread {thread_id}: Connection is closed")
                        exit()

                    time.sleep(0.5)  # Sleep 0.5 seconds between messages
                else:
                    continue

            # After sending in the current direction, change direction
            direction *= -1

    def on_message(ws, message):
        print(f"Received: {message}")

    def on_error(ws, error):
        print(f"Error: {error}")

    def on_close(ws, close_status_code, close_msg):
        print(f"WebSocket connection closed for Thread {thread_id}.")

    # Start WebSocket connection
    encoded_token = urllib.parse.quote(token)
    ws_url = f"ws://{url}:3000/ws?token={encoded_token}"
    ws = websocket.WebSocketApp(ws_url, on_open=on_open, on_message=on_message, on_error=on_error, on_close=on_close)
    ws.run_forever()

# Function to run all the WebSocket sending in parallel
def run_parallel_sends():
    # Define path information (this corresponds to the paths in 'coordinates.json')
    calls = [
        (token1, 1, 2, 600),
        (token2, 1, 2, 1500),
        (token3, 2, 2, 0),
        (token4, 2, 2, 1515),
        (token5, 1, 2, 900),
    ]
    
    threads = []
    
    # Create a thread for each call to send_coordinates
    for idx, (token, type, factor, start) in enumerate(calls):
        thread = threading.Thread(target=send_coordinates, args=(token, type, factor, start, idx))
        threads.append(thread)
        thread.start()
    
    # Join all threads to ensure all instances complete
    for thread in threads:
        thread.join()

# Run the parallel WebSocket send requests
run_parallel_sends()
