// This file can be used for request validation schemas
// Using a validation library like Zod or Joi in the future
// For now, validation is handled in the controller

export const authSchemas = {
    register: {
        required: ['username', 'email', 'password', 'phone_number'],
        optional: ['profile_image'],
    },
    login: {
        required: ['email', 'password'],
    },
    updateProfile: {
        optional: ['username', 'profile_image', 'phone_number'],
    },
};
