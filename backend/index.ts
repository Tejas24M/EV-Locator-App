import express from 'express';
import expressWs from 'express-ws';
import jwt from 'jsonwebtoken';
import { db } from './database';
import { WebSocket } from 'ws';
import configure from './routers';

const expressServer = express();
const wsServer = expressWs(expressServer);
const app = wsServer.app;

const JWT_SECRET = 'your_secret_key';
const port = process.env.PORT || 3000;

let clients: { [key: string]: WebSocket[] } = {};

// Middleware to verify JWT
function authenticate(token: string) {
    try {
        const decoded = jwt.verify(token, JWT_SECRET) as { clientType: string };
        return decoded;
    } catch (err) {
        return null;
    }
}

// WebSocket Connection Handling
app.ws('/ws', (ws, req) => {
    const token = req.query.token as string;
    const clientData = authenticate(token);

    // 'guest' for non-authenticated clients
    const clientType = clientData ? clientData.clientType : 'guest';

    // Store WebSocket connections by clientType
    if (!clients[clientType]) clients[clientType] = [];
    clients[clientType].push(ws);

    ws.on('message', (message: string) => {
        if (clientType === 'driver') {

            // ADD VALIDATION

            // Send message to all clients (drivers and users)
            Object.values(clients).flat().forEach(clientWs => clientWs.send(message));
        }
    });

    ws.on('close', () => {
        // Remove the connection from the appropriate clientType list
        clients[clientType] = clients[clientType].filter(clientWs => clientWs !== ws);
    });
});

// Configure the Express app with routers
configure(app);

// Start the server
const server = app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
