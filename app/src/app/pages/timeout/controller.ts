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

        let logInterval;
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
        const timeout = req.query.timeoutSeconds || '120';
        const timeoutMs = parseInt(timeout) * 1000;
        log.info({timeout, timeoutMs}, 'query params');

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
            res.sendStatus(200);
            log.info('200 response sent');
        }
    }
}
