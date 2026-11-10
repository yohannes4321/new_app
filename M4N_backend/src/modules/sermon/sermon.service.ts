import { CategoryModel, SermonModel } from "./sermon.model.js";
import slugify from "slugify";
import { CreateSermonInput } from "./sermon.types.js";
import { UserService } from "../users/user.service.js";
import mongoose from "mongoose";

const slugifyFn = (slugify as any).default ? (slugify as any).default : slugify;

export class SermonService {
  static async getAllCategories() {
    return CategoryModel.find().sort({ name: 1 });
  }

  static async getAllSermonsInCategory(categoryId: string, userId?: string) {
    const categoryObjId = new mongoose.Types.ObjectId(categoryId as string);
    const sermons = await SermonModel.find({ category: categoryObjId }).sort({
      date: -1,
    });
    if (!userId) return sermons;

    const user = await UserService.findByFirebaseId(userId);
    const isPremium =
      user?.premium_until && new Date(user.premium_until) > new Date();

    return sermons.map((sermon) => {
      if (sermon.is_premium && !isPremium) {
        return {
          ...sermon.toObject(),
          audio_file: null,
        };
      }
      return sermon;
    });
  }

  static async create(input: CreateSermonInput) {
    // generate unique slug from title using slugify package
    const base = slugifyFn(input.title || "sermon", {
      lower: true,
      strict: true,
    });
    let slug = base;
    let counter = 0;
    while (await SermonModel.exists({ slug })) {
      counter += 1;
      slug = `${base}-${counter}`;
    }

    return SermonModel.create({
      ...input,
      date: new Date(input.date),
      slug,
    });
  }

  static async createCategory(input: {
    name: string;
    imageUrl: string;
    description?: string;
  }) {
    const existing = await CategoryModel.findOne({
      name: { $regex: `^${input.name}$`, $options: "i" },
    });
    if (existing) throw new Error("Category with that name already exists");

    return CategoryModel.create({
      name: input.name,
      imageUrl: input.imageUrl,
      description: input.description,
    });
  }

  static async updateCategory(
    id: string | string[],
    input: { name?: string; imageUrl?: string; description?: string },
  ) {
    const category = await CategoryModel.findById(id);
    if (!category) throw new Error("Category not found");

    if (input.name && input.name !== category.name) {
      const existing = await CategoryModel.findOne({
        name: { $regex: `^${input.name}$`, $options: "i" },
        _id: { $ne: category._id },
      });
      if (existing) throw new Error("Another category with that name exists");
    }

    if (input.name) category.name = input.name;
    if (input.imageUrl) category.imageUrl = input.imageUrl;
    if (input.description !== undefined)
      category.description = input.description;

    await category.save();
    return category;
  }

  static async getCategoryByName(name: string) {
    let category = await CategoryModel.findOne({
      name: { $regex: `^${name}$`, $options: "i" },
    });

    if (!category) {
      category = await CategoryModel.create({
        name,
        imageUrl:
          "https://res.cloudinary.com/dagim/image/upload/v1700000000/sermons/default_category.png",
        description: `Collection of sermons related to ${name}`,
      });
    }
    return category._id;
  }
  static async deleteCategory(id: string | string[]) {
    const categoryObjId = new mongoose.Types.ObjectId(id as string);

    // Prevent deletion if sermons reference this category
    const inUse = await SermonModel.exists({ category: categoryObjId });
    if (inUse)
      throw new Error("Cannot delete category while sermons reference it");

    const deleted = await CategoryModel.findByIdAndDelete(id);
    if (!deleted) throw new Error("Category not found");
    return deleted;
  }

  static async getSermonById(id: string | string[], userId?: string) {
    let sermon = null as any;
    const idStr = Array.isArray(id) ? id[0] : id;

    // try by ObjectId first
    if (mongoose.Types.ObjectId.isValid(idStr)) {
      sermon = await SermonModel.findById(idStr);
    }

    // fallback to slug lookup
    if (!sermon) {
      sermon = await SermonModel.findOne({ slug: idStr });
    }
    if (!sermon) throw new Error("Sermon not found");

    if (!sermon.is_premium) return sermon;

    if (!userId) throw new Error("Premium content");

    const user = await UserService.findByFirebaseId(userId);
    const isPremium =
      user?.premium_until && new Date(user.premium_until) > new Date();

    if (!isPremium) throw new Error("Subscription required");

    return sermon;
  }

  static async updateSermon(
    slugOrId: string | string[],
    input: Partial<CreateSermonInput>,
    files?: { cover_image?: string; audio_file?: string },
  ) {
    let sermon = null as any;

    sermon = await SermonModel.findOne({ slug: slugOrId });

    if (!sermon) throw new Error("Sermon not found");

    // update fields
    if (input.title) sermon.title = input.title;
    if (input.pastor_name) sermon.pastor_name = input.pastor_name;
    if (input.date) sermon.date = new Date(input.date);
    if (input.category) sermon.category = input.category;
    if (input.is_premium !== undefined) sermon.is_premium = input.is_premium;
    if (files?.cover_image) sermon.cover_image = files.cover_image;
    if (files?.audio_file) sermon.audio_file = files.audio_file;

    // update slug if title changes
    if (input.title && input.title !== sermon.title) {
      const base = slugifyFn(input.title, { lower: true, strict: true });
      let slug = base;
      let counter = 0;
      while (await SermonModel.exists({ slug, _id: { $ne: sermon._id } })) {
        counter += 1;
        slug = `${base}-${counter}`;
      }
      sermon.slug = slug;
    }

    await sermon.save();
    return sermon;
  }

  static async deleteSermon(slugOrId: string | string[]) {
    let sermon = null as any;

    sermon = await SermonModel.findOne({ slug: slugOrId });

    if (!sermon) throw new Error("Sermon not found");
    await SermonModel.deleteOne({ _id: sermon._id });
    return { success: true };
  }
}
