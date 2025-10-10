import {initLogger} from '../util/logger.ts';
import type {Logger} from 'pino';
import type {Config} from "./config.ts";

/**
 * This class encapsulates all the services and clients for the application
 */
export class AppService {
	#config: Config;
	logger: Logger;

	constructor(config: Config) {
		this.#config = config;
        this.logger = initLogger(config);
	}

	get gitSha() {
		return this.#config.gitSha;
	}

	get staticDir() {
		return this.#config.staticDir;
	}
}
