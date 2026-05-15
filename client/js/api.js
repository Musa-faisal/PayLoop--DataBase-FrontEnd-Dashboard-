// api.js — Fetch wrappers for all PayLoop API endpoints

async function apiFetch(url) {
  try {
    const res = await fetch(url);
    const data = await res.json();
    if (data && data.error) {
      console.error(`API error (${url}):`, data.error);
      return null;
    }
    return data;
  } catch (err) {
    console.error(`Fetch failed (${url}):`, err.message);
    return null;
  }
}

const API = {
  getOverview:           () => apiFetch('/api/overview'),
  getTransactions:       () => apiFetch('/api/transactions'),
  getTransactionSummary: () => apiFetch('/api/transactions/summary'),
  getTransactionMonthly: () => apiFetch('/api/transactions/monthly'),
  getMerchants:          () => apiFetch('/api/merchants'),
  getMerchantCategories: () => apiFetch('/api/merchants/categories'),
  getUserBalances:       () => apiFetch('/api/users/balances'),
  getUserDistribution:   () => apiFetch('/api/users/distribution'),
  getUserSpending:       () => apiFetch('/api/users/spending'),
  getCities:             () => apiFetch('/api/analytics/cities'),
  getFraud:              () => apiFetch('/api/analytics/fraud'),
  getAudit:              () => apiFetch('/api/analytics/audit'),
};
