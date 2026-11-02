# 🛒 Dotmarket Database Seed

Fills the backend database with realistic test data, so the storefront and admin dashboard have something to show.

## 🚀 Quick Start

Finish the setup steps in the [README](README.md#-getting-started) first, then run these from the `backend` folder:

```bash
python seed_database.py
python -m src.main
```

## 🔐 Test User Credentials

| Role     | Email              | Password  |
|----------|-------------------|-----------|
| Admin    | admin@test.com    | Test123!  |
| Manager  | manager@test.com  | Test123!  |
| Customer | customer@test.com | Test123!  |

The seed also creates 5 more customers (such as `priya.patel@test.com`) with the same password, so the admin tables have realistic data.

## 📊 What's Included

### Categories (60 total)
- **12 Parent Categories**: Fruits & Veg, Meat, Fish, Dairy, Bakery, Pantry, Snacks, Beverages, Frozen, Household, Personal Care, Electronics
- **48 Subcategories**: Organized under parents with proper hierarchy

### Products (108 total)
- **50 products with images**
- **58 products without images** (will use placeholders)
- Every subcategory has at least one product
- Add new products at the end of `PRODUCTS`: seeded orders reference products by list index
- Various stock levels for dashboard testing:
  - Low stock (≤5 units): 4 products
  - Out of stock (0 units): 2 products

### Orders (15 total)
5 orders belong to the Customer test user and 10 to the other seeded customers, spread over the last ~30 days:
- **6 Shipped** - completed orders
- **4 Paid** - processing
- **3 Pending** - awaiting payment
- **2 Cancelled** - for testing cancellation flow

## ⚠️ Dashboard Test Scenarios

The seed data is designed to show various states in your admin dashboard:

1. **Low Stock Alert**: Products like "Red Bell Peppers", "Organic Brown Eggs", "Toilet Paper" have stock ≤ 5
2. **Out of Stock**: "Energy Boost" energy drink and "Sunrise Farms Organic Brown Eggs" have 0 stock
3. **Order Management**: Orders in all status states
4. **High-value Products**: Electronics category has items up to $1250

## 🔄 Re-seeding

To reset your database with fresh data, run the script again. It clears all existing data first:

```bash
python seed_database.py
```

## 💡 Notes

- The script hashes passwords with `bcrypt`
- Product and order `createdAt` dates are set by the script and spread out, so "New arrivals" and the order tables look realistic
- Product images are served from `/uploads/`
- Products without images have `null` for `image` - the frontend shows a placeholder
