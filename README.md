# E-Commerce Sales & Customer Analytics (SQL)

This is a small SQL project I built to practice working with a realistic e-commerce database — customers, products, orders, and order items — and to write queries that actually answer business questions instead of just pulling raw rows.

## What this is about

I wanted to go beyond basic SELECT statements and get comfortable with joins, CTEs, and window functions, so I set up a mini e-commerce schema and wrote a set of queries on top of it covering revenue, category performance, and customer value. It's not meant to be a production system — just a clean, working example of how I think about SQL analytics.

## Tech Stack

- MySQL (the script uses `DATE_FORMAT`, CTEs, and window functions, so MySQL 8.0+ is needed)

## Database Schema

| Table | Description |
|---|---|
| `customers` | Customer details — name, email, city, state, signup date |
| `products` | Product catalog — name, category, price, stock |
| `orders` | Order header — customer, date, payment method, status |
| `order_items` | Line items per order — product, quantity, price |

**Relationships:**
- `orders.customer_id` → `customers.customer_id`
- `order_items.order_id` → `orders.order_id`
- `order_items.product_id` → `products.product_id`

## Sample Data

The script seeds the database with 5 customers, 5 products, 8 orders, and 9 order items, covering categories like Electronics, Footwear, Accessories, and Appliances.

## What the Queries Do

Here's a rundown of the analysis included in the script, more or less in the order they appear:

1. **Total orders & revenue** – a quick top-line check on how many orders came in and how much money the store made overall.
2. **Revenue by category** – breaks down units sold and revenue per product category, so you can see what's actually driving sales.
3. **Top 3 customers by spend** – a simple ranking of who's spending the most, joined across customers, orders, and order items.
4. **Customer ranking with DENSE_RANK()** – similar to the above, but using a window function to rank every customer by total spend (cancelled orders excluded).
5. **Running revenue total by month** – uses a window function to show how revenue accumulates month over month.
6. **Month-over-month growth %** – compares each month's revenue to the previous one using `LAG()`, so you can see whether the business is growing or slowing down.
7. **A reporting view** – `business_performance_summary` joins everything (orders, customers, products, order items) into one flat view, so you don't have to rewrite the same joins every time you want to pull a report.

## Running It

1. Open up any MySQL client — Workbench, the `mysql` CLI, DBeaver, whatever you're comfortable with.
2. Run the whole script. It'll create the database, set up the tables, load in the sample data, run through the queries, and finish by creating the view.

```bash
mysql -u <username> -p < ecommerce_analytics.sql
```

3. Once that's done, you can just query the view whenever you want a quick report:

```sql
SELECT * FROM business_performance_summary;
```

## License

Free to use for learning, practice, or whatever else — no restrictions.
