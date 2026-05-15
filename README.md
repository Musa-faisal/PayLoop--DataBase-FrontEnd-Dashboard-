# PayLoop Analytics Dashboard

A real-time analytics dashboard for **PayLoopDBCourse** — a Microsoft SQL Server database simulating a digital wallet system. Built with Node.js + Express on the backend and vanilla HTML/CSS/JS + Chart.js on the frontend.

---

## Tech Stack

| Layer      | Technology                          |
|------------|-------------------------------------|
| Runtime    | Node.js (LTS)                       |
| Backend    | Express 4.x                         |
| Database   | Microsoft SQL Server (via `mssql`)  |
| Auth       | Windows Trusted Authentication      |
| Frontend   | Vanilla HTML / CSS / JavaScript     |
| Charts     | Chart.js 4.x (CDN)                  |
| Fonts      | Inter (Google Fonts CDN)            |

---

## Features

- **Overview** — KPI cards: total users, wallets, volume, avg balance, transactions + monthly trend line + transaction type doughnut
- **Transactions** — Last 50 transactions table with colour-coded type badges + bar chart by type
- **Merchants** — Revenue leaderboard, horizontal bar chart, category doughnut
- **Users & Wallets** — Balance table, top-spenders bar chart, wallet tier doughnut
- **Analytics** — City-level transaction map, fraud monitoring table (highlighted rows), audit log feed

---

## Setup

### Prerequisites

- Node.js 18+ installed
- Microsoft SQL Server (Express or full) running locally
- Database `PayLoopDBCourse` restored and accessible via Windows Authentication

### Steps

```bash
# 1. Clone / copy the project
cd payloop-dashboard

# 2. Install dependencies
npm install

# 3. Configure environment (defaults work for local SQL Server Express + Windows Auth)
copy .env.example .env
# Edit .env if your server name differs from localhost\SQLEXPRESS

# 4. Start the server
node server/index.js

# 5. Open in browser
# http://localhost:3000
```

---

## Environment Variables

| Variable              | Default              | Description                        |
|-----------------------|----------------------|------------------------------------|
| `DB_SERVER`           | `localhost\SQLEXPRESS` | SQL Server instance name           |
| `DB_NAME`             | `PayLoopDBCourse`    | Database name                      |
| `DB_TRUSTED_CONNECTION` | `true`             | Use Windows Authentication         |
| `DB_PORT`             | `1433`               | SQL Server port                    |
| `PORT`                | `3000`               | Express HTTP port                  |

---

## Screenshot

> _(Add a screenshot here once the dashboard is running)_

---

## Database Requirements

The following views/objects must exist in `PayLoopDBCourse`:

- `ShowTransactions` — joined view of Transactions + Users + Wallets
- `ShowBalances` — joined view of Wallets + Users
- `MerchantTotals` — merchant revenue aggregation
- `WalletDistribution` — wallet balance tiers (HIGH / MEDIUM / LOW)
- `CityTransactions` — monthly transaction volume by city
- `FraudMonitoring` — flagged high-risk transactions
- `AuditLog` — system event log table

---

## Project Structure

```
payloop-dashboard/
├── server/
│   ├── index.js          # Express entry point
│   ├── db.js             # mssql connection pool
│   └── routes/           # API route handlers
├── client/
│   ├── index.html        # Single-page app shell
│   ├── style.css         # Dark fintech theme
│   └── js/
│       ├── app.js        # Router + section loaders
│       ├── api.js        # Fetch wrappers
│       └── charts.js     # Chart.js helpers
└── CLAUDE.md             # Full technical documentation
```
