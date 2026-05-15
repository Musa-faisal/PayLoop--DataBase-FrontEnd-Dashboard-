// charts.js — Chart.js render helpers (dark fintech theme)

// ── Global defaults ──
Chart.defaults.color = '#8B949E';
Chart.defaults.borderColor = '#30363D';
Chart.defaults.font.family = "'Inter', system-ui, sans-serif";

const ACCENT      = '#00C896';
const ACCENT_DIM  = 'rgba(0,200,150,0.15)';
const PALETTE = [
  '#00C896', '#3FB950', '#D29922', '#F85149',
  '#58A6FF', '#BC8CFF', '#FF7B72', '#79C0FF',
  '#56D364', '#E3B341'
];

function destroyIfExists(id) {
  const existing = Chart.getChart(id);
  if (existing) existing.destroy();
}

function renderLineChart(id, labels, data, label = 'Value') {
  destroyIfExists(id);
  const ctx = document.getElementById(id);
  if (!ctx) return;
  return new Chart(ctx, {
    type: 'line',
    data: {
      labels,
      datasets: [{
        label,
        data,
        borderColor: ACCENT,
        backgroundColor: ACCENT_DIM,
        borderWidth: 2,
        pointBackgroundColor: ACCENT,
        pointRadius: 3,
        fill: true,
        tension: 0.4
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: true,
      plugins: {
        legend: { labels: { color: '#E6EDF3', font: { size: 12 } } }
      },
      scales: {
        x: { ticks: { color: '#8B949E' }, grid: { color: '#30363D' } },
        y: { ticks: { color: '#8B949E' }, grid: { color: '#30363D' } }
      }
    }
  });
}

function renderBarChart(id, labels, data, label = 'Value') {
  destroyIfExists(id);
  const ctx = document.getElementById(id);
  if (!ctx) return;
  return new Chart(ctx, {
    type: 'bar',
    data: {
      labels,
      datasets: [{
        label,
        data,
        backgroundColor: PALETTE.slice(0, data.length),
        borderRadius: 4,
        borderSkipped: false
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: true,
      plugins: {
        legend: { labels: { color: '#E6EDF3', font: { size: 12 } } }
      },
      scales: {
        x: { ticks: { color: '#8B949E' }, grid: { color: '#30363D' } },
        y: { ticks: { color: '#8B949E' }, grid: { color: '#30363D' } }
      }
    }
  });
}

function renderDoughnutChart(id, labels, data) {
  destroyIfExists(id);
  const ctx = document.getElementById(id);
  if (!ctx) return;
  return new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels,
      datasets: [{
        data,
        backgroundColor: PALETTE.slice(0, data.length),
        borderColor: '#161B22',
        borderWidth: 2
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: true,
      cutout: '65%',
      plugins: {
        legend: {
          position: 'bottom',
          labels: { color: '#E6EDF3', font: { size: 12 }, padding: 12 }
        }
      }
    }
  });
}

function renderHorizontalBar(id, labels, data, label = 'Value') {
  destroyIfExists(id);
  const ctx = document.getElementById(id);
  if (!ctx) return;
  return new Chart(ctx, {
    type: 'bar',
    data: {
      labels,
      datasets: [{
        label,
        data,
        backgroundColor: PALETTE.slice(0, data.length),
        borderRadius: 4,
        borderSkipped: false
      }]
    },
    options: {
      indexAxis: 'y',
      responsive: true,
      maintainAspectRatio: true,
      plugins: {
        legend: { labels: { color: '#E6EDF3', font: { size: 12 } } }
      },
      scales: {
        x: { ticks: { color: '#8B949E' }, grid: { color: '#30363D' } },
        y: { ticks: { color: '#8B949E' }, grid: { color: '#30363D' } }
      }
    }
  });
}
