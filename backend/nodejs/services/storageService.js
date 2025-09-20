const admin = require('firebase-admin');
const bucket = admin.storage().bucket();

class StorageService {
  async uploadFile(file, path) {
    try {
      const fileUpload = bucket.file(path);
      const stream = fileUpload.createWriteStream({
        metadata: {
          contentType: file.mimetype,
        },
      });

      return new Promise((resolve, reject) => {
        stream.on('error', reject);
        stream.on('finish', async () => {
          await fileUpload.makePublic();
          const publicUrl = `https://storage.googleapis.com/${bucket.name}/${path}`;
          resolve(publicUrl);
        });
        stream.end(file.buffer);
      });
    } catch (error) {
      throw new Error(`Upload failed: ${error.message}`);
    }
  }

  async deleteFile(path) {
    try {
      await bucket.file(path).delete();
    } catch (error) {
      console.error(`Delete failed: ${error.message}`);
    }
  }

  async cleanupOldFiles(olderThanDays = 30) {
    try {
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - olderThanDays);

      const [files] = await bucket.getFiles();
      const oldFiles = files.filter(file => {
        const created = new Date(file.metadata.timeCreated);
        return created < cutoffDate;
      });

      await Promise.all(oldFiles.map(file => file.delete()));
      console.log(`Cleaned up ${oldFiles.length} old files`);
    } catch (error) {
      console.error(`Cleanup failed: ${error.message}`);
    }
  }
}

module.exports = new StorageService();