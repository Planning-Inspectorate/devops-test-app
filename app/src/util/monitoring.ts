import { Router as createRouter } from 'express';
import type { IRouter, Response, Request } from 'express';
import { asyncHandler, type AsyncRequestHandler } from "./async-handler.ts";

interface MonitoringRoutesOptions {
	gitSha?: string;
}

export function createMonitoringRoutes({ gitSha }: MonitoringRoutesOptions): IRouter {
	const router = createRouter();
	const handleHealthCheck = buildHandleHeathCheck(gitSha);

	router.head('/', asyncHandler(handleHeadHealthCheck));
	router.get('/health', asyncHandler(handleHealthCheck));

	return router;
}

export function handleHeadHealthCheck(_: Request, response: Response) {
	// no-op - HEAD mustn't return a body
	response.sendStatus(200);
}

export function buildHandleHeathCheck(
	gitSha?: string
): AsyncRequestHandler {
	return async (_, response) => {
		response.status(200).send({
			status: 'OK',
			uptime: process.uptime(),
			commit: gitSha
		});
	};
}
