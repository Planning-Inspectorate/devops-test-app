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

	watchTestSecretValue() {
		const logger = this.logger.child({method: 'watchTestSecretValue'});
		logger.info('START');
		let value = this.#config.testSecret?.toString() || '<undefined>';
		logger.info({value},'initial value');
		setTimeout(() => {
			logger.debug('checking secret value');
			if (value !== this.#config.testSecret) {
				value = this.#config.testSecret?.toString() || '<undefined>';
				logger.info({value},'secret value changed');
			}
		}, 5 * 1000);
	}
}
