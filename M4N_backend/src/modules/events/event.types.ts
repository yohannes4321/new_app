import { Document, Types } from "mongoose";

export interface IEvent {
	title: string;
	description: string;
	date_time: Date;
	location: string;
	cover_image?: string;
	registration_count: number;
	is_full: boolean;
	allows_registration: boolean;
	createdAt: Date;
	updatedAt: Date;
}

export interface IEventDocument extends IEvent, Document {}

export interface IEventRegistration {
	event_id: Types.ObjectId | string;
	user_id: string;
	createdAt: Date;
	updatedAt: Date;
}

export interface IEventRegistrationDocument extends IEventRegistration, Document {}

export interface CreateEventInput {
	title: string;
	description: string;
	date_time: string; // Received as ISO string from frontend
	location: string;
	cover_image?: string;
	allows_registration?: boolean;
}

export interface UpdateEventInput {
	title?: string;
	description?: string;
	date_time?: string;
	location?: string;
	cover_image?: string;
	allows_registration?: boolean;
	is_full?: boolean;
}
