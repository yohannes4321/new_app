import { Testimony } from "./testimony.model.js";
import { CreateTestimonyInput, ITestimonyDocument, UpdateTestimonyInput } from "./testimony.types.js";

export class TestimonyService {
  static async createTestimony(input: CreateTestimonyInput): Promise<ITestimonyDocument> {
    const testimony = new Testimony(input);
    return testimony.save();
  }

  static async getAllTestimonies(options: {
    page?: number;
    limit?: number;
  } = {}): Promise<{ testimonies: ITestimonyDocument[]; total: number }> {
    const { page = 1, limit = 10 } = options;
    const skip = (page - 1) * limit;

    const [testimonies, total] = await Promise.all([
      Testimony.find({}).sort({ createdAt: -1 }).skip(skip).limit(limit),
      Testimony.countDocuments({}),
    ]);

    return { testimonies, total };
  }

  static async getTestimonyById(id: number): Promise<ITestimonyDocument | null> {
    return Testimony.findOne({ id });
  }

  static async searchTestimonies(options: {
    q: string;
    page?: number;
    limit?: number;
  }): Promise<{ testimonies: ITestimonyDocument[]; total: number }> {
    const { q, page = 1, limit = 10 } = options;
    const skip = (page - 1) * limit;

    const searchRegex = new RegExp(q.trim(), "i");
    const query = {
      $or: [
        { title: searchRegex },
        { verse: searchRegex },
        { text_content: searchRegex },
        { posted_by: searchRegex },
      ],
    };

    const [testimonies, total] = await Promise.all([
      Testimony.find(query).sort({ createdAt: -1 }).skip(skip).limit(limit),
      Testimony.countDocuments(query),
    ]);

    return { testimonies, total };
  }

  static async updateTestimony(id: number, input: UpdateTestimonyInput): Promise<ITestimonyDocument | null> {
    return Testimony.findOneAndUpdate({ id }, input, {
      new: true,
      runValidators: true,
    });
  }

  static async deleteTestimony(id: number): Promise<boolean> {
    const deleted = await Testimony.findOneAndDelete({ id });
    return !!deleted;
  }

  static async likeTestimony(id: number, userId: string): Promise<ITestimonyDocument> {
    const testimony = await Testimony.findOneAndUpdate(
      { id, likes: { $ne: userId } },
      { $addToSet: { likes: userId } },
      { new: true },
    );

    if (testimony) return testimony;

    const existing = await Testimony.findOne({ id });
    if (!existing) throw new Error("Testimony not found");
    throw new Error("Already liked");
  }

  static async unlikeTestimony(id: number, userId: string): Promise<ITestimonyDocument> {
    const testimony = await Testimony.findOneAndUpdate(
      { id, likes: userId },
      { $pull: { likes: userId } },
      { new: true },
    );

    if (testimony) return testimony;

    const existing = await Testimony.findOne({ id });
    if (!existing) throw new Error("Testimony not found");
    throw new Error("Not liked yet");
  }

  static async addComment(
    id: number,
    input: { user_id: string; posted_by: string; text: string },
  ): Promise<ITestimonyDocument> {
    const testimony = await Testimony.findOneAndUpdate(
      { id },
      {
        $push: {
          comments: {
            user_id: input.user_id,
            posted_by: input.posted_by,
            text: input.text,
            created_at: new Date(),
          },
        },
      },
      { new: true },
    );

    if (!testimony) {
      throw new Error("Testimony not found");
    }

    return testimony;
  }
}
