import type {Request, Response} from 'express';

/**
 * Render the POST page
 */
export function handlePost(req: Request, res: Response) {
    res.render('pages/post/post.view.njk', {
        pageTitle: 'Submitted successfully'
    });
}
