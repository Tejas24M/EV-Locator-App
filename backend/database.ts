import sqlite3 from 'sqlite3';
import path from 'path';

type User = {
    id: number;
    username: string;
    password: string;
    client_type: string;
};

// Open the SQLite database file
const dbPath = path.resolve(__dirname, 'db.sqlite3');
const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error('Could not connect to SQLite database:', err.message);
    } else {
        console.log('Connected to SQLite database');
    }
});

// Define the table schema
function createTables() {
    db.run(`
        CREATE TABLE IF NOT EXISTS clients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            client_type TEXT CHECK(client_type IN ('driver', 'user')) NOT NULL
        )
    `, (err) => {
        if (err) {
            console.error('Could not create clients table:', err.message);
        } else {
            console.log('Clients table is ready');
        }
    });
}

// Initialize the database tables
createTables();

export { db, User };
