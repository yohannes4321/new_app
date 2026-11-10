import { Request, Response } from "express";
import { EventService } from "./event.service.js";
import { CreateEventInput, UpdateEventInput } from "./event.types.js";
import { EventValidator } from "./event.validation.js";

export class EventController {
    /**
     * GET /api/events
     * Supports query params: ?page=1&limit=10&upcoming=true
     */
    static async getAllEvents(req: Request, res: Response): Promise<void> {
        try {
            const pageRaw = req.query.page !== undefined ? Number(req.query.page) : undefined;
            const limitRaw = req.query.limit !== undefined ? Number(req.query.limit) : undefined;
            const upcomingRaw = req.query.upcoming;

            if (pageRaw !== undefined && (!Number.isInteger(pageRaw) || pageRaw < 1)) {
                res.status(400).json({ success: false, message: "page must be a positive integer" });
                return;
            }
            if (limitRaw !== undefined && (!Number.isInteger(limitRaw) || limitRaw < 1 || limitRaw > 100)) {
                res.status(400).json({ success: false, message: "limit must be an integer between 1 and 100" });
                return;
            }
            if (upcomingRaw !== undefined && upcomingRaw !== "true" && upcomingRaw !== "false") {
                res.status(400).json({ success: false, message: "upcoming must be true or false" });
                return;
            }

            const page = pageRaw ?? 1;
            const limit = limitRaw ?? 10;
            const upcoming = upcomingRaw === "true";

            const { events, total } = await EventService.getAllEvents({ page, limit, upcoming });

            res.status(200).json({
                success: true,
                data: events,
                pagination: {
                    total,
                    page,
                    limit,
                    pages: Math.ceil(total / limit)
                }
            });
        } catch (error) {
            res.status(500).json({ success: false, message: "Failed to fetch events" });
        }
    }

    /**
     * GET /api/events/:id
     */
    static async getEventById(req: Request<{ id: string }>, res: Response): Promise<void> {
        try {
            const event = await EventService.getEventById(req.params.id);
            if (!event) {
                res.status(404).json({ success: false, message: "Event not found" });
                return;
            }
            res.status(200).json({ success: true, data: event });
        } catch (error) {
            res.status(400).json({ success: false, message: "Invalid event ID format" });
        }
    }

    /**
     * POST /api/events
     */
    static async createEvent(req: Request, res: Response): Promise<void> {
        try {
            const input: CreateEventInput = req.body;

            const error = EventValidator.validateCreate(input);
            if (error) {
                res.status(400).json({ success: false, message: error });
                return;
            }

            const event = await EventService.createEvent(input);
            res.status(201).json({ success: true, data: event });
        } catch (error) {
            res.status(400).json({
                success: false,
                message: error instanceof Error ? error.message : "Failed to create event",
            });
        }
    }

    /**
     * PUT /api/events/:id
     */
    static async updateEvent(req: Request<{ id: string }>, res: Response): Promise<void> {
        try {
            const input: UpdateEventInput = req.body;

            if (!input || Object.keys(input).length === 0) {
                res.status(400).json({ success: false, message: "At least one field must be provided" });
                return;
            }

            const error = EventValidator.validateUpdate(input);
            if (error) {
                res.status(400).json({ success: false, message: error });
                return;
            }

            const event = await EventService.updateEvent(req.params.id, input);
            if (!event) {
                res.status(404).json({ success: false, message: "Event not found" });
                return;
            }
            res.status(200).json({ success: true, data: event });
        } catch (error) {
            res.status(400).json({ success: false, message: "Failed to update event" });
        }
    }

    /**
     * DELETE /api/events/:id
     */
    static async deleteEvent(req: Request<{ id: string }>, res: Response): Promise<void> {
        try {
            const success = await EventService.deleteEvent(req.params.id);
            if (!success) {
                res.status(404).json({ success: false, message: "Event not found" });
                return;
            }
            res.status(200).json({ success: true, message: "Event deleted successfully" });
        } catch (error) {
            res.status(400).json({ success: false, message: "Failed to delete event" });
        }
    }

    /**
     * POST /api/events/:id/register
     */
    static async registerForEvent(req: Request<{ id: string }>, res: Response): Promise<void> {
        try {
            const userId = req.userId;
            if (!userId) {
                res.status(401).json({ success: false, message: "Unauthorized" });
                return;
            }

            const event = await EventService.registerForEvent(req.params.id, userId);
            res.status(200).json({
                success: true,
                message: "Successfully registered",
                data: {
                    registration_count: event?.registration_count
                }
            });
        } catch (error) {
            if (error instanceof Error && error.message === "Event not found") {
                res.status(404).json({ success: false, message: error.message });
                return;
            }
            if (error instanceof Error && (error.message === "Event is already full" || error.message === "Registration is not allowed")) {
                res.status(409).json({ success: false, message: error.message });
                return;
            }
            if (error instanceof Error && error.message === "Already registered") {
                res.status(409).json({ success: false, message: error.message });
                return;
            }
            res.status(400).json({
                success: false,
                message: error instanceof Error ? error.message : "Registration failed",
            });
        }
    }

    /**
     * DELETE /api/events/:id/unregister
     */
    static async unregisterFromEvent(req: Request<{ id: string }>, res: Response): Promise<void> {
        try {
            const userId = req.userId;
            if (!userId) {
                res.status(401).json({ success: false, message: "Unauthorized" });
                return;
            }

            const event = await EventService.unregisterFromEvent(req.params.id, userId);
            res.status(200).json({
                success: true,
                message: "Successfully unregistered",
                data: {
                    registration_count: event?.registration_count
                }
            });
        } catch (error) {
            if (error instanceof Error && error.message === "Event not found") {
                res.status(404).json({ success: false, message: error.message });
                return;
            }
            if (error instanceof Error && (error.message === "No registrations to remove" || error.message === "Not registered")) {
                res.status(409).json({ success: false, message: error.message });
                return;
            }
            res.status(400).json({
                success: false,
                message: error instanceof Error ? error.message : "Unregistration failed",
            });
        }
    }
}
