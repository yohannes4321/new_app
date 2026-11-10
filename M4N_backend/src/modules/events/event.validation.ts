export class EventValidator {
    static validateCreate(data: any): string | null {
        if (!data || typeof data !== "object") {
            return "Request body is required";
        }
        if (!data.title || typeof data.title !== "string" || data.title.length < 3) {
            return "Title must be at least 3 characters long";
        }
        if (!data.description || typeof data.description !== "string") {
            return "Description is required";
        }
        if (!data.date_time || isNaN(Date.parse(data.date_time))) {
            return "Valid date_time (ISO string) is required";
        }
        if (!data.location || typeof data.location !== "string") {
            return "Location is required";
        }
        if (data.cover_image !== undefined && typeof data.cover_image !== "string") {
            return "cover_image must be a string";
        }
        if (data.allows_registration !== undefined && typeof data.allows_registration !== "boolean") {
            return "allows_registration must be a boolean";
        }
        return null;
    }

    static validateUpdate(data: any): string | null {
        if (!data || typeof data !== "object") {
            return "Request body is required";
        }
        if (data.title !== undefined && (typeof data.title !== "string" || data.title.length < 3)) {
            return "Title must be at least 3 characters long";
        }
        if (data.date_time !== undefined && isNaN(Date.parse(data.date_time))) {
            return "Valid date_time (ISO string) is required";
        }
        if (data.description !== undefined && typeof data.description !== "string") {
            return "Description must be a string";
        }
        if (data.location !== undefined && typeof data.location !== "string") {
            return "Location must be a string";
        }
        if (data.cover_image !== undefined && typeof data.cover_image !== "string") {
            return "cover_image must be a string";
        }
        if (data.allows_registration !== undefined && typeof data.allows_registration !== "boolean") {
            return "allows_registration must be a boolean";
        }
        if (data.is_full !== undefined && typeof data.is_full !== "boolean") {
            return "is_full must be a boolean";
        }
        return null;
    }
}
