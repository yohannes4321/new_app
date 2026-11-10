import { Request, Response } from "express";
import { TestimonyService } from "./testimony.service.js";
import { CreateTestimonyInput, UpdateTestimonyInput } from "./testimony.types.js";
import { TestimonyValidator } from "./testimony.validation.js";
import { UserService } from "../users/user.service.js";

const parseIntegerId = (idParam: string): number | null => {
  const parsed = Number(idParam);
  if (!Number.isInteger(parsed) || parsed < 1) {
    return null;
  }

  return parsed;
};

const toResponseData = (testimony: any) => {
  return {
    ...testimony,
    like_count: Array.isArray(testimony.likes) ? testimony.likes.length : 0,
    comment_count: Array.isArray(testimony.comments) ? testimony.comments.length : 0,
  };
};

const getOptionalString = (value: unknown): string | undefined => {
  return typeof value === "string" ? value : undefined;
};

const parseImagesField = (value: unknown): string[] | undefined => {
  if (value === undefined) {
    return undefined;
  }

  if (Array.isArray(value)) {
    return value.filter((image): image is string => typeof image === "string").map((image) => image.trim());
  }

  if (typeof value !== "string") {
    return undefined;
  }

  const trimmed = value.trim();
  if (!trimmed) {
    return [];
  }

  try {
    const parsed = JSON.parse(trimmed);
    if (Array.isArray(parsed)) {
      return parsed
        .filter((image): image is string => typeof image === "string")
        .map((image) => image.trim());
    }
  } catch {
    // no-op: fall through to string parsing
  }

  if (trimmed.includes(",")) {
    return trimmed.split(",").map((image) => image.trim()).filter(Boolean);
  }

  return [trimmed];
};

const getUploadedImageUrls = (req: Request): string[] => {
  const files = req.files as Express.Multer.File[] | Record<string, Express.Multer.File[]> | undefined;

  if (!files) {
    return [];
  }

  if (Array.isArray(files)) {
    return files.map((file) => file.path).filter((path): path is string => typeof path === "string" && path.length > 0);
  }

  const testimonyFiles = files.images ?? files.testimonyImages ?? files.testimonyImage ?? [];
  return testimonyFiles
    .map((file) => file.path)
    .filter((path): path is string => typeof path === "string" && path.length > 0);
};

const mergeImageInputs = (bodyImages: string[] | undefined, uploadedImages: string[]): string[] | undefined => {
  if (bodyImages === undefined && uploadedImages.length === 0) {
    return undefined;
  }

  return [...(bodyImages ?? []), ...uploadedImages];
};

export class TestimonyController {
  static async getTestimonies(req: Request, res: Response): Promise<void> {
    try {
      const pageRaw = req.query.page !== undefined ? Number(req.query.page) : undefined;
      const limitRaw = req.query.limit !== undefined ? Number(req.query.limit) : undefined;

      if (pageRaw !== undefined && (!Number.isInteger(pageRaw) || pageRaw < 1)) {
        res.status(400).json({ success: false, message: "page must be a positive integer" });
        return;
      }

      if (limitRaw !== undefined && (!Number.isInteger(limitRaw) || limitRaw < 1 || limitRaw > 100)) {
        res.status(400).json({ success: false, message: "limit must be an integer between 1 and 100" });
        return;
      }

      const page = pageRaw ?? 1;
      const limit = limitRaw ?? 10;

      const { testimonies, total } = await TestimonyService.getAllTestimonies({ page, limit });

      res.status(200).json({
        success: true,
        data: testimonies.map((testimony) => toResponseData(testimony.toObject())),
        pagination: {
          total,
          page,
          limit,
          pages: Math.ceil(total / limit),
        },
      });
    } catch (error) {
      res.status(500).json({ success: false, message: "Failed to fetch testimonies" });
    }
  }

