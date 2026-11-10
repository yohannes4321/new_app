# Church Backend API Endpoints

This document describes all currently mounted HTTP endpoints in this repository and how to use them.

## Base Notes

- Base API prefix: `/api`
- Health endpoint: `GET /health`
- Auth scheme for protected endpoints: `Authorization: Bearer <firebase_id_token>`
- Default response style is JSON with `success`, `message`, and/or `data`
- If route does not exist: `404` with `{ success: false, message: "Route <METHOD> <URL> not found" }`

## Auth & Role Rules

- `authMiddleware`: requires a Firebase ID token in `Authorization` header.
- `adminOnly` (some modules): allows users where DB `role === "admin"`.
- `adminMiddleware` (events module): allows users where DB `is_admin === true`.

## 1) Health

### `GET /health`

Basic service health check.

Example:

```bash
curl -X GET http://https://church-backend-s1rb.onrender.com/health
```

---

## 2) Auth (`/api/auth`)

### `POST /api/auth/register`

Register a local user record.

Body (JSON):

- `username` (string, required)
- `email` (string, required)
- `password` (string, required)
- `phone_number` (string, required)
- `profile_image` (string, optional)
- `role` can be sent by type, but should not be used by clients.

Example:

```bash
curl -X POST http://https://church-backend-s1rb.onrender.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john",
    "email": "john@example.com",
    "password": "secret123",
    "phone_number": "+251900000000"
  }'
```

### `POST /api/auth/session`

Verifies Firebase ID token and returns user profile from local DB.

Body (JSON):

- `idToken` (string, required)

Example:

```bash
curl -X POST http://https://church-backend-s1rb.onrender.com/api/auth/session \
  -H "Content-Type: application/json" \
  -d '{ "idToken": "<firebase_id_token>" }'
```

### `GET /api/auth/profile` (Protected)

Returns current user profile.

### `PUT /api/auth/profile` (Protected)

Update only allowed fields:

- `username` (optional)
- `profile_image` (optional)
- `phone_number` (optional)

### `GET /api/auth/stats` (Protected)

Returns:

- `total_donations`
- `is_premium`
- `events_registered` (currently placeholder)

Example protected call:

```bash
curl -X GET http://https://church-backend-s1rb.onrender.com/api/auth/profile \
  -H "Authorization: Bearer <firebase_id_token>"
```

---

## 3) Sermons (`/api/sermons`)

### Category Endpoints

### `GET /api/sermons/categories` (Protected)

List categories.

### `POST /api/sermons/categories` (Protected + Admin)

`multipart/form-data`

- `name` (required)
- `description` (optional)
- `image` file (required)

### `PUT /api/sermons/categories/:id` (Protected + Admin)

`multipart/form-data`

- Any of: `name`, `description`, `image`

### `DELETE /api/sermons/categories/:id` (Protected + Admin)

Fails if sermons still reference the category.

### Sermon Endpoints

### `GET /api/sermons?categoryId=<mongoObjectId>` (Protected)

Required query:

- `categoryId`

### `GET /api/sermons/:slug` (Protected)

Fetch sermon by slug (or ObjectId fallback).
Premium sermons require active premium user.

### `POST /api/sermons/create` (Protected + Admin)

`multipart/form-data`

- `title` (required)
- `pastor_name` (required)
- `date` (required, date string)
- `category` (required, category name; service resolves/creates category)
- `is_premium` (required boolean-like field)
- `cover_image` file (required)
- `audio_file` file (optional)

### `PUT /api/sermons/update/:slug` (Protected + Admin)

`multipart/form-data`

- Any sermon fields to update
- Optional files: `cover_image`, `audio_file`

### `DELETE /api/sermons/delete/:slug` (Protected + Admin)

Delete sermon by slug.

---

## 4) Books (`/api/books`)

### Public

### `GET /api/books`

List books for store.

### `GET /api/books/:id`

Book details (excludes `fileUrl`).

### Protected

### `GET /api/books/:id/read` (Protected)

Checks if user purchased the book, then returns a signed read URL.
Returns `403` if not purchased.

### Admin

### `POST /api/books/create` (Protected + Admin)

`multipart/form-data`

- Files: `coverImage` (required), `file` (required)
- Plus book fields in body (title/author/price/category/description, etc.)

### `PUT /api/books/update/:id` (Protected + Admin)

`multipart/form-data`

- Any updatable fields
- Optional files: `coverImage`, `file`

### `DELETE /api/books/delete/:id` (Protected + Admin)

Delete a book.

Example create:

