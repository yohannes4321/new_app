import { Request, Response } from "express";
import PurchaseService from "./purchase.service.js";
import Purchase from "./purchase.model.js";

export const getMyLibrary = async (req: Request, res: Response) => {
  try {
    const userId = req.userId;
    const library = await PurchaseService.getUserLibrary(userId);
    res.json({ success: true, data: library });
  } catch {
    res.status(500).json({ success: false, message: "Failed to load library" });
  }
};

export const getAllPurchases = async (req: Request, res: Response) => {
  try {
    const page = Math.max(1, Number(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, Number(req.query.limit) || 20));
    const skip = (page - 1) * limit;

    const [purchases, total] = await Promise.all([
      Purchase.find()
        .populate("book", "title author price coverImage")
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit),
      Purchase.countDocuments(),
    ]);

    res.json({
      success: true,
      data: purchases,
      pagination: { total, page, limit, pages: Math.ceil(total / limit) },
    });
  } catch {
    res.status(500).json({ success: false, message: "Failed to load purchases" });
  }
};
