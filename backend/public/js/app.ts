(function () {
    let ws: WebSocket;
    const messages = <HTMLElement>document.getElementById('messages');
    const wsSend = <HTMLButtonElement>document.getElementById('ws-send');
    const wsInput = <HTMLInputElement>document.getElementById('ws-input');

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
            ws = new WebSocket(`ws://127.0.0.1:3000/ws?token=${encodeURIComponent(token)}`);
            showMessage('WebSocket connection established with token');
        } else {
            // If no token, create a WebSocket without token
            ws = new WebSocket('ws://127.0.0.1:3000/ws');
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
    wsSend.addEventListener('click', () => {
        const val = wsInput?.value;

        if (!val) {
            return;
        } else if (!ws) {
            showMessage('No WebSocket connection');
            return;
        } else if (!token) {
            showMessage('You must be logged in to send messages');
            return;
        }

        // Send message if user is authenticated
        ws.send(val);
        showMessage(`Sent: "${val}"`);
        wsInput.value = ''; // Clear the input field after sending
    });

    // Close the WebSocket connection when the user logs out or session ends
    window.addEventListener('beforeunload', closeConnection); // Close connection on page unload (e.g., logout)
})();
