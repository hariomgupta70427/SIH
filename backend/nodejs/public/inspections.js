// Inspections Management JavaScript
const socket = io();
let inspections = [];
let filteredInspections = [];

// Load inspections on page load
document.addEventListener('DOMContentLoaded', () => {
    loadInspections();
    setupFilters();
    setupSocketListeners();
});

// Load inspections from API
async function loadInspections() {
    try {
        const response = await fetch('/api/inspections');
        inspections = await response.json();
        populateTypeFilter();
        applyFilters();
    } catch (error) {
        document.getElementById('inspectionsList').innerHTML = '<div class="empty">Error loading inspections</div>';
    }
}

// Populate type filter dropdown
function populateTypeFilter() {
    const typeFilter = document.getElementById('typeFilter');
    const types = [...new Set(inspections.map(i => i.partType).filter(Boolean))];
    
    typeFilter.innerHTML = '<option value="">All Types</option>';
    types.forEach(type => {
        const option = document.createElement('option');
        option.value = type;
        option.textContent = type;
        typeFilter.appendChild(option);
    });
}

// Setup filter event listeners
function setupFilters() {
    document.getElementById('statusFilter').addEventListener('change', applyFilters);
    document.getElementById('typeFilter').addEventListener('change', applyFilters);
}

// Apply filters and render
function applyFilters() {
    const statusFilter = document.getElementById('statusFilter').value;
    const typeFilter = document.getElementById('typeFilter').value;
    
    filteredInspections = inspections.filter(inspection => {
        const matchesStatus = !statusFilter || inspection.status === statusFilter;
        const matchesType = !typeFilter || inspection.partType === typeFilter;
        return matchesStatus && matchesType;
    });
    
    renderInspections();
}

// Render inspections list
function renderInspections() {
    const container = document.getElementById('inspectionsList');
    
    if (filteredInspections.length === 0) {
        container.innerHTML = '<div class="empty">No inspections found</div>';
        return;
    }
    
    container.innerHTML = filteredInspections.map(inspection => `
        <div class="inspection-card">
            <div class="inspection-header">
                <div class="part-id">${inspection.partId || 'N/A'}</div>
                <div class="status ${inspection.status}">${inspection.status?.toUpperCase() || 'PENDING'}</div>
            </div>
            
            <div class="inspection-details">
                <div class="detail-item">
                    <div class="detail-label">Part Type</div>
                    <div class="detail-value">${inspection.partType || 'N/A'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Location</div>
                    <div class="detail-value">${inspection.location || 'N/A'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Condition</div>
                    <div class="detail-value">${inspection.condition || 'N/A'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Priority</div>
                    <div class="detail-value">${inspection.priority || 'medium'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Inspector</div>
                    <div class="detail-value">${inspection.inspectorName || 'N/A'}</div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Date</div>
                    <div class="detail-value">${formatDate(inspection.timestamp)}</div>
                </div>
            </div>
            
            ${inspection.notes ? `<div style="margin-bottom: 1rem;"><strong>Notes:</strong> ${inspection.notes}</div>` : ''}
            
            <div class="actions">
                ${inspection.status !== 'completed' ? `<button class="btn btn-success" onclick="updateStatus('${inspection.id}', 'completed')">Mark Complete</button>` : ''}
                ${inspection.status !== 'failed' ? `<button class="btn btn-danger" onclick="updateStatus('${inspection.id}', 'failed')">Mark Failed</button>` : ''}
                ${inspection.status !== 'pending' ? `<button class="btn btn-warning" onclick="updateStatus('${inspection.id}', 'pending')">Mark Pending</button>` : ''}
            </div>
        </div>
    `).join('');
}

// Update inspection status
async function updateStatus(inspectionId, newStatus) {
    try {
        const response = await fetch(`/api/inspections/${inspectionId}`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ status: newStatus })
        });
        
        if (response.ok) {
            // Update local data
            const inspection = inspections.find(i => i.id === inspectionId);
            if (inspection) {
                inspection.status = newStatus;
                applyFilters();
            }
        } else {
            alert('Failed to update status');
        }
    } catch (error) {
        alert('Error updating status: ' + error.message);
    }
}

// Setup Socket.IO listeners for real-time updates
function setupSocketListeners() {
    socket.on('inspection_added', (inspection) => {
        inspections.unshift(inspection);
        populateTypeFilter();
        applyFilters();
    });
    
    socket.on('inspection_updated', (updatedInspection) => {
        const index = inspections.findIndex(i => i.id === updatedInspection.id);
        if (index !== -1) {
            inspections[index] = { ...inspections[index], ...updatedInspection };
            applyFilters();
        }
    });
}

// Format timestamp
function formatDate(timestamp) {
    if (!timestamp) return 'N/A';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
}