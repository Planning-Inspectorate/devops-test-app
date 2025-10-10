import type { Logger } from 'pino';
import type { ErrorRequestHandler, Request, Response } from 'express';

/**
 * A catch-all error handler to use as express middleware
 */
export function buildDefaultErrorHandlerMiddleware(logger: Logger): ErrorRequestHandler {
	return (error, req, res, next) => {
		const message = error.message || 'unknown error';
		logger.error(error, message); // log the original error to include full details

		if (res.headersSent) {
			next(error);
			return;
		}

		// make sure we don't use an invalid code
		const code = error.statusCode && error.statusCode > 399 ? error.statusCode : 500;
		res.status(code);
		res.render(`views/layouts/error`, {
			pageTitle: 'Sorry, there was an error',
			messages: [message, 'Try again later']
		});
	};
}

/**
 * A catch-all handler to serve a 404 page
 */
export function notFoundHandler(req: Request, res: Response) {
	res.status(404);
	res.render(`views/layouts/error`, {
		pageTitle: 'Page not found',
		messages: [
			'If you typed the web address, check it is correct.',
			'If you pasted the web address, check you copied the entire address.'
		]
	});
}
