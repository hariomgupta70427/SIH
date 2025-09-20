const admin = require('firebase-admin');
const db = admin.firestore();

class AnalyticsService {
  constructor() {
    this.listeners = [];
  }

  startRealTimeUpdates(io) {
    const unsubscribe = db.collection('inspections')
      .onSnapshot((snapshot) => {
        const changes = snapshot.docChanges();
        
        changes.forEach((change) => {
          const data = { id: change.doc.id, ...change.doc.data() };
          
          if (change.type === 'added') {
            io.emit('inspection_added', data);
          } else if (change.type === 'modified') {
            io.emit('inspection_updated', data);
          }
        });
        
        this.emitAnalytics(io, snapshot);
      });
    
    this.listeners.push(unsubscribe);
  }

  async emitAnalytics(io, snapshot) {
    try {
      const inspections = snapshot.docs.map(doc => doc.data());
      
      const analytics = {
        total: inspections.length,
        pending: inspections.filter(i => i.status === 'pending').length,
        completed: inspections.filter(i => i.status === 'completed').length,
        failed: inspections.filter(i => i.status === 'failed').length,
        byDate: this.getInspectionsByDate(inspections),
        byType: this.getInspectionsByType(inspections),
        timestamp: new Date()
      };
      
      io.emit('analytics_update', analytics);
    } catch (error) {
      console.error('Analytics emission error:', error);
    }
  }

  getInspectionsByDate(inspections) {
    const dateMap = {};
    inspections.forEach(inspection => {
      const date = new Date(inspection.timestamp?.toDate?.() || inspection.timestamp).toDateString();
      dateMap[date] = (dateMap[date] || 0) + 1;
    });
    return dateMap;
  }

  getInspectionsByType(inspections) {
    const typeMap = {};
    inspections.forEach(inspection => {
      const type = inspection.partType || 'Unknown';
      typeMap[type] = (typeMap[type] || 0) + 1;
    });
    return typeMap;
  }

  cleanup() {
    this.listeners.forEach(unsubscribe => unsubscribe());
  }
}

module.exports = new AnalyticsService();