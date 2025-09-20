// Data Entry Form JavaScript
let measurementCount = 0;
let defectCount = 0;

// Add measurement field
function addMeasurement() {
    const container = document.getElementById('measurementsList');
    const div = document.createElement('div');
    div.className = 'measurement-item';
    div.innerHTML = `
        <input type="text" placeholder="Parameter (e.g., Length)" name="measurement_param_${measurementCount}">
        <input type="text" placeholder="Value (e.g., 25.5 mm)" name="measurement_value_${measurementCount}">
        <button type="button" class="remove-btn" onclick="removeMeasurement(this)">×</button>
    `;
    container.appendChild(div);
    measurementCount++;
}

// Remove measurement field
function removeMeasurement(btn) {
    btn.parentElement.remove();
}

// Add defect field
function addDefect() {
    const container = document.getElementById('defectsList');
    const div = document.createElement('div');
    div.className = 'defect-item';
    div.innerHTML = `
        <input type="text" placeholder="Defect description" name="defect_${defectCount}" style="flex: 1;">
        <button type="button" class="remove-btn" onclick="removeDefect(this)">×</button>
    `;
    container.appendChild(div);
    defectCount++;
}

// Remove defect field
function removeDefect(btn) {
    btn.parentElement.remove();
}

// Show status message
function showStatus(message, isError = false) {
    const status = document.getElementById('status');
    status.textContent = message;
    status.className = `status ${isError ? 'error' : 'success'}`;
    status.style.display = 'block';
    setTimeout(() => {
        status.style.display = 'none';
    }, 5000);
}

// Handle form submission
document.getElementById('inspectionForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const formData = new FormData(e.target);
    
    // Collect measurements
    const measurements = {};
    for (let i = 0; i < measurementCount; i++) {
        const param = formData.get(`measurement_param_${i}`);
        const value = formData.get(`measurement_value_${i}`);
        if (param && value) {
            measurements[param] = value;
        }
    }
    
    // Collect defects
    const defects = [];
    for (let i = 0; i < defectCount; i++) {
        const defect = formData.get(`defect_${i}`);
        if (defect) {
            defects.push(defect);
        }
    }
    
    // Prepare final form data
    const finalFormData = new FormData();
    finalFormData.append('partId', formData.get('partId'));
    finalFormData.append('partType', formData.get('partType'));
    finalFormData.append('partName', formData.get('partName'));
    finalFormData.append('location', formData.get('location'));
    finalFormData.append('condition', formData.get('condition'));
    finalFormData.append('priority', formData.get('priority'));
    finalFormData.append('notes', formData.get('notes'));
    finalFormData.append('measurements', JSON.stringify(measurements));
    finalFormData.append('defects', JSON.stringify(defects));
    
    if (formData.get('image')) {
        finalFormData.append('image', formData.get('image'));
    }
    
    try {
        const response = await fetch('/api/inspections', {
            method: 'POST',
            body: finalFormData
        });
        
        if (response.ok) {
            const result = await response.json();
            showStatus('Inspection submitted successfully!');
            e.target.reset();
            document.getElementById('measurementsList').innerHTML = '';
            document.getElementById('defectsList').innerHTML = '';
            measurementCount = 0;
            defectCount = 0;
        } else {
            const error = await response.json();
            showStatus(`Error: ${error.error}`, true);
        }
    } catch (error) {
        showStatus(`Network error: ${error.message}`, true);
    }
});

// Initialize with one measurement field
addMeasurement();