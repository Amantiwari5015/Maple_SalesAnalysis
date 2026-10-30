# Maple & Co. – Project Notes

Practice project: simulated Upwork client brief ("Sarah", Maple & Co. Home Goods).
Budget $150 fixed · 5-day deadline · Tools: Python (pandas), SQL (SQLite), Power BI.

---

## 1. Client brief

**Decision the client is making:** which products, channels and regions deserve more investment in 2026, and what to fix or cut.

**Client questions**
1. Total revenue and profit in 2025 (excluding cancelled and test orders)
2. Monthly trend: how much bigger were the holidays?
3. Most profitable categories and products
4. Best sales channel (Amazon and Etsy charge fees)
5. Strongest and weakest regions
6. Which category gets returned most
7. Are discounts helping?
8. Repeat customers vs one-time buyers

**KPIs requested:** Total Revenue, Gross Profit, Profit Margin %, Total Orders, AOV, Return Rate %, Repeat Customer %, Avg Rating
**Filters requested:** Month, Category, Sales Channel, Region

**Formulas given by client**
- Revenue = Quantity × Unit Price × (1 − Discount %) (shipping not included)
- Profit = Revenue − (Quantity × Unit Cost)

---

## 2. Dataset overview

| File | Rows | Columns | Notes |
|---|---|---|---|
| maple_orders_2025.csv | 4,034 | 13 | One row per order, Jan–Dec 2025 |
| maple_products.csv | 19 | 5 | Product lookup: name, category, price, cost |

Join key: `Product_ID` (every order matched a product).

---

## 3. Client decisions (asked before cleaning)

- Quantity 0 or −1 → entry mistakes, **remove**
- Quantity 200 → typo, **change to 2**
- Rating 6 → invalid, **set to blank**
- Missing cost for Framed Botanical Print (P115) → **$27.00**
- Missing region / payment method → **"Unknown"**, keep the order
- Returned and Cancelled orders → **excluded from revenue and profit**, kept for return rate

---

## 4. Cleaning log

| Step | File | Column | Issue | Action | Rows affected |
|---|---|---|---|---|---|
| 1 | Orders | all | Column names had capitals and "%" | Renamed to lowercase (`discount_pct`) | All columns |
| 2 | Orders | customer_id | Test orders ("TEST") | Removed | 9 |
| 3 | Orders | customer_id | Lowercase IDs / trailing spaces | Strip + uppercase | 40 |
| 4 | Orders | region | 7 spelling variants (NE, North East, west, Mid West, South-East…) | Standardised to 5 regions | 253 |
| 5 | Orders | region | Blank | Filled "Unknown" (client) | 80 |
| 6 | Orders | sales_channel | Variants (website, Web, instagram, IG) | Standardised to 4 channels | 157 |
| 7 | Orders | payment_method | Blank | Filled "Unknown" (client) | 122 |
| 8 | Orders | order_date | 3 formats (YYYY-MM-DD, MM/DD/YYYY, DD-Mon-YYYY) | Converted to one date type | 1,308 non-standard |
| 9 | Orders | unit_price | Stored as text with "$" | Removed "$", converted to number | 604 |
| 10 | Orders | quantity | Typo 200 | Changed to 2 (client) | 3 |
| 11 | Orders | quantity | Zero or negative | Removed (client) | 22 |
| 12 | Orders | customer_rating | Invalid value 6 | Set to blank (client) | 40 |
| 13 | Orders | all | Exact duplicate rows | Removed (after text cleaning) | 130 |
| 14 | Orders | order_id | Repeated order IDs | Kept first, removed rest | 5 |
| 15 | Products | category | "candles", "Kitchen " | Strip + title case | 2 |
| 16 | Products | unit_cost | Missing for P115 | Filled $27.00 (client) | 1 |
| 17 | Both | — | Two separate files | Merged on product_id (left join) | Row count unchanged |
| 18 | Orders | new | No revenue/profit columns | Added revenue, total_cost, profit, month, month_name | All |

