// app.js — Router + section data loaders

// ── Utility ──────────────────────────────────────────────
function pkr(value) {
  const num = parseFloat(value) || 0;
  return 'PKR ' + num.toLocaleString('en-PK', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function typeBadge(type) {
  const t = (type || '').toLowerCase().replace('_', '-');
  const map = {
    credit: 'badge-credit',
    debit: 'badge-debit',
    'transfer-in': 'badge-transfer-in',
    'transfer-out': 'badge-transfer-out'
  };
  const cls = map[t] || 'badge-credit';
  return `<span class="badge ${cls}">${type}</span>`;
}

function statusBadge(status) {
  const s = (status || '').toLowerCase();
  return `<span class="badge badge-${s}">${status}</span>`;
}

function formatDate(val) {
  if (!val) return '—';
  const d = new Date(val);
  return isNaN(d) ? val : d.toLocaleDateString('en-PK', { year: 'numeric', month: 'short', day: 'numeric' });
}

function formatMonth(val) {
  if (!val) return '—';
  // val may be "2024-01-01" or a Date
  const d = new Date(val);
  return isNaN(d) ? val : d.toLocaleDateString('en-PK', { year: 'numeric', month: 'short' });
}

function setTableBody(tableId, rows) {
  const tbody = document.querySelector(`#${tableId} tbody`);
  if (!tbody) return;
  if (!rows || rows.length === 0) {
    tbody.innerHTML = `<tr><td colspan="10" class="loading-msg">No data available.</td></tr>`;
    return;
  }
  tbody.innerHTML = rows;
}

// ── Router ───────────────────────────────────────────────
const sections = ['overview', 'transactions', 'merchants', 'users', 'analytics'];
const loaders  = {};

document.querySelectorAll('.nav-item').forEach(item => {
  item.addEventListener('click', () => {
    const target = item.dataset.section;

    // Update nav
    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
    item.classList.add('active');

    // Show section
    document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
    document.getElementById(`section-${target}`).classList.add('active');

    // Load data
    if (loaders[target]) loaders[target]();
  });
});

// ── SECTION: Overview ────────────────────────────────────
loaders.overview = async function () {
  // KPIs
  const data = await API.getOverview();
  if (data) {
    document.getElementById('kpi-users').textContent   = Number(data.totalUsers).toLocaleString();
    document.getElementById('kpi-wallets').textContent = Number(data.totalWallets).toLocaleString();
    document.getElementById('kpi-volume').textContent  = pkr(data.totalVolume);
    document.getElementById('kpi-avg').textContent     = pkr(data.avgBalance);
    document.getElementById('kpi-txns').textContent    = Number(data.totalTransactions).toLocaleString();
  }

  // Monthly line chart
  const monthly = await API.getTransactionMonthly();
  if (monthly && monthly.length) {
    const labels = monthly.map(r => `${r.year}-${String(r.month).padStart(2, '0')}`);
    const amounts = monthly.map(r => parseFloat(r.total_amount) || 0);
    renderLineChart('chart-monthly-volume', labels, amounts, 'Total Amount (PKR)');
  }

  // Transaction split doughnut
  const summary = await API.getTransactionSummary();
  if (summary && summary.length) {
    const labels = summary.map(r => r.txn_type);
    const counts  = summary.map(r => parseFloat(r.txn_count) || 0);
    renderDoughnutChart('chart-txn-split', labels, counts);
  }
};

// ── SECTION: Transactions ────────────────────────────────
loaders.transactions = async function () {
  // Bar chart — total by type
  const summary = await API.getTransactionSummary();
  if (summary && summary.length) {
    const labels  = summary.map(r => r.txn_type);
    const amounts = summary.map(r => parseFloat(r.total_amount) || 0);
    renderBarChart('chart-txn-by-type', labels, amounts, 'Total Amount (PKR)');
  }

  // Transactions table
  const txns = await API.getTransactions();
  if (!txns) return;

  const rows = txns.map(r => `
    <tr>
      <td>${r.name || '—'}</td>
      <td>${typeBadge(r.txn_type)}</td>
      <td class="text-right">${pkr(r.amount)}</td>
      <td>${r.note || '—'}</td>
      <td>${formatDate(r.txn_date)}</td>
    </tr>`).join('');

  setTableBody('table-transactions', rows);
};

// ── SECTION: Merchants ───────────────────────────────────
loaders.merchants = async function () {
  const merchants = await API.getMerchants();

  if (merchants && merchants.length) {
    // Horizontal bar — top 10
    const top10 = merchants.slice(0, 10);
    renderHorizontalBar(
      'chart-merchant-revenue',
      top10.map(m => m.name || m.merchant_name),
      top10.map(m => parseFloat(m.total_received) || 0),
      'Total Received (PKR)'
    );

    // Table
    const rows = merchants.map(r => `
      <tr>
        <td>${r.name || r.merchant_name || '—'}</td>
        <td>${r.category || '—'}</td>
        <td class="text-right">${Number(r.payment_count || r.payments || 0).toLocaleString()}</td>
        <td class="text-right">${pkr(r.total_received)}</td>
      </tr>`).join('');
    setTableBody('table-merchants', rows);
  }

  // Category doughnut
  const cats = await API.getMerchantCategories();
  if (cats && cats.length) {
    renderDoughnutChart(
      'chart-category-revenue',
      cats.map(c => c.category),
      cats.map(c => parseFloat(c.total_value) || 0)
    );
  }
};

// ── SECTION: Users & Wallets ─────────────────────────────
loaders.users = async function () {
  // Top spenders bar chart
  const spending = await API.getUserSpending();
  if (spending && spending.length) {
    const top10 = spending.slice(0, 10);
    renderBarChart(
      'chart-top-spenders',
      top10.map(u => u.name),
      top10.map(u => parseFloat(u.total_spent) || 0),
      'Total Spent (PKR)'
    );
  }

  // Wallet distribution doughnut
  const dist = await API.getUserDistribution();
  if (dist && dist.length) {
    renderDoughnutChart(
      'chart-wallet-tiers',
      dist.map(d => d.balance_tier),
      dist.map(d => parseFloat(d.user_count) || 0)
    );
  }

  // Balances table
  const balances = await API.getUserBalances();
  if (balances && balances.length) {
    const rows = balances.map(r => `
      <tr>
        <td>${r.name || '—'}</td>
        <td>${r.email || '—'}</td>
        <td class="text-right">${pkr(r.balance)}</td>
        <td>${statusBadge(r.status || 'active')}</td>
      </tr>`).join('');
    setTableBody('table-balances', rows);
  }
};

// ── SECTION: Analytics ───────────────────────────────────
loaders.analytics = async function () {
  // Cities chart + table
  const cities = await API.getCities();
  if (cities && cities.length) {
    // Unique cities for chart
    const cityMap = {};
    cities.forEach(r => {
      const city = r.city || r.City;
      const vol  = parseFloat(r.transaction_volume || r.TransactionVolume) || 0;
      cityMap[city] = (cityMap[city] || 0) + vol;
    });
    const cityLabels = Object.keys(cityMap);
    const cityVols   = Object.values(cityMap);
    renderBarChart('chart-cities', cityLabels, cityVols, 'Total Volume (PKR)');

    // Table
    const rows = cities.map(r => {
      const city = r.city || r.City;
      const month = r.transaction_month || r.TransactionMonth;
      const vol = r.transaction_volume || r.TransactionVolume;
      return `<tr>
        <td>${city || '—'}</td>
        <td>${formatMonth(month)}</td>
        <td class="text-right">${pkr(vol)}</td>
      </tr>`;
    }).join('');
    setTableBody('table-cities', rows);
  }

  // Fraud table
  const fraud = await API.getFraud();
  if (fraud && fraud.length) {
    const rows = fraud.map(r => {
      // Accept any column naming
      const name   = r.name || r.Name || r.user_name || '—';
      const amount = r.amount || r.Amount || 0;
      const type   = r.txn_type || r.Type || '—';
      const note   = r.note || r.Note || '—';
      const date   = r.txn_date || r.Date || r.date;
      return `<tr class="fraud-row">
        <td>${name}</td>
        <td class="text-right">${pkr(amount)}</td>
        <td>${typeBadge(type)}</td>
        <td>${note}</td>
        <td>${formatDate(date)}</td>
      </tr>`;
    }).join('');
    setTableBody('table-fraud', rows);
  }

  // Audit feed
  const audit = await API.getAudit();
  const feed = document.getElementById('audit-feed');
  if (feed) {
    if (!audit || audit.length === 0) {
      feed.innerHTML = '<p class="loading-msg">No audit entries.</p>';
    } else {
      feed.innerHTML = audit.map(r => {
        const event   = r.event_type || r.EventType || 'Event';
        const details = r.details || r.Details || '';
        const time    = r.log_date || r.LogDate;
        return `<div class="audit-entry">
          <div class="audit-dot"></div>
          <div class="audit-body">
            <div class="audit-event">${event}</div>
            <div class="audit-details">${details}</div>
            <div class="audit-time">${formatDate(time)}</div>
          </div>
        </div>`;
      }).join('');
    }
  }
};

// ── Bootstrap ────────────────────────────────────────────
loaders.overview();
