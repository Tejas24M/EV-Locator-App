import express from 'express';
import expressWs from 'express-ws';
import jwt from 'jsonwebtoken';
import { db } from './database';
import { WebSocket } from 'ws';
import configure from './routers';
import { findShortestDistance } from './distance';

const expressServer = express();
const wsServer = expressWs(expressServer);
const app = wsServer.app;

const JWT_SECRET = process.env.JWT_SECRET || 'GgNOzBgcJeR2wSZf';
const port = process.env.PORT || 3000;

let clients: { [key: string]: WebSocket[] } = {};

// Middleware to verify JWT
function authenticate(token: string) {
    try {
        const decoded = jwt.verify(token, JWT_SECRET) as { id: number; clientType: string };
        return decoded;
    } catch (err) {
        return null;
    }
}

// WebSocket Connection Handling
app.ws('/ws', (ws, req) => {
    const token = req.query.token as string;

    let clientData: { id: number; clientType: string } | null = null;
    if (token) {
        clientData = authenticate(token);

        if (!clientData) {
            console.error("Invalid Token");
            ws.send(JSON.stringify({ status: 'fail', message: 'Invalid token' }));
            ws.terminate();
            return;
        }
    }
    // 'guest' for non-authenticated clients
    const clientType = clientData ? clientData.clientType : 'guest';

    // Store WebSocket connections by clientType
    if (!clients[clientType]) clients[clientType] = [];
    clients[clientType].push(ws);

    ws.on('message', (message: string) => {
        if (clientData && clientType === 'driver') {

            let parsedMessage;
            try {
                parsedMessage = JSON.parse(message);
            } catch (error) {
                console.error("Invalid JSON received:", message);
                return;
            }

            if (!parsedMessage.hasOwnProperty('latitude') || !parsedMessage.hasOwnProperty('longitude') || !parsedMessage.hasOwnProperty('route') || !parsedMessage.hasOwnProperty('count')) {
                console.error("Fields required: 'latitude', 'longitude', 'route'.");
                return;
            }

            let latitude = parsedMessage.latitude as number;
            let longitude = parsedMessage.longitude as number;
            let route = parsedMessage.route as number;
            let count = parsedMessage.count as number;

            let distance = findShortestDistance(latitude, longitude, route) as number;
            if(distance > 10) {
                console.error("Far away from road");
                ws.send(JSON.stringify({ status: 'fail', message: 'Far away from road' }));
                ws.terminate();
                return;
            }

            // ADD VALIDATION

            // console.log(parsedMessage);

            // Message payload
            const data = {
                driverId: clientData.id,
                latitude: latitude,
                longitude: longitude,
                route: route,
                count: count
            };

            // Broadcast the message along with the driver id to all clients (drivers and users)
            Object.values(clients).flat().forEach(clientWs => clientWs.send(JSON.stringify(data)));

        }
    });

    ws.on('close', () => {
        // Remove the WebSocket from the correct clientType group on disconnect
        const clientIndex = clients[clientType]?.indexOf(ws);
        if (clientIndex !== -1) {
            clients[clientType].splice(clientIndex, 1);
        }
    });
});

// Configure the Express app with routers
configure(app);

// Start the server
const server = app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