**Result:** 4,034 raw rows → **3,868 clean rows** (3,459 Delivered · 253 Returned · 156 Cancelled).
Ratings left blank on purpose: 637 orders (customers who didn't rate).

**Lesson learned:** remove duplicates *after* cleaning text. Before cleaning, "C1234" and "c1234 " look like different rows.

---

## 5. Findings (SQL, delivered orders only)

| # | Question | Finding | Meaning | Recommendation |
|---|---|---|---|---|
| 1 | Revenue & profit | $218,550 revenue · $110,607 profit · 50.6% margin · 3,459 orders · AOV $63.18 | Healthy margin for a small brand | Track monthly against this baseline |
| 2 | Monthly trend | Dec $36.7K = 2.0× monthly average; Nov + Dec = 29% of the year; Feb lowest ($9.2K) | Business depends heavily on Q4 | Order holiday stock by September |
| 3 | Categories / products | Bedding top profit ($28.6K) but 44.1% margin; Candles best margin (64.7%); top product Waffle Throw Blanket ($9.3K profit) | Highest revenue ≠ best margin | Push Candles as add-ons and gift sets |
| 4 | Channels | Website 45% of revenue; Etsy 21%, Instagram 20%, Amazon 15%; AOV $62–65 on all | Website is the core; marketplace fees not in data | Grow the website; check Amazon/Etsy fees |
| 5 | Regions | Northeast 26%, West 25%, Southeast 20%, Midwest 17%, Southwest 10%, Unknown 2% | Coasts lead | Test regional ads in the Southwest |
| 6 | Returns | Bedding 13.4% vs 4.7–5.5% for others; overall 6.8% | Bedding has a product or description problem | Add size charts and fabric photos, check return reasons |
| 7 | Discounts | Margin 53.0% at 0% → 39.1% at 25%; AOV $66.97 → $40.64 | Discounts don't grow basket size | Cap regular discounts at 10% |
| 8 | Repeat customers | 669 of 1,076 customers (62.2%) ordered 2+ times | Strong loyalty base | Loyalty email / second-order offer |

**Limitations:** no marketplace or ad costs, only one year of data, 17% of orders unrated, no return reasons recorded.

---

## 6. Dashboard (Power BI)

File: `04_dashboard/maple_sales_dashboard.pbix` · canvas 1280 × 720 · custom theme (navy #1F3A5F)

- **Page 1 – Overview:** title, 4 slicers, KPI card (7 values), monthly revenue line, profit by category, revenue by channel, revenue by region
- **Page 2 – Deep Dive:** return rate by category, discount combo chart (orders + margin), repeat-customer donut (calculated table `Customer Segments`), products table sorted by profit, category × channel matrix

**DAX measures:** Total Revenue, Total Profit, Total Orders, Profit Margin %, AOV, Return Rate %, Avg Rating, Repeat Customer %

**Still to do**
- [ ] Top N = 10 filter on the products table
- [ ] Heatmap (Cell elements → Background color) on the matrix
- [ ] Sync slicers across both pages
- [ ] Total Orders card shows "3K"; set display units to None
- [ ] Region chart scrollbar; turn off X-axis so all 6 bars fit

---

## 7. Deliverables (05_deliverables)

- `Maple_Insights_Report.pdf`: client-ready report (summary, KPIs, top 5 insights, 3 recommendations, limitations, dashboard images)
- `insights_report.md`: same report in Markdown (for GitHub)
- `screenshots/overview.png`, `screenshots/deep_dive.png`

---

## 8. Client communication log

- Day 1: data received message + questions (decisions in section 3)
- Day 2: progress update after cleaning (4,034 → 3,868 rows)
- Day 5: delivery message with report, dashboard and top 3 insights

## 9. Next steps

1. Finish the dashboard to-do list above
2. Change absolute file paths in the notebooks to relative (`../01_Raw/...`)
3. Write README.md and .gitignore, then upload to GitHub
4. LinkedIn post + Upwork portfolio entry
