# Church Backend API

Backend service for church digital content and community features, including authentication, sermons, books, events, testimonies, purchases, and payment flow integration.

## Overview

This project is an Express + TypeScript API using MongoDB for persistence. It supports:

- Firebase-token based authentication
- Admin-gated content management
- Sermon categories and premium sermon access rules
- Book catalog, digital reading access, and purchase library
- Event management and user registration/unregistration
- Testimony publishing, likes, comments, and search
- Payment initialization/verification via Chapa
- Media uploads via Cloudinary

## Tech Stack

- Node.js + TypeScript (ESM)
- Express 5
- MongoDB + Mongoose
- Firebase Admin SDK
- Cloudinary + Multer
- Jest + ts-jest

## Repository Structure

```text
src/
  app.ts                     # Express app + route mounting + error handlers
  server.ts                  # Bootstraps env, DB connection, and HTTP server
  config/                    # DB, env, Firebase, Cloudinary setup
  middlewares/               # Admin checks, upload middleware
  modules/
    auth/
    books/
    events/
    payments/
    purchases/
    sermon/
    testimonies/
    users/

tests/
  event.test.ts              # Example test coverage (events)
```

## Prerequisites

- Node.js 20+
- pnpm 10+
- MongoDB instance
- Firebase service account credentials
- Cloudinary account
- Chapa test key (for payment flow)

## Environment Variables

Create a `.env` file in the project root.

```env
# Server
PORT=5000
BASE_URL=http://localhost:5000

# MongoDB
# Option A: direct URI
MONGODB_URI=mongodb+srv://<user>:<password>@cluster.mongodb.net/church

# Option B: URI template + PASSWORD replacement
# MONGODB_URI=mongodb+srv://<user>:<db_password>@cluster.mongodb.net/church
# PASSWORD=your-db-password
PASSWORD=

# Auth/JWT (JWT is currently not central to auth flow but still configured)
JWT_SECRET=secret-keying
JWT_EXPIRES_IN=7d

# Firebase Admin (recommended)
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account",...}

# Cloudinary
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=

# Payments (Chapa)
CHAPA_TEST_SECRET_KEY=
```

### Firebase Credential Resolution

The app loads Firebase Admin credentials in this order:

1. `FIREBASE_SERVICE_ACCOUNT_JSON` environment variable
2. Fallback file at `serviceAccountKey.json` in repo root

## Installation

```bash
pnpm install
```

## Running the Project

### Development

```bash
pnpm dev
```

### Build

```bash
pnpm build
```

### Production Start

```bash
pnpm start
```

## Testing

```bash
pnpm test
```

Notes:

- Jest is configured for ESM + TypeScript (`ts-jest`).
- Current tests include event controller behavior.

## API Documentation

Detailed endpoint documentation is available in:

- `API_ENDPOINTS.md`

Quick examples:

- Health check: `GET /health`
- Auth base: `/api/auth`
- Sermons base: `/api/sermons`
- Books base: `/api/books`
- Events base: `/api/events`
- Testimonies base: `/api/testimonies`
- Payments base: `/api/payments`
- Purchase library: `/api/purchase/library`

## Auth & Authorization

- Protected endpoints require Firebase ID token:
  - `Authorization: Bearer <firebase_id_token>`
- Admin-restricted routes use role checks from the user record.
- Two admin guards exist in code:
  - `adminOnly` checks `role === "admin"`
  - `adminMiddleware` checks `is_admin === true`

## Uploads & Media

Cloudinary storage is used for uploaded assets:

- Book covers/files
- Sermon cover images/audio

Upload routing is field-based in middleware (`src/middlewares/upload.ts`), so form field names must match route expectations.

## Operational Notes

- The app includes a JSON pre-parser that strips BOM/comments for `application/json` requests.
- Global 404 and error handlers are defined in `src/app.ts`.
- Payment verification redirects to `PAYMENT_RETURN_URL` (with a production fallback).

### Payment identity and mobile policy

- Payment initialization requires Firebase authentication and derives the Chapa customer email/name from the authenticated local profile; client-provided identity fields are ignored.
- Do not expose Chapa checkout or payment instructions in the iOS/Android builds. Those builds are consumption-only and resolve access from the signed-in account.
- Configure `PAYMENT_RETURN_URL` for the web payment-result page and `API_BASE_URL` in Flutter for the cPanel deployment.

## Scripts

- `pnpm dev` - start in watch mode using `tsx`
- `pnpm build` - compile TypeScript to `dist/`
- `pnpm start` - run compiled server
- `pnpm test` - run Jest tests

## License

Currently marked as `ISC` in `package.json`.
