import { CreateTestimonyInput, UpdateTestimonyInput } from "./testimony.types.js";

export class TestimonyValidator {
  static validateCreate(data: CreateTestimonyInput): string | null {
    if (!data || typeof data !== "object") {
      return "Request body is required";
    }

    if (!data.title || typeof data.title !== "string" || data.title.trim().length < 3) {
      return "title must be at least 3 characters long";
    }

    if (data.verse !== undefined && (typeof data.verse !== "string" || !data.verse.trim())) {
      return "verse must be a non-empty string";
    }

    if (!data.text_content || typeof data.text_content !== "string" || data.text_content.trim().length < 10) {
      return "text_content must be at least 10 characters long";
    }

    if (data.images !== undefined) {
      if (!Array.isArray(data.images)) {
        return "images must be an array of URLs";
      }
      if (!data.images.every((image) => typeof image === "string" && image.trim().length > 0)) {
        return "images must contain only non-empty string URLs";
      }
    }

    if (!data.posted_by || typeof data.posted_by !== "string" || !data.posted_by.trim()) {
      return "posted_by is required";
    }

    if (data.youtube_video_id !== undefined && typeof data.youtube_video_id !== "string") {
      return "youtube_video_id must be a string";
    }

    return null;
  }

  static validateUpdate(data: UpdateTestimonyInput): string | null {
    if (!data || typeof data !== "object") {
      return "Request body is required";
    }

    if (data.title !== undefined && (typeof data.title !== "string" || data.title.trim().length < 3)) {
      return "title must be at least 3 characters long";
    }

    if (data.verse !== undefined && (typeof data.verse !== "string" || !data.verse.trim())) {
      return "verse must be a non-empty string";
    }

    if (
      data.text_content !== undefined &&
      (typeof data.text_content !== "string" || data.text_content.trim().length < 10)
    ) {
      return "text_content must be at least 10 characters long";
    }

    if (data.images !== undefined) {
      if (!Array.isArray(data.images)) {
        return "images must be an array of URLs";
      }

      if (!data.images.every((image) => typeof image === "string" && image.trim().length > 0)) {
        return "images must contain only non-empty string URLs";
      }
    }

    if (data.posted_by !== undefined && (typeof data.posted_by !== "string" || !data.posted_by.trim())) {
      return "posted_by must be a non-empty string";
    }

    if (data.youtube_video_id !== undefined && typeof data.youtube_video_id !== "string") {
      return "youtube_video_id must be a string";
    }

    return null;
  }

  static validateCommentText(text: unknown): string | null {
    if (typeof text !== "string" || text.trim().length < 1) {
      return "comment text is required";
    }

    if (text.trim().length > 1000) {
      return "comment text must not exceed 1000 characters";
    }

    return null;
  }
}
