import { Request, Response } from "express";
import { SermonService } from "./sermon.service.js";

export class SermonController {
  /**
   * GET /categories
   * Phase 1 loading
   */
  static async getAllCategories(req: Request, res: Response) {
    const categories = await SermonService.getAllCategories();

    if (categories.length === 0) {
      return res
        .status(404)
        .json({ success: false, message: "No categories found" });
    }
    res.status(200).json({ success: true, data: categories });
    return;
  }

  /**
   * POST /categories (admin only)
   */
  static async createCategory(req: Request, res: Response) {
    try {
      const file = req.file as Express.Multer.File | undefined;
      const { name, description } = req.body;

      if (!name || !file) {
        return res
          .status(400)
          .json({ success: false, message: "Name and image are required" });
      }

      const category = await SermonService.createCategory({
        name,
        imageUrl: file.path,
        description,
      });

      res.status(201).json({ success: true, data: category });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error instanceof Error ? error.message : "Failed to create",
      });
    }
  }

  /**
   * PUT /categories/:id (admin only)
   */
  static async updateCategory(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const file = req.file as Express.Multer.File | undefined;
      const { name, description } = req.body;

      const updatePayload: any = {};
      if (name) updatePayload.name = name;
      if (description !== undefined) updatePayload.description = description;
      if (file) updatePayload.imageUrl = file.path;

      const category = await SermonService.updateCategory(id, updatePayload);
      res.json({ success: true, data: category });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error instanceof Error ? error.message : "Failed to update",
      });
    }
  }

  /**
   * DELETE /categories/:id (admin only)
   */
  static async deleteCategory(req: Request, res: Response) {
    try {
      const { id } = req.params;
      await SermonService.deleteCategory(id);
      res.json({ success: true, message: "Category deleted" });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error instanceof Error ? error.message : "Failed to delete",
      });
    }
  }
  /**
   * POST /sermons (admin only)
   */
  static async create(req: Request, res: Response) {
    console.log("Creating sermon with data:", req.body);
    try {
      const files = req.files as {
        cover_image?: Express.Multer.File[];
        audio_file?: Express.Multer.File[];
      };

      if (!files?.cover_image) {
        res.status(400).json({
          success: false,
          message: "Cover image is required",
        });
        return;
      }
      const catagoryId = await SermonService.getCategoryByName(
        req.body.category,
      );
      req.body.category = catagoryId;

      const sermonData = {
        ...req.body,
        cover_image: files.cover_image[0].path,
        audio_file: files.audio_file ? files.audio_file[0].path : undefined,
      };

      const sermon = await SermonService.create(sermonData);

      res.status(201).json({
        success: true,
        data: sermon,
      });
    } catch (error) {
      console.error("Error creating sermon:", error);
      res.status(400).json({
        success: false,
        message: error instanceof Error ? error.message : "Failed",
      });
    }
  }

  /**
   * GET /sermons
   */
  static async getAllSermonsInCatagory(req: Request, res: Response) {
    const categoryId = req.query.categoryId as string | undefined;

    if (!categoryId) {
      return res
        .status(400)
        .json({ success: false, message: "Category ID is required" });
    }

    try {
      const sermons = await SermonService.getAllSermonsInCategory(
        categoryId,
        req.userId,
      );
      res.json({ success: true, data: sermons });
    } catch (error) {
      res.status(500).json({ success: false });
    }
  }

  /**
   * GET /sermons/:id
   */
  static async getOneSermon(req: Request, res: Response) {
    try {
      const { slug } = req.params;
      const sermon = await SermonService.getSermonById(slug, req.userId);

      res.json({ success: true, data: sermon });
    } catch (error) {
      res.status(403).json({
        success: false,
        message: error instanceof Error ? error.message : "Access denied",
      });
    }
  }

  /**
   * PUT /sermons/:slug (admin only)
   */
  static async updateSermon(req: Request, res: Response) {
    try {
      const { slug } = req.params;
      const files = req.files as {
        cover_image?: Express.Multer.File[];
        audio_file?: Express.Multer.File[];
      };
      const filePaths: any = {};
      if (files?.cover_image) filePaths.cover_image = files.cover_image[0].path;
      if (files?.audio_file) filePaths.audio_file = files.audio_file[0].path;
      const updated = await SermonService.updateSermon(
        slug,
        req.body,
        filePaths,
      );
      res.json({ success: true, data: updated });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error instanceof Error ? error.message : "Failed to update",
      });
    }
  }

  /**
   * DELETE /sermons/:slug (admin only)
   */
  static async deleteSermon(req: Request, res: Response) {
    try {
      const { slug } = req.params;
      await SermonService.deleteSermon(slug);
      res.json({ success: true, message: "Sermon deleted" });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error instanceof Error ? error.message : "Failed to delete",
      });
    }
  }
}
