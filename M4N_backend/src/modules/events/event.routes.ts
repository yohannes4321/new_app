import { Router } from "express";
import { EventController } from "./event.controller.js";
import { authMiddleware, adminMiddleware } from "../auth/auth.middleware.js";

const router = Router();

// GET /api/events => List all events
router.get("/", EventController.getAllEvents);

// GET /api/events/:id => Specific Event with ID
router.get("/:id", EventController.getEventById);

/**
 * PROTECTED ROUTES
 */

// POST /api/events => Creates a new event (admin only)
router.post("/", authMiddleware, adminMiddleware, EventController.createEvent);

// PUT /api/events/:id => Updates an event (admin only)
router.put("/:id", authMiddleware, adminMiddleware, EventController.updateEvent);

// DELETE /api/events/:id => Deletes an event (admin only)
router.delete("/:id", authMiddleware, adminMiddleware, EventController.deleteEvent);

/**
 * USER REGISTRATION ROUTES
 */

// POST /api/events/:id/register => Registers a user for an event (user only)
router.post("/:id/register", authMiddleware, EventController.registerForEvent);

// DELETE /api/events/:id/unregister => Unregisters a user from an event (user only)
router.delete("/:id/unregister", authMiddleware, EventController.unregisterFromEvent);

export default router;