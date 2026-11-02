# 🛒 Dotmarket Backend

The REST API behind **[Dotmarket](https://github.com/dotcomico/dotmarket)**, a full-stack supermarket e-commerce app. It handles products, categories, orders, users and login.

![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-3.1-000000?logo=flask&logoColor=white)
![SQLAlchemy](https://img.shields.io/badge/SQLAlchemy-2.0-D71F00?logo=sqlalchemy&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-database-07405E?logo=sqlite&logoColor=white)

> [!NOTE]
> This is one of four repos that make up Dotmarket. For the overview, screenshots and full setup, start with the **[main repo](https://github.com/dotcomico/dotmarket)**.

## 🚀 Getting Started

**You need:** Python 3.11+

```bash
git clone https://github.com/dotcomico/dotmarket-server.git backend
cd backend

python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate

pip install -r requirements.txt
cp .env.example .env            # Windows: copy .env.example .env
python seed_database.py         # Fills the database with test data
python -m src.main
```

The API runs at http://localhost:3000. Check that it works by logging in:

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"admin@test.com\", \"password\": \"Test123!\"}"
```

You should get back a `token` and a `user`.

> [!IMPORTANT]
> Don't skip creating `.env`. Without a `JWT_SECRET`, the server starts normally but every login fails with a 500 error.

### Test accounts

All passwords are `Test123!`.

| Role | Email |
|---|---|
| Admin | `admin@test.com` |
| Manager | `manager@test.com` |
| Customer | `customer@test.com` |

See [README_SEED.md](README_SEED.md) for everything the seed script creates.

## 🧱 How It Works

Each request passes through three layers, so business rules live in one place:

```
Route (src/routes)      Reads the HTTP request and shapes the response
   ↓
Service (src/services)  Holds the business rules and validation
   ↓
Model (src/models)      Maps to the database through SQLAlchemy
```

- **Login:** users get a JWT. The `@auth` decorator checks who is calling, and `@checkRole` checks what they're allowed to do.
- **Passwords:** stored as salted bcrypt hashes.
- **Checkout:** one transaction checks stock on every item, records each item's price at purchase, and reduces stock.
- **Rate limiting:** Flask-Limiter allows 100 requests per 15 minutes per client, or 1000 in development.

## 🔗 API Endpoints

Routes marked (admin) or (admin/manager) need a token for that role. Send it as `Authorization: Bearer <token>`.

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register user |
| POST | `/api/auth/login` | Login user |
| GET | `/api/auth/me` | Get current user |

### Products
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/products` | Get all products (paginated) |
| GET | `/api/products/:id` | Get product by ID |
| GET | `/api/products/stats` | Inventory aggregates for the admin dashboard (admin/manager) |
| POST | `/api/products` | Create product (admin/manager) |
| PUT | `/api/products/:id` | Update product (admin/manager) |
| DELETE | `/api/products/:id` | Delete product (admin) |

`GET /api/products` accepts `page`, `limit` (100 at most), `search`, `categoryId`, `minPrice` and `maxPrice`.

`GET /api/products/stats` returns `totalProducts`, `lowStockCount`, `outOfStockCount`, `inventoryValue`, `lowStockThreshold` and `lowStockProducts` (the 5 lowest-stock rows, each `{ id, name, stock, price }`). All of it is computed in SQL over the whole catalogue, so clients shouldn't re-derive it from a paginated page.

### Categories
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/categories` | Get all categories (flat) |
| GET | `/api/categories/tree` | Get the nested category tree |
| GET | `/api/categories/:slug` | Get one category by slug, with breadcrumbs |
| GET | `/api/categories/:slug/products` | Get a category's products |
| POST | `/api/categories` | Create category (admin/manager) |
| GET | `/api/categories/:id` | Get category by numeric ID (admin/manager) |
| PUT | `/api/categories/:id` | Update category (admin/manager) |
| DELETE | `/api/categories/:id` | Delete category (admin) |

The numeric-ID routes win over `/:slug`, so `/api/categories/:slug` only resolves for non-numeric slugs. All seeded slugs are non-numeric.

### Orders
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/orders` | **All** orders for admin/manager; returns `[]` for a customer |
| GET | `/api/orders/privet` | The logged-in user's own orders (see note) |
| GET | `/api/orders/:id` | Get one order (owner, or any admin/manager) |
| POST | `/api/orders` | Create order (checkout) |
| PUT | `/api/orders/:id` | Update status (admin/manager) |
| DELETE | `/api/orders/:id` | Delete order (admin) |

`/orders/privet` is a typo for "private" that shipped as the real route name. The customer "My Orders" screen calls it, so renaming it would break the frontend.

### Users
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users/profile` | Get the logged-in user's own profile |
| GET | `/api/users` | Get all users (admin, each with `ordersCount` and `totalSpent`) |
| PUT | `/api/users/:id/role` | Update role (admin) |

There is no `DELETE /api/users/:id`, because user deletion isn't implemented.

## ⚙️ Environment Variables

Set these in `.env`. The values in `.env.example` are for local development, so use your own `JWT_SECRET` anywhere else.

| Variable | Description | Default |
|----------|-------------|---------|
| `JWT_SECRET` | Key used to sign login tokens | **Required** |
| `PORT` | Server port | `3000` |
| `DB_STORAGE` | Database file path | `./database.sqlite` |
| `NODE_ENV` | `development` turns on Flask debug mode and the higher rate limit | Not set |
| `RATE_LIMIT` | Overrides the rate limit, such as `500 per 15 minutes` | Set by `NODE_ENV` |

## 📁 Project Structure

```
backend/
├── src/
│   ├── config/         # Database setup and constants
│   ├── middleware/     # Login check, role check, file uploads
│   ├── models/         # Database models
│   ├── routes/         # API routes
│   ├── services/       # Business logic
│   ├── utils/          # Shared helpers and error handling
│   └── main.py         # Entry point
├── public/uploads/     # Product images
├── seed_database.py    # Creates the test data
└── requirements.txt
```

## 🐳 Docker

To run only the backend, build the image from this folder. It comes with the test data already seeded.

```bash
docker build -t dotmarket-backend .
docker run -p 3000:3000 -e JWT_SECRET=choose-your-own-secret dotmarket-backend
```

To run the full app, follow the [Quick Start](https://github.com/dotcomico/dotmarket/blob/main/docs/QUICK_START.md).

## 🛠️ Troubleshooting

**`UnicodeEncodeError` when starting on Windows:** the startup log prints emoji that some Windows terminals can't encode. Run this in PowerShell, then start the server again:

```powershell
$env:PYTHONIOENCODING="utf-8"
```

## 🔗 Related Repos

| Repo | Role |
|---|---|
| [`dotmarket`](https://github.com/dotcomico/dotmarket) | Overview, docs and Docker Compose |
| [`dotmarket-client`](https://github.com/dotcomico/dotmarket-client) | Storefront and admin UI |
| [`dotmarket-mcp-server`](https://github.com/dotcomico/dotmarket-mcp-server) | Exposes this API as tools for AI models |
| [`dotmarket-ai-server`](https://github.com/dotcomico/dotmarket-ai-server) | Chat assistant |

## 📄 License

[MIT](LICENSE)
