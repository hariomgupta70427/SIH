"""
Integration Manager for UDM and TMS Portal Data
Coordinates scraping, data processing, and synchronization
"""

import json
import pandas as pd
from datetime import datetime, timedelta
import schedule
import time
from scrapers.udm_scraper import UDMScraper
from scrapers.tms_scraper import TMSScraper

class IntegrationManager:
    def __init__(self):
        self.udm_scraper = None
        self.tms_scraper = None
        self.last_sync = None
        
    def initialize_scrapers(self):
        """Initialize both scrapers"""
        try:
            self.udm_scraper = UDMScraper(headless=True)
            self.tms_scraper = TMSScraper(use_selenium=False)
            print("Scrapers initialized successfully")
            return True
        except Exception as e:
            print(f"Scraper initialization error: {e}")
            return False
    
    def sync_udm_data(self):
        """Sync data from UDM portal"""
        try:
            print("Starting UDM data sync...")
            
            # Login and scrape UDM data
            if self.udm_scraper.login():
                if self.udm_scraper.navigate_to_inventory():
                    parts_data = self.udm_scraper.scrape_parts_data()
                    
                    if parts_data:
                        # Process and save data
                        processed_data = self.process_udm_data(parts_data)
                        self.save_sync_data(processed_data, 'udm_sync_data.json')
                        
                        print(f"UDM sync completed: {len(parts_data)} parts")
                        return processed_data
            
            print("UDM sync failed")
            return []
            
        except Exception as e:
            print(f"UDM sync error: {e}")
            return []
    
    def sync_tms_data(self):
        """Sync data from TMS portal"""
        try:
            print("Starting TMS data sync...")
            
            # Scrape TMS data
            track_data = self.tms_scraper.scrape_static_tms()
            inspection_data = self.tms_scraper.get_inspection_records()
            
            if track_data or inspection_data:
                # Process and combine data
                processed_data = self.process_tms_data(track_data, inspection_data)
                self.save_sync_data(processed_data, 'tms_sync_data.json')
                
                print(f"TMS sync completed: {len(track_data)} tracks, {len(inspection_data)} inspections")
                return processed_data
            
            print("TMS sync failed")
            return []
            
        except Exception as e:
            print(f"TMS sync error: {e}")
            return []
    
    def process_udm_data(self, raw_data):
        """Process and standardize UDM data"""
        processed_data = []
        
        for item in raw_data:
            processed_item = {
                'source': 'UDM',
                'sync_timestamp': datetime.now().isoformat(),
                'part_id': item.get('part_id'),
                'name': item.get('part_name'),
                'category': item.get('category'),
                'quantity': self.safe_int(item.get('quantity')),
                'status': item.get('status', '').lower(),
                'location': item.get('location'),
                'last_updated': item.get('last_updated'),
                'data_quality': self.assess_data_quality(item)
            }
            processed_data.append(processed_item)
        
        return processed_data
    
    def process_tms_data(self, track_data, inspection_data):
        """Process and standardize TMS data"""
        processed_data = {
            'tracks': [],
            'inspections': []
        }
        
        # Process track data
        for track in track_data:
            processed_track = {
                'source': 'TMS',
                'sync_timestamp': datetime.now().isoformat(),
                'track_id': track.get('track_id'),
                'section': track.get('section'),
                'kilometer': track.get('kilometer'),
                'condition': track.get('ballast_condition', '').lower(),
                'last_inspection': track.get('last_inspection'),
                'priority': track.get('priority', '').lower(),
                'maintenance_required': track.get('maintenance_required'),
                'data_quality': self.assess_data_quality(track)
            }
            processed_data['tracks'].append(processed_track)
        
        # Process inspection data
        for inspection in inspection_data:
            processed_inspection = {
                'source': 'TMS',
                'sync_timestamp': datetime.now().isoformat(),
                'inspection_id': inspection.get('inspection_id'),
                'track_id': inspection.get('track_id'),
                'inspection_date': inspection.get('inspection_date'),
                'inspector': inspection.get('inspector_name'),
                'type': inspection.get('inspection_type'),
                'defects_count': len(inspection.get('defects', [])),
                'recommendations': inspection.get('recommendations'),
                'next_inspection': inspection.get('next_inspection')
            }
            processed_data['inspections'].append(processed_inspection)
        
        return processed_data
    
    def safe_int(self, value):
        """Safely convert value to integer"""
        try:
            return int(str(value).replace(',', ''))
        except (ValueError, TypeError):
            return 0
    
    def assess_data_quality(self, data_item):
        """Assess data quality score (0-100)"""
        score = 100
        required_fields = ['id', 'name', 'status']
        
        # Check for missing required fields
        for field in required_fields:
            if not any(key.endswith(field) for key in data_item.keys()):
                score -= 20
        
        # Check for empty values
        empty_count = sum(1 for v in data_item.values() if not v or v == 'N/A')
        score -= (empty_count * 5)
        
        return max(0, min(100, score))
    
    def generate_sync_report(self, udm_data, tms_data):
        """Generate synchronization report"""
        report = {
            'sync_timestamp': datetime.now().isoformat(),
            'udm_summary': {
                'total_parts': len(udm_data),
                'active_parts': len([p for p in udm_data if p.get('status') == 'active']),
                'low_stock_parts': len([p for p in udm_data if p.get('quantity', 0) < 10]),
                'avg_data_quality': sum(p.get('data_quality', 0) for p in udm_data) / len(udm_data) if udm_data else 0
            },
            'tms_summary': {
                'total_tracks': len(tms_data.get('tracks', [])),
                'critical_tracks': len([t for t in tms_data.get('tracks', []) if t.get('priority') == 'critical']),
                'recent_inspections': len([i for i in tms_data.get('inspections', []) 
                                         if self.is_recent_date(i.get('inspection_date'))]),
                'avg_data_quality': self.calculate_avg_quality(tms_data)
            },
            'integration_status': 'success',
            'next_sync': (datetime.now() + timedelta(hours=6)).isoformat()
        }
        
        return report
    
    def is_recent_date(self, date_str):
        """Check if date is within last 30 days"""
        try:
            date_obj = datetime.fromisoformat(date_str.replace('Z', '+00:00'))
            return (datetime.now() - date_obj).days <= 30
        except:
            return False
    
    def calculate_avg_quality(self, tms_data):
        """Calculate average data quality for TMS data"""
        all_items = tms_data.get('tracks', []) + tms_data.get('inspections', [])
        if not all_items:
            return 0
        return sum(item.get('data_quality', 0) for item in all_items) / len(all_items)
    
    def save_sync_data(self, data, filename):
        """Save synchronized data"""
        try:
            with open(f'data/{filename}', 'w') as f:
                json.dump(data, f, indent=2)
            print(f"Data saved to data/{filename}")
        except Exception as e:
            print(f"Save error: {e}")
    
    def run_full_sync(self):
        """Run complete synchronization process"""
        print("Starting full synchronization...")
        
        if not self.initialize_scrapers():
            return False
        
        try:
            # Sync both portals
            udm_data = self.sync_udm_data()
            tms_data = self.sync_tms_data()
            
            # Generate report
            report = self.generate_sync_report(udm_data, tms_data)
            self.save_sync_data(report, 'sync_report.json')
            
            # Update last sync time
            self.last_sync = datetime.now()
            
            print("Full synchronization completed successfully")
            print(f"UDM: {len(udm_data)} parts")
            print(f"TMS: {len(tms_data.get('tracks', []))} tracks, {len(tms_data.get('inspections', []))} inspections")
            
            return True
            
        except Exception as e:
            print(f"Full sync error: {e}")
            return False
        
        finally:
            self.cleanup()
    
    def schedule_sync(self):
        """Schedule automatic synchronization"""
        # Schedule sync every 6 hours
        schedule.every(6).hours.do(self.run_full_sync)
        
        # Schedule daily reports
        schedule.every().day.at("08:00").do(self.generate_daily_report)
        
        print("Synchronization scheduled:")
        print("- Full sync: Every 6 hours")
        print("- Daily report: 08:00 AM")
        
        # Keep running
        while True:
            schedule.run_pending()
            time.sleep(60)  # Check every minute
    
    def generate_daily_report(self):
        """Generate daily integration report"""
        try:
            # Load latest sync data
            with open('data/sync_report.json', 'r') as f:
                latest_report = json.load(f)
            
            daily_report = {
                'date': datetime.now().strftime('%Y-%m-%d'),
                'last_sync': latest_report.get('sync_timestamp'),
                'udm_status': latest_report.get('udm_summary'),
                'tms_status': latest_report.get('tms_summary'),
                'recommendations': self.generate_recommendations(latest_report)
            }
            
            self.save_sync_data(daily_report, f'daily_report_{datetime.now().strftime("%Y%m%d")}.json')
            print("Daily report generated")
            
        except Exception as e:
            print(f"Daily report error: {e}")
    
    def generate_recommendations(self, report):
        """Generate actionable recommendations"""
        recommendations = []
        
        udm_summary = report.get('udm_summary', {})
        tms_summary = report.get('tms_summary', {})
        
        # UDM recommendations
        if udm_summary.get('low_stock_parts', 0) > 0:
            recommendations.append(f"Reorder {udm_summary['low_stock_parts']} low-stock parts")
        
        if udm_summary.get('avg_data_quality', 0) < 80:
            recommendations.append("Improve UDM data quality - missing information detected")
        
        # TMS recommendations
        if tms_summary.get('critical_tracks', 0) > 0:
            recommendations.append(f"Urgent: Address {tms_summary['critical_tracks']} critical track sections")
        
        if tms_summary.get('recent_inspections', 0) < tms_summary.get('total_tracks', 0) * 0.1:
            recommendations.append("Increase inspection frequency - many tracks overdue")
        
        return recommendations
    
    def cleanup(self):
        """Clean up resources"""
        if self.udm_scraper:
            self.udm_scraper.close()
        if self.tms_scraper:
            self.tms_scraper.close()

def main():
    """Main integration workflow"""
    manager = IntegrationManager()
    
    # Run one-time sync
    print("Running one-time synchronization...")
    success = manager.run_full_sync()
    
    if success:
        print("Synchronization completed successfully")
        
        # Optionally start scheduled sync
        # manager.schedule_sync()  # Uncomment to run continuous sync
    else:
        print("Synchronization failed")

if __name__ == "__main__":
    main()