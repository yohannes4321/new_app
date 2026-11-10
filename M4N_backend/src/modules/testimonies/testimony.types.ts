import { Document } from "mongoose";

export interface ITestimonyComment {
  user_id: string;
  posted_by: string;
  text: string;
  created_at: Date;
}

export interface ITestimony {
  id: number;
  title: string;
  verse?: string;
  text_content: string;
  images: string[];
  posted_by: string;
  youtube_video_id?: string;
  likes: string[];
  comments: ITestimonyComment[];
  createdAt: Date;
  updatedAt: Date;
}

export interface ITestimonyDocument extends ITestimony, Document {}

export interface CreateTestimonyInput {
  title: string;
  verse?: string;
  text_content: string;
  images?: string[];
  posted_by: string;
  youtube_video_id?: string;
}

export interface UpdateTestimonyInput {
  title?: string;
  verse?: string;
  text_content?: string;
  images?: string[];
  posted_by?: string;
  youtube_video_id?: string;
}
