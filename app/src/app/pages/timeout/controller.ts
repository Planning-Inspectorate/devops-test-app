import type {Request, Response} from 'express';
import type {AppService} from "../../service.ts";
import {clearInterval} from "node:timers";

/**
 * For testing origin timeout behaviour
 */
export function buildTimeoutController(service: AppService) {
    const logger = service.logger;
    return async (req: Request, res: Response) => {
        const id = Math.random().toString(36).substr(2);
        const log = logger.child({id, request: 'timeout'});

        let logInterval: NodeJS.Timeout | null = null;
        let cancelled = false;

        req.on('close', () => {
            log.info('request closed');
            cancelled = true;
            if (logInterval) {
                log.info('[req] clear interval');
                clearInterval(logInterval);
                logInterval = null;
            }
        });
        res.on('finished', () => {
            log.info('response finished');
        });
        res.on('close', () => {
            log.info('response closed');
            if (logInterval) {
                log.info('[res] clear interval');
                clearInterval(logInterval);
                logInterval = null;
            }
        });

        log.info('new request');
        const timeout = (typeof req.query.timeoutSeconds === 'string' && req.query.timeoutSeconds) || '120';
        const timeoutMs = parseInt(timeout) * 1000;
        const sendHeaders = typeof req.query.sendHeaders === 'string' && req.query.sendHeaders === 'true';
        const sendHeadersTimeout = (typeof req.query.sendHeadersTimeoutSeconds === 'string' && req.query.sendHeadersTimeoutSeconds) || '1';
        const sendHeadersTimeoutMs = parseInt(sendHeadersTimeout) * 1000;
        log.info({timeout, timeoutMs, sendHeaders}, 'query params');

        const body = 'OK';

        if (sendHeaders) {
            setTimeout(() => {
                res.writeHead(200, {
                    'Content-Length': Buffer.byteLength(body),
                    'Content-Type': 'text/plain',
                });
                log.info({timeout, sendHeaders}, 'status & headers sent');
            }, sendHeadersTimeoutMs);
        }

        // log every 5s so we know its still doing things.
        let elapsed = 0;
        logInterval = setInterval(() => {
            elapsed+=5;
            log.info({timeout, elapsed}, 'still running');
        }, 5000);
        await new Promise(resolve => setTimeout(resolve, timeoutMs));
        log.info({timeout}, 'elapsed');
        if (cancelled) {
            log.info('no response, cancelled');
        } else {
            if (sendHeaders) {
                res.end(body);
            } else {
                res.sendStatus(200);
            }
            log.info('200 response sent');
        }
    }
}
