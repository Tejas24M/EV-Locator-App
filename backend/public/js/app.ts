(function () {
    let ws: WebSocket;
    const messages = <HTMLElement>document.getElementById('messages');
    const wsSend = <HTMLButtonElement>document.getElementById('ws-send');
    const latitudeInput = <HTMLInputElement>document.getElementById('latitude');
    const longitudeInput = <HTMLInputElement>document.getElementById('longitude');

    const host = window.location.host;

    // Assume the token is stored in localStorage after login
    const token = localStorage.getItem('authToken');

    // Function to show messages in the message area
    function showMessage(message: string) {
        if (messages) {
            messages.textContent += `\n${message}`;
            messages.scrollTop = messages.scrollHeight;
        }
    }

    // Function to close the WebSocket connection
    function closeConnection() {
        if (ws) {
            ws.close();
            showMessage('WebSocket connection closed');
        }
    }

    // Function to open WebSocket connection (with token if available)
    function openConnection() {
        if (token) {
            // If token is found, create a WebSocket with the token as a query parameter
            ws = new WebSocket(`ws://${host}/ws?token=${encodeURIComponent(token)}`);
            showMessage('WebSocket connection established with token');
        } else {
            // If no token, create a WebSocket without token
            ws = new WebSocket(`ws://${host}/ws`);
            showMessage('WebSocket connection established (no token)');
        }

        // Set up event listeners for the WebSocket
        ws.addEventListener('error', () => {
            showMessage('WebSocket error');
        });

        ws.addEventListener('open', () => {
            showMessage('WebSocket connection established');
        });

        ws.addEventListener('close', () => {
            showMessage('WebSocket connection closed');
        });

        // Listen for incoming WebSocket messages (everyone can receive data)
        ws.addEventListener('message', (msg: MessageEvent<string>) => {
            showMessage(`Received message: ${msg.data}`);
        });
    }

    // Open the WebSocket connection immediately
    openConnection();

    // Send message via WebSocket only if the user is authenticated
    wsSend.addEventListener('click', (event) => {
        event.preventDefault(); // Prevent form submission
        
        const latitude = latitudeInput?.value;
        const longitude = longitudeInput?.value;
    
        if (!ws) {
            showMessage('No WebSocket connection');
            return;
        }
        else if (!token) {
            showMessage('You must be logged in to send messages');
            return;
        }

        // Ensure both latitude and longitude are provided
        if (!latitude || !longitude) {
            showMessage('Please enter both latitude and longitude');
            return;
        }
    
        // Validate latitude and longitude values
        const lat = parseFloat(latitude);
        const lon = parseFloat(longitude);
    
        if (isNaN(lat) || isNaN(lon)) {
            showMessage('Invalid latitude or longitude');
            return;
        }
    
        // Create the JSON object to send
        const coordinates = {
            latitude: lat,
            longitude: lon
        };
    
        // Check WebSocket connection
        if (!ws) {
            showMessage('No WebSocket connection');
            return;
        }
    
        // Send the JSON object via WebSocket
        ws.send(JSON.stringify(coordinates));
    
        // Display a message confirming the coordinates were sent
        showMessage(`Sent: ${JSON.stringify(coordinates)}`);
    
        // Optionally, clear the input fields after sending
        latitudeInput.value = '';
        longitudeInput.value = '';
    });

    // Close the WebSocket connection when the user logs out or session ends
    window.addEventListener('beforeunload', closeConnection); // Close connection on page unload (e.g., logout)
})();
