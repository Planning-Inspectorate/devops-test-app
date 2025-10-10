import {buildRouter} from './router.ts';
import express from 'express';
import bodyParser from 'body-parser';
import type {Express} from 'express';
import {buildLogRequestsMiddleware} from "../util/log-requests.ts";
import {configureNunjucks} from "./nunjucks.ts";
import type {AppService} from "./service.ts";
import {buildDefaultErrorHandlerMiddleware, notFoundHandler} from "../util/errors.ts";

export function createApp(service: AppService): Express {
    const router = buildRouter(service);
    const nunjucksEnvironment = configureNunjucks();

    // create an express app, and configure it for our usage
    const app = express();

    app.use(buildLogRequestsMiddleware(service.logger));

// configure body-parser, to populate req.body
// see https://expressjs.com/en/resources/middleware/body-parser.html
    app.use(bodyParser.urlencoded({extended: true}));
    app.use(bodyParser.json());

// Set the express view engine to nunjucks
// calls to res.render will use nunjucks
    nunjucksEnvironment.express(app);
    app.set('view engine', 'njk');

// static files
    app.use(express.static(service.staticDir));

// register the router, which will define any subpaths
// any paths not defined will return 404 by default
    app.use('/', router);

    app.use(notFoundHandler);

// catch/handle errors last
    app.use(buildDefaultErrorHandlerMiddleware(service.logger));

    return app;
}