  static async getTestimonyById(req: Request<{ id: string }>, res: Response): Promise<void> {
    try {
      const id = parseIntegerId(req.params.id);
      if (!id) {
        res.status(400).json({ success: false, message: "id must be a positive integer" });
        return;
      }

      const testimony = await TestimonyService.getTestimonyById(id);
      if (!testimony) {
        res.status(404).json({ success: false, message: "Testimony not found" });
        return;
      }

      res.status(200).json({ success: true, data: toResponseData(testimony.toObject()) });
    } catch (error) {
      res.status(500).json({ success: false, message: "Failed to fetch testimony" });
    }
  }

  static async searchTestimonies(req: Request, res: Response): Promise<void> {
    try {
      const q = typeof req.query.q === "string" ? req.query.q.trim() : "";
      const pageRaw = req.query.page !== undefined ? Number(req.query.page) : undefined;
      const limitRaw = req.query.limit !== undefined ? Number(req.query.limit) : undefined;

      if (!q) {
        res.status(400).json({ success: false, message: "q query parameter is required" });
        return;
      }

      if (pageRaw !== undefined && (!Number.isInteger(pageRaw) || pageRaw < 1)) {
        res.status(400).json({ success: false, message: "page must be a positive integer" });
        return;
      }

      if (limitRaw !== undefined && (!Number.isInteger(limitRaw) || limitRaw < 1 || limitRaw > 100)) {
        res.status(400).json({ success: false, message: "limit must be an integer between 1 and 100" });
        return;
      }

      const page = pageRaw ?? 1;
      const limit = limitRaw ?? 10;
      const { testimonies, total } = await TestimonyService.searchTestimonies({ q, page, limit });

      res.status(200).json({
        success: true,
        data: testimonies.map((testimony) => toResponseData(testimony.toObject())),
        pagination: {
          total,
          page,
          limit,
          pages: Math.ceil(total / limit),
        },
      });
    } catch (error) {
      res.status(500).json({ success: false, message: "Failed to search testimonies" });
    }
  }

