// Real-time Dashboard with Chart.js and Socket.IO
const socket = io();

// Chart instances
let dateChart, typeChart;

// Initialize charts
function initCharts() {
    // Date chart
    const dateCtx = document.getElementById('dateChart').getContext('2d');
    dateChart = new Chart(dateCtx, {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                label: 'Inspections',
                data: [],
                borderColor: '#3498db',
                backgroundColor: 'rgba(52, 152, 219, 0.1)',
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            scales: {
                y: { beginAtZero: true }
            }
        }
    });

    // Type chart
    const typeCtx = document.getElementById('typeChart').getContext('2d');
    typeChart = new Chart(typeCtx, {
        type: 'doughnut',
        data: {
            labels: [],
            datasets: [{
                data: [],
                backgroundColor: ['#e74c3c', '#f39c12', '#2ecc71', '#9b59b6', '#34495e']
            }]
        },
        options: {
            responsive: true
        }
    });
}

// Update stats cards
function updateStats(analytics) {
    document.getElementById('totalInspections').textContent = analytics.total || 0;
    document.getElementById('pendingInspections').textContent = analytics.pending || 0;
    document.getElementById('completedInspections').textContent = analytics.completed || 0;
    document.getElementById('failedInspections').textContent = analytics.failed || 0;
}

// Update date chart
function updateDateChart(byDate) {
    const sortedDates = Object.keys(byDate).sort((a, b) => new Date(a) - new Date(b));
    const values = sortedDates.map(date => byDate[date]);
    
    dateChart.data.labels = sortedDates.map(date => new Date(date).toLocaleDateString());
    dateChart.data.datasets[0].data = values;
    dateChart.update('none');
}

// Update type chart
function updateTypeChart(byType) {
    const types = Object.keys(byType);
    const values = Object.values(byType);
    
    typeChart.data.labels = types;
    typeChart.data.datasets[0].data = values;
    typeChart.update('none');
}

// Socket event listeners
socket.on('connect', () => {
    document.getElementById('status').textContent = 'Connected';
    document.getElementById('status').className = 'status connected';
});

socket.on('disconnect', () => {
    document.getElementById('status').textContent = 'Disconnected';
    document.getElementById('status').className = 'status disconnected';
});

// Real-time analytics updates
socket.on('analytics_update', (analytics) => {
    updateStats(analytics);
    updateDateChart(analytics.byDate || {});
    updateTypeChart(analytics.byType || {});
});

// Individual inspection updates
socket.on('inspection_added', (inspection) => {
    // Trigger analytics refresh
    console.log('New inspection added:', inspection.id);
});

socket.on('inspection_updated', (inspection) => {
    // Trigger analytics refresh
    console.log('Inspection updated:', inspection.id);
});

// Get auth token from localStorage (injected by Flutter)
function getAuthHeaders() {
    const token = localStorage.getItem('authToken');
    return token ? { 'Authorization': `Bearer ${token}` } : {};
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    initCharts();
    
    // Fetch initial data
    fetch('/api/analytics', {
        headers: getAuthHeaders()
    })
        .then(res => res.json())
        .then(analytics => {
            updateStats(analytics);
            updateDateChart(analytics.byDate || {});
            updateTypeChart(analytics.byType || {});
        })
        .catch(err => console.error('Failed to load initial data:', err));
});