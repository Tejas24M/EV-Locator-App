import express, { Application, Request, Response, NextFunction } from 'express';
import { resolve } from 'path';
import authRouter from './auth';

export default function configure(app: Application) {
    app.use(express.json());
    app
        .get('/', (req, res) => {
            res.sendFile(resolve(__dirname, '../index.html'));
        })
        .get('/login.html', (req, res) => {
            res.sendFile(resolve(__dirname, '../public/html/login.html'));
        })
        .get('/register.html', (req, res) => {
            res.sendFile(resolve(__dirname, '../public/html/register.html'));
        })
        .use(express.static('public'))
        .use('/auth', authRouter)
        .use('/error', (req, res, next) => {
            next(new Error('Other Error'));
        })
        .use((req, res, next) => {
            next(new Error('Not Found'));
        })
        .use((error: Error, req: Request, res: Response, next: NextFunction) => {
            switch (error.message) {
                case 'Not Found':
                    res.sendFile(resolve(__dirname, '../notfound.html'));
                    return;
            }

            res.sendFile(resolve(__dirname, '../error.html'));
        });
}