```bash
curl -X POST http://https://church-backend-s1rb.onrender.com/api/books/create \
  -H "Authorization: Bearer <firebase_id_token>" \
  -F "title=Sample Book" \
  -F "author=Author Name" \
  -F "price=100" \
  -F "category=Faith" \
  -F "description=Book description" \
  -F "coverImage=@./cover.jpg" \
  -F "file=@./book.pdf"
```

---

## 5) Payments (`/api/payments`)

### `POST /api/payments/initialize`

Creates Chapa checkout and stores pending purchase.

Body (JSON):

- `email` (required)
- `firstName` (required)
- `lastName` (required)
- `userId` (required)
- `bookId` (required)

Response:

- `{ checkoutUrl: "..." }`

### `GET /api/payments/verify/:tx_ref`

Verifies payment and redirects browser:

- success: redirects to Google search `payment success`
- failure: redirects to Google search `payment failed`

Example initialize:

```bash
curl -X POST http://https://church-backend-s1rb.onrender.com/api/payments/initialize \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "userId": "firebase-uid",
    "bookId": "<book_mongo_id>"
  }'
```

---

## 6) Purchases (`/api/purchase`)

Note: mounted path is singular `purchase` (not `purchases`).

### `GET /api/purchase/library` (Protected)

Returns authenticated user library (completed purchases with populated book info).

Example:

```bash
curl -X GET http://https://church-backend-s1rb.onrender.com/api/purchase/library \
  -H "Authorization: Bearer <firebase_id_token>"
```

---

## 7) Events (`/api/events`)

### Public

### `GET /api/events`

Query params:

- `page` (optional, positive integer, default `1`)
- `limit` (optional, `1-100`, default `10`)
- `upcoming` (optional, `true|false`)

Returns paginated events and `pagination` object.

### `GET /api/events/:id`

Get single event by MongoDB id.

### Admin

### `POST /api/events` (Protected + Admin via `is_admin`)

Body:

- `title` (required, min 3 chars)
- `description` (required)
- `date_time` (required, ISO date string)
- `location` (required)
- `cover_image` (optional string)
- `allows_registration` (optional boolean)

### `PUT /api/events/:id` (Protected + Admin)

Any update fields:

- `title`, `description`, `date_time`, `location`, `cover_image`, `allows_registration`, `is_full`

### `DELETE /api/events/:id` (Protected + Admin)

Delete event.

### User Registration

### `POST /api/events/:id/register` (Protected)

Registers current user for event.
Can return `409` for already registered/full/registration not allowed.

### `DELETE /api/events/:id/unregister` (Protected)

Unregister current user.
Can return `409` if not registered.

Example:

```bash
curl -X POST http://https://church-backend-s1rb.onrender.com/api/events/<event_id>/register \
  -H "Authorization: Bearer <firebase_id_token>"
```

---

## 8) Testimonies (`/api/testimonies`)

### Public

### `GET /api/testimonies`

Query params:

- `page` (optional, positive integer, default `1`)
- `limit` (optional, `1-100`, default `10`)

### `GET /api/testimonies/search?q=<term>`

Required query:

- `q` (non-empty)
  Optional:
- `page`, `limit`

### `GET /api/testimonies/:id`

`:id` must be positive integer.

### Authenticated

### `POST /api/testimonies/:id/like` (Protected)

Like testimony.

### `DELETE /api/testimonies/:id/like` (Protected)

Unlike testimony.

### `POST /api/testimonies/:id/comment` (Protected)

Body:

- `text` (required, 1..1000 chars)

### Admin

### `POST /api/testimonies` (Protected + Admin)

Body:

- `title` (required, min 3)
- `text_content` (required, min 10)
- `posted_by` (required)
- `verse` (optional)
- `images` (optional `string[]`)
- `youtube_video_id` (optional)

### `PUT /api/testimonies/:id` (Protected + Admin)

Same fields as create, all optional. At least one field required.

### `DELETE /api/testimonies/:id` (Protected + Admin)

Delete testimony.

Example create:

```bash
curl -X POST http://https://church-backend-s1rb.onrender.com/api/testimonies \
  -H "Authorization: Bearer <firebase_id_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "God answered my prayer",
    "text_content": "I prayed and received help in a difficult season.",
    "posted_by": "John"
  }'
```

---

## Quick Error Reference

- `400`: validation or malformed input
- `401`: missing/invalid auth token
- `403`: forbidden (admin or purchase requirement not met)
- `404`: not found
- `409`: conflict (duplicate like/register states, event state)
- `500`: server/internal failure