  static async createTestimony(req: Request, res: Response): Promise<void> {
    try {
      const body = req.body as Record<string, unknown>;
      const input: CreateTestimonyInput = {
        title: getOptionalString(body.title) ?? "",
        verse: getOptionalString(body.verse),
        text_content: getOptionalString(body.text_content) ?? "",
        posted_by: getOptionalString(body.posted_by) ?? "",
        youtube_video_id: getOptionalString(body.youtube_video_id),
      };

      const mergedImages = mergeImageInputs(parseImagesField(body.images), getUploadedImageUrls(req));
      if (mergedImages !== undefined) {
        input.images = mergedImages;
      }

      const validationError = TestimonyValidator.validateCreate(input);

      if (validationError) {
        res.status(400).json({ success: false, message: validationError });
        return;
      }

      const testimony = await TestimonyService.createTestimony(input);
      res.status(201).json({ success: true, data: toResponseData(testimony.toObject()) });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error instanceof Error ? error.message : "Failed to create testimony",
      });
    }
  }

  static async updateTestimony(req: Request<{ id: string }>, res: Response): Promise<void> {
    try {
      const id = parseIntegerId(req.params.id);
      if (!id) {
        res.status(400).json({ success: false, message: "id must be a positive integer" });
        return;
      }

      const body = req.body as Record<string, unknown>;
      const input: UpdateTestimonyInput = {};

      const title = getOptionalString(body.title);
      if (title !== undefined) input.title = title;

      const verse = getOptionalString(body.verse);
      if (verse !== undefined) input.verse = verse;

      const textContent = getOptionalString(body.text_content);
      if (textContent !== undefined) input.text_content = textContent;

      const postedBy = getOptionalString(body.posted_by);
      if (postedBy !== undefined) input.posted_by = postedBy;

      const youtubeVideoId = getOptionalString(body.youtube_video_id);
      if (youtubeVideoId !== undefined) input.youtube_video_id = youtubeVideoId;

      const mergedImages = mergeImageInputs(parseImagesField(body.images), getUploadedImageUrls(req));
      if (mergedImages !== undefined) {
        input.images = mergedImages;
      }

      if (Object.keys(input).length === 0) {
        res.status(400).json({ success: false, message: "At least one field must be provided" });
        return;
      }

      const validationError = TestimonyValidator.validateUpdate(input);
      if (validationError) {
        res.status(400).json({ success: false, message: validationError });
        return;
      }

      const testimony = await TestimonyService.updateTestimony(id, input);
      if (!testimony) {
        res.status(404).json({ success: false, message: "Testimony not found" });
        return;
      }

      res.status(200).json({ success: true, data: toResponseData(testimony.toObject()) });
    } catch (error) {
      res.status(400).json({ success: false, message: "Failed to update testimony" });
    }
  }

  static async deleteTestimony(req: Request<{ id: string }>, res: Response): Promise<void> {
    try {
      const id = parseIntegerId(req.params.id);
      if (!id) {
        res.status(400).json({ success: false, message: "id must be a positive integer" });
        return;
      }

      const deleted = await TestimonyService.deleteTestimony(id);
      if (!deleted) {
        res.status(404).json({ success: false, message: "Testimony not found" });
        return;
      }

      res.status(200).json({ success: true, message: "Testimony deleted successfully" });
    } catch (error) {
      res.status(400).json({ success: false, message: "Failed to delete testimony" });
    }
  }

  static async likeTestimony(req: Request<{ id: string }>, res: Response): Promise<void> {
    try {
      const id = parseIntegerId(req.params.id);
      if (!id) {
        res.status(400).json({ success: false, message: "id must be a positive integer" });
        return;
      }

      if (!req.userId) {
        res.status(401).json({ success: false, message: "Unauthorized" });
        return;
      }

      const testimony = await TestimonyService.likeTestimony(id, req.userId);
      res.status(200).json({ success: true, data: toResponseData(testimony.toObject()) });
    } catch (error) {
      if (error instanceof Error && error.message === "Testimony not found") {
        res.status(404).json({ success: false, message: error.message });
        return;
      }

      if (error instanceof Error && error.message === "Already liked") {
        res.status(409).json({ success: false, message: error.message });
        return;
      }

      res.status(400).json({ success: false, message: "Failed to like testimony" });
    }
  }

  static async unlikeTestimony(req: Request<{ id: string }>, res: Response): Promise<void> {
    try {
      const id = parseIntegerId(req.params.id);
      if (!id) {
        res.status(400).json({ success: false, message: "id must be a positive integer" });
        return;
      }

      if (!req.userId) {
        res.status(401).json({ success: false, message: "Unauthorized" });
        return;
      }

      const testimony = await TestimonyService.unlikeTestimony(id, req.userId);
      res.status(200).json({ success: true, data: toResponseData(testimony.toObject()) });
    } catch (error) {
      if (error instanceof Error && error.message === "Testimony not found") {
        res.status(404).json({ success: false, message: error.message });
        return;
      }

      if (error instanceof Error && error.message === "Not liked yet") {
        res.status(409).json({ success: false, message: error.message });
        return;
      }

      res.status(400).json({ success: false, message: "Failed to unlike testimony" });
    }
  }

  static async commentOnTestimony(req: Request<{ id: string }>, res: Response): Promise<void> {
    try {
      const id = parseIntegerId(req.params.id);
      if (!id) {
        res.status(400).json({ success: false, message: "id must be a positive integer" });
        return;
      }

      if (!req.userId) {
        res.status(401).json({ success: false, message: "Unauthorized" });
        return;
      }

      const validationError = TestimonyValidator.validateCommentText(req.body?.text);
      if (validationError) {
        res.status(400).json({ success: false, message: validationError });
        return;
      }

      const user = await UserService.findByFirebaseId(req.userId);
      const testimony = await TestimonyService.addComment(id, {
        user_id: req.userId,
        posted_by: user?.username ?? "Anonymous",
        text: req.body.text.trim(),
      });

      res.status(201).json({ success: true, data: toResponseData(testimony.toObject()) });
    } catch (error) {
      if (error instanceof Error && error.message === "Testimony not found") {
        res.status(404).json({ success: false, message: error.message });
        return;
      }

      res.status(400).json({ success: false, message: "Failed to post comment" });
    }
  }
}
