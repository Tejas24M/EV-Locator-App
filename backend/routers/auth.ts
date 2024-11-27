import express, { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { db, User } from '../database';

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'GgNOzBgcJeR2wSZf';

// Registration Route
router.post('/register', async (req: Request, res: Response): Promise<void> => {
    const { username, password, clientType } = req.body;

    if (!username || !password || !clientType) {
        res.status(400).json({ error: 'All fields (username, password, clientType) are required' });
        return;
    }

    try {
        // Check if the username already exists
        db.get(`SELECT * FROM clients WHERE username = ?`, [username], async (err, row) => {
            if (err) {
                res.status(500).json({ error: 'Database error during registration' });
                return;
            }

            if (row) {
                res.status(400).json({ error: 'Username already exists' });
                return;
            }

            // Hash the password before saving it
            const hashedPassword = await bcrypt.hash(password, 10);

            db.run(
                `INSERT INTO clients (username, password, client_type) VALUES (?, ?, ?)`,
                [username, hashedPassword, clientType],
                (err) => {
                    if (err) {
                        console.log(err)
                        res.status(500).json({ error: 'Registration failed due to server error' });
                        return;
                    }
                    res.status(201).json({ message: 'User registered successfully' });
                }
            );
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error during registration' });
    }
});

// Login Route
router.post('/login', async (req: Request, res: Response): Promise<void> => {
    const { username, password } = req.body;

    if (!username || !password) {
        res.status(400).json({ error: 'Username and password are required' });
        return;
    }

    try {
        db.get(`SELECT * FROM clients WHERE username = ?`, [username], async (err, row) => {
            if (err) {
                res.status(500).json({ error: 'Database error during login' });
                return;
            }

            const user = row as User;

            if (!user || !(await bcrypt.compare(password, user.password))) {
                res.status(401).json({ error: 'Invalid username or password' });
                return;
            }

            // Generate JWT token
            const token = jwt.sign({ id: user.id, clientType: user.client_type }, JWT_SECRET, { expiresIn: '1h' });
            res.json({ token: token, role: user.client_type});
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error during login' });
    }
});

export default router;
