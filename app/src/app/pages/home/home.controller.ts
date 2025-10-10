import type {Request, Response} from 'express';

/**
 * Render the home page
 */
export function viewHomepage(req: Request, res: Response) {
    res.render('pages/home/home.view.njk', {
        pageTitle: 'Welcome home'
    });
}
