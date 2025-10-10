import { Router as createRouter } from 'express';
import type { IRouter } from 'express';
import { viewHomepage } from "./pages/home/home.controller.ts";
import { handlePost } from "./pages/post/post.controller.ts";
import { createMonitoringRoutes } from "../util/monitoring.ts";
import type {AppService} from "./service.js";

/**
 * Main app router
 */
export function buildRouter(service: AppService): IRouter {
	const router = createRouter();
	const monitoringRoutes = createMonitoringRoutes(service);

	router.use('/', monitoringRoutes);

    router.route('/')
        .get(viewHomepage)
        .post(handlePost);
    router.route('/post').post(handlePost);

	return router;
}
