import multer from "multer";
import { CloudinaryStorage } from "multer-storage-cloudinary";
import cloudinary from "../config/cloudinary.js";

const storage = new CloudinaryStorage({
  cloudinary,
  params: async (_, file) => {
    console.log(cloudinary.config());

    try {
      console.log("Uploading file info:", {
        originalname: file?.originalname,
        mimetype: file?.mimetype,
        fieldname: file?.fieldname,
        encoding: file?.encoding,
      });

      const mimetype =
        typeof file?.mimetype === "string" ? file.mimetype : undefined;

      // Determine upload destination by fieldname first, then fall back to mimetype
      const field = file?.fieldname;

      if (field === "cover" || field === "coverImage") {
        return {
          folder: "books/covers",
          resource_type: "image",
        };
      }

      if (field === "file" || field === "book_file" || field === "bookFile") {
        return {
          folder: "books/files",
          resource_type: "image",
          type: "authenticated", // This makes the file private
          format: "pdf",
        };
      }

      if (
        field === "images" ||
        field === "testimonyImage" ||
        field === "testimonyImages"
      ) {
        return {
          folder: "testimonies/images",
          resource_type: "image",
        };
      }

      const isAudio = mimetype ? mimetype.startsWith("audio") : false;

      return {
        folder: isAudio ? "sermons/audio" : "sermons/images",
        resource_type: isAudio ? "auto" : "image",
      };
    } catch (error) {
      console.error("Error determining Cloudinary upload parameters:", error);
      // Ensure we always return a params object so the upload doesn't crash
      return {
        folder: "sermons/misc",
        resource_type: "auto",
      };
    }
  },
});

export const upload = multer({ storage });
