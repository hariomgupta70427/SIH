const admin = require('firebase-admin');
const storageService = require('./storageService');
const db = admin.firestore();

class CleanupService {
  constructor() {
    this.isRunning = false;
  }

  // Start periodic cleanup (run daily)
  startPeriodicCleanup() {
    if (this.isRunning) return;
    
    this.isRunning = true;
    console.log('Starting periodic cleanup service');
    
    // Run cleanup every 24 hours
    setInterval(async () => {
      await this.runCleanup();
    }, 24 * 60 * 60 * 1000);
    
    // Run initial cleanup after 1 minute
    setTimeout(() => this.runCleanup(), 60000);
  }

  async runCleanup() {
    try {
      console.log('Running cleanup...');
      
      // Clean up expired inspections (90+ days old)
      await this.cleanupExpiredInspections();
      
      // Clean up orphaned storage files
      await this.cleanupOrphanedFiles();
      
      // Clean up old analytics data
      await this.cleanupOldAnalytics();
      
      console.log('Cleanup completed');
    } catch (error) {
      console.error('Cleanup failed:', error);
    }
  }

  async cleanupExpiredInspections() {
    const cutoffDate = new Date(Date.now() - 90 * 24 * 60 * 60 * 1000);
    
    const snapshot = await db.collection('inspections')
      .where('timestamp', '<', cutoffDate)
      .get();
    
    if (snapshot.empty) return;
    
    const batch = db.batch();
    const imagesToDelete = [];
    
    snapshot.docs.forEach(doc => {
      const data = doc.data();
      if (data.imageUrl) {
        const fileName = data.imageUrl.split('/').pop();
        imagesToDelete.push(`inspections/${fileName}`);
      }
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    
    // Delete associated images
    await Promise.all(imagesToDelete.map(path => 
      storageService.deleteFile(path).catch(console.error)
    ));
    
    console.log(`Cleaned up ${snapshot.size} expired inspections`);
  }

  async cleanupOrphanedFiles() {
    await storageService.cleanupOldFiles(90);
  }

  async cleanupOldAnalytics() {
    const cutoffDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    
    const snapshot = await db.collection('analytics')
      .where('timestamp', '<', cutoffDate)
      .get();
    
    if (snapshot.empty) return;
    
    const batch = db.batch();
    snapshot.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
    
    console.log(`Cleaned up ${snapshot.size} old analytics records`);
  }

  stop() {
    this.isRunning = false;
  }
}

module.exports = new CleanupService();