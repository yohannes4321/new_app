import { jest, afterEach, describe, it, expect } from '@jest/globals';

// ------------------------------------------------------------------
// MOCK EVENT MODEL (in-memory)
// ------------------------------------------------------------------
jest.unstable_mockModule('../src/modules/events/event.model.js', () => {
  let store = new Map<string, any>();
  let counter = 0;

  class Event {
    _id: string;

    constructor(data: any) {
      this._id = `${++counter}`;
      Object.assign(this, data);
    }

    async save() {
      store.set(this._id, this);
      return this;
    }

    static async findById(id: string) {
      return store.get(id) ?? null;
    }

    static async findByIdAndUpdate(id: string, update: any) {
      const existing = store.get(id);
      if (!existing) return null;
      Object.assign(existing, update);
      store.set(id, existing);
      return existing;
    }

    static async findByIdAndDelete(id: string) {
      const existing = store.get(id);
      if (!existing) return null;
      store.delete(id);
      return existing;
    }

    static find() {
      const results = Array.from(store.values());
      const chain = {
        sort: () => chain,
        skip: () => chain,
        limit: () => Promise.resolve(results),
      };
      return chain;
    }

    static async countDocuments() {
      return store.size;
    }

    static __clear() {
      store.clear();
      counter = 0;
    }
  }

  return { Event };
});

// ------------------------------------------------------------------
// DYNAMIC IMPORTS
// ------------------------------------------------------------------
const { Event } = await import('../src/modules/events/event.model.js');
// Note: We don't strictly need to dynamic import types, but it keeps things consistent
const { CreateEventInput } = await import('../src/modules/events/event.types.js');
const { EventController } = await import('../src/modules/events/event.controller.js');

afterEach(() => {
  (Event as any).__clear?.();
});

describe('POST /api/events', () => {
    it('should create a new event', async () => {
        const newEvent: CreateEventInput = {
            "title": "test event",
            "description": "test description",
            "date_time": "2025-12-12T12:00:00Z",
            "location": "test location",
            "cover_image": "test cover image url",
            "allows_registration": true
        }

        const req: any = { body: newEvent };
        const res: any = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn().mockReturnThis(),
        };

        await EventController.createEvent(req, res);

        expect(res.status).toHaveBeenCalledWith(201);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true }));
        const responseBody = res.json.mock.calls[0][0];
        expect(responseBody.data.title).toBe(newEvent.title);
        expect(responseBody.data.description).toBe(newEvent.description);
        expect(responseBody.data.date_time).toBe(newEvent.date_time);
        expect(responseBody.data.location).toBe(newEvent.location);
        expect(responseBody.data.allows_registration).toBe(newEvent.allows_registration);

        // Database Validation
        const event_id = responseBody.data._id;
        const event = await Event.findById(event_id);

        expect(event).not.toBeNull();
        expect(event?.title).toBe(newEvent.title);
        expect(event?.description).toBe(newEvent.description);
        expect(event?.date_time).toBe(newEvent.date_time);
        expect(event?.location).toBe(newEvent.location);
        expect(event?.cover_image).toBe(newEvent.cover_image);
        expect(event?.allows_registration).toBe(newEvent.allows_registration);
    });

    it('should return 400 for invalid input', async () => {
        const newEvent: Partial<CreateEventInput> = {
            "description": "test description",
            "date_time": "2025-12-12T12:00:00Z",
            "location": "test location",
            "allows_registration": true,
            "cover_image": "test cover image"
        }

        const req: any = { body: newEvent };
        const res: any = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn().mockReturnThis(),
        };

        await EventController.createEvent(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: false }));
    });

    it('should create with missing optional fields', async () => {
        const newEvent: Partial<CreateEventInput> = {
            "title": "test event",
            "description": "test description",
            "date_time": "2025-12-12T12:00:00Z",
            "location": "test location",
            "allows_registration": true
        }

        const req: any = { body: newEvent };
        const res: any = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn().mockReturnThis(),
        };

        await EventController.createEvent(req, res);

        expect(res.status).toHaveBeenCalledWith(201);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true }));
    })
})
