import dotenv from 'dotenv';
import path from 'node:path';
import {fileURLToPath} from 'url';

export interface Config {
    apiUrl: string;
    gitSha: string;
    logLevel: string;
    httpPort: number;
    srcDir: string;
    sessionSecret: string;
    staticDir: string;
    NODE_ENV?: string;
}

// cache the config
let config: Config | undefined;

/**
 * Load configuration from the environment
 */
export function loadConfig(): Config {
    if (config) {
        return config;
    }
    // load configuration from .env file into process.env
    dotenv.config();

// get the file path for the directory this file is in
    const dirname = path.dirname(fileURLToPath(import.meta.url));
// get the file path for the web/src directory
    const srcDir = path.join(dirname, '..');
// get the file path for the .static directory
    const staticDir = path.join(srcDir, '.static');

    const {
        API_URL,
        GIT_SHA,
        LOG_LEVEL,
        HTTP_PORT,
        NODE_ENV
    } = process.env;

    config = {
        // the URL of the API service
        apiUrl: API_URL || 'http://localhost:3000',
        gitSha: GIT_SHA || '',
        // the log level to use
        logLevel: LOG_LEVEL || 'info',
        // the HTTP port to listen on
        httpPort: HTTP_PORT && parseInt(HTTP_PORT) || 8080,
        // the web/src directory
        srcDir,
        sessionSecret: 'shhh, secret!',
        // the static directory to serve assets from (images, css, etc..)
        staticDir,
        NODE_ENV: NODE_ENV
    };
    return config;
}

export interface BuildConfig {
    srcDir: string;
    staticDir: string;
}

/**
 * Config required for the build script
 */
export function loadBuildConfig(): BuildConfig {
    // get the file path for the directory this file is in
    const dirname = path.dirname(fileURLToPath(import.meta.url));
    // get the file path for the src directory
    const srcDir = path.join(dirname, '..');
    // get the file path for the .static directory
    const staticDir = path.join(srcDir, '.static');

    return {
        srcDir,
        staticDir
    };
}
