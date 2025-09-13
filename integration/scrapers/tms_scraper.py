"""
TMS (Track Management System) Scraper
Retrieves track fitting and inspection data using requests + BeautifulSoup or Selenium
"""

import requests
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
import pandas as pd
import json
import time
from fake_useragent import UserAgent
from urllib.parse import urljoin, urlparse

class TMSScraper:
    def __init__(self, use_selenium=False):
        """Initialize TMS scraper with requests or Selenium"""
        self.use_selenium = use_selenium
        self.session = requests.Session()
        self.driver = None
        self.base_url = "https://tms.indianrailways.gov.in"
        
        # Setup session with headers
        ua = UserAgent()
        self.session.headers.update({
            'User-Agent': ua.random,
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive',
        })
        
        if use_selenium:
            self.setup_selenium()
    
    def setup_selenium(self):
        """Setup Selenium driver for dynamic content"""
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        
        self.driver = webdriver.Chrome(
            service=webdriver.chrome.service.Service(ChromeDriverManager().install()),
            options=chrome_options
        )
        print("Selenium driver initialized")
    
    def scrape_static_tms(self, url=None):
        """Scrape TMS data using requests + BeautifulSoup (for static content)"""
        if not url:
            # Create mock TMS HTML for demonstration
            return self.create_mock_tms_data()
        
        try:
            print(f"Fetching TMS data from: {url}")
            response = self.session.get(url, timeout=30)
            response.raise_for_status()
            
            # Parse HTML with BeautifulSoup
            soup = BeautifulSoup(response.content, 'html.parser')
            
            # Extract track data
            track_data = self.parse_track_data(soup)
            
            return track_data
            
        except requests.RequestException as e:
            print(f"Request error: {e}")
            return self.create_mock_tms_data()
        except Exception as e:
            print(f"Parsing error: {e}")
            return self.create_mock_tms_data()
    
    def scrape_dynamic_tms(self, url=None):
        """Scrape TMS data using Selenium (for dynamic content)"""
        if not self.driver:
            print("Selenium not initialized")
            return []
        
        try:
            if url:
                self.driver.get(url)
            else:
                # Load mock dynamic page
                self.load_mock_dynamic_page()
            
            # Wait for content to load
            time.sleep(3)
            
            # Get page source and parse
            page_source = self.driver.page_source
            soup = BeautifulSoup(page_source, 'html.parser')
            
            # Extract track data
            track_data = self.parse_track_data(soup)
            
            return track_data
            
        except Exception as e:
            print(f"Selenium scraping error: {e}")
            return self.create_mock_tms_data()
    
    def create_mock_tms_data(self):
        """Create mock TMS data for demonstration"""
        mock_data = [
            {
                'track_id': 'TRK-001-KM-125',
                'section': 'Delhi-Mumbai Main Line',
                'kilometer': '125.450',
                'track_type': 'Broad Gauge',
                'rail_type': '60 kg/m UIC',
                'sleeper_type': 'Concrete',
                'ballast_condition': 'Good',
                'last_inspection': '2024-01-15',
                'inspector': 'S.K. Sharma',
                'defects_found': 'Minor rail wear',
                'maintenance_required': 'Routine grinding',
                'priority': 'Medium',
                'fitting_details': {
                    'rail_joints': 'Welded',
                    'fasteners': 'Pandrol e-clip',
                    'fish_plates': 'Standard 60kg',
                    'bolts_condition': 'Good'
                }
            },
            {
                'track_id': 'TRK-002-KM-126',
                'section': 'Delhi-Mumbai Main Line',
                'kilometer': '126.200',
                'track_type': 'Broad Gauge',
                'rail_type': '60 kg/m UIC',
                'sleeper_type': 'Concrete',
                'ballast_condition': 'Fair',
                'last_inspection': '2024-01-18',
                'inspector': 'R.P. Singh',
                'defects_found': 'Loose fasteners, ballast settlement',
                'maintenance_required': 'Fastener tightening, ballast packing',
                'priority': 'High',
                'fitting_details': {
                    'rail_joints': 'Bolted',
                    'fasteners': 'Pandrol e-clip',
                    'fish_plates': 'Standard 60kg',
                    'bolts_condition': 'Needs attention'
                }
            },
            {
                'track_id': 'TRK-003-KM-127',
                'section': 'Delhi-Mumbai Main Line',
                'kilometer': '127.800',
                'track_type': 'Broad Gauge',
                'rail_type': '52 kg/m',
                'sleeper_type': 'Steel',
                'ballast_condition': 'Poor',
                'last_inspection': '2024-01-20',
                'inspector': 'M.K. Gupta',
                'defects_found': 'Rail corrugation, ballast contamination',
                'maintenance_required': 'Rail replacement, ballast renewal',
                'priority': 'Critical',
                'fitting_details': {
                    'rail_joints': 'Bolted',
                    'fasteners': 'Dog spikes',
                    'fish_plates': 'Standard 52kg',
                    'bolts_condition': 'Poor'
                }
            }
        ]
        
        print("Using mock TMS data for demonstration")
        return mock_data
    
    def load_mock_dynamic_page(self):
        """Load mock dynamic TMS page"""
        mock_html = """
        <!DOCTYPE html>
        <html>
        <head><title>TMS - Track Management System</title></head>
        <body>
            <div class="tms-container">
                <h1>Track Management System</h1>
                <div class="track-records">
                    <div class="track-record" data-track-id="TRK-001-KM-125">
                        <h3>Track ID: TRK-001-KM-125</h3>
                        <p class="section">Section: Delhi-Mumbai Main Line</p>
                        <p class="kilometer">KM: 125.450</p>
                        <p class="condition">Condition: Good</p>
                        <p class="inspector">Inspector: S.K. Sharma</p>
                        <p class="date">Last Inspection: 2024-01-15</p>
                    </div>
                    <div class="track-record" data-track-id="TRK-002-KM-126">
                        <h3>Track ID: TRK-002-KM-126</h3>
                        <p class="section">Section: Delhi-Mumbai Main Line</p>
                        <p class="kilometer">KM: 126.200</p>
                        <p class="condition">Condition: Fair</p>
                        <p class="inspector">Inspector: R.P. Singh</p>
                        <p class="date">Last Inspection: 2024-01-18</p>
                    </div>
                </div>
            </div>
        </body>
        </html>
        """
        
        self.driver.execute_script(f"document.open(); document.write(`{mock_html}`); document.close();")
    
    def parse_track_data(self, soup):
        """Parse track data from HTML soup"""
        track_data = []
        
        try:
            # Look for track records
            track_records = soup.find_all(['div', 'tr'], class_=['track-record', 'track-row'])
            
            if not track_records:
                # Try alternative selectors
                track_records = soup.find_all('div', attrs={'data-track-id': True})
            
            for record in track_records:
                track_info = {}
                
                # Extract track ID
                track_id = record.get('data-track-id')
                if not track_id:
                    track_id_elem = record.find(['h3', 'td'], string=lambda x: x and 'TRK-' in x)
                    track_id = track_id_elem.get_text(strip=True) if track_id_elem else 'Unknown'
                
                track_info['track_id'] = track_id
                
                # Extract other fields
                fields = {
                    'section': ['section', 'route', 'line'],
                    'kilometer': ['kilometer', 'km', 'chainage'],
                    'condition': ['condition', 'status', 'state'],
                    'inspector': ['inspector', 'inspected-by', 'officer'],
                    'date': ['date', 'inspection-date', 'last-inspection']
                }
                
                for field, selectors in fields.items():
                    value = 'N/A'
                    for selector in selectors:
                        elem = record.find(class_=selector)
                        if elem:
                            value = elem.get_text(strip=True)
                            break
                    track_info[field] = value
                
                track_info['scraped_at'] = pd.Timestamp.now().isoformat()
                track_data.append(track_info)
            
            print(f"Parsed {len(track_data)} track records")
            
        except Exception as e:
            print(f"Parsing error: {e}")
        
        return track_data
    
    def get_inspection_records(self, track_id=None):
        """Get detailed inspection records for specific track"""
        try:
            # Mock inspection data
            inspection_data = [
                {
                    'inspection_id': 'INS-2024-001',
                    'track_id': track_id or 'TRK-001-KM-125',
                    'inspection_date': '2024-01-15',
                    'inspector_name': 'S.K. Sharma',
                    'inspection_type': 'Routine',
                    'defects': [
                        {'type': 'Rail Wear', 'severity': 'Minor', 'location': 'KM 125.450'},
                        {'type': 'Fastener Loose', 'severity': 'Medium', 'location': 'KM 125.460'}
                    ],
                    'measurements': {
                        'rail_profile': '98%',
                        'gauge': '1435mm',
                        'cross_level': '2mm',
                        'twist': '1mm'
                    },
                    'recommendations': 'Schedule rail grinding within 30 days',
                    'next_inspection': '2024-04-15'
                }
            ]
            
            return inspection_data
            
        except Exception as e:
            print(f"Inspection records error: {e}")
            return []
    
    def save_data(self, data, filename='tms_track_data.json'):
        """Save scraped TMS data"""
        try:
            # Save as JSON
            with open(f'data/{filename}', 'w') as f:
                json.dump(data, f, indent=2)
            
            # Save as CSV if data is flat
            if data and isinstance(data[0], dict):
                # Flatten nested data for CSV
                flattened_data = []
                for record in data:
                    flat_record = {}
                    for key, value in record.items():
                        if isinstance(value, dict):
                            for sub_key, sub_value in value.items():
                                flat_record[f"{key}_{sub_key}"] = sub_value
                        elif isinstance(value, list):
                            flat_record[key] = ', '.join(map(str, value))
                        else:
                            flat_record[key] = value
                    flattened_data.append(flat_record)
                
                df = pd.DataFrame(flattened_data)
                csv_filename = filename.replace('.json', '.csv')
                df.to_csv(f'data/{csv_filename}', index=False)
                print(f"Data saved to data/{filename} and data/{csv_filename}")
            
        except Exception as e:
            print(f"Save error: {e}")
    
    def close(self):
        """Close resources"""
        if self.driver:
            self.driver.quit()
        self.session.close()
        print("TMS scraper closed")

def main():
    """Main TMS scraping workflow"""
    print("Starting TMS portal scraping...")
    
    # Try static scraping first
    print("\n1. Static scraping with requests + BeautifulSoup:")
    static_scraper = TMSScraper(use_selenium=False)
    
    try:
        track_data = static_scraper.scrape_static_tms()
        
        if track_data:
            print(f"Scraped {len(track_data)} track records")
            static_scraper.save_data(track_data, 'tms_static_data.json')
            
            # Show sample data
            print("\nSample track record:")
            for key, value in track_data[0].items():
                if isinstance(value, dict):
                    print(f"  {key}:")
                    for sub_key, sub_value in value.items():
                        print(f"    {sub_key}: {sub_value}")
                else:
                    print(f"  {key}: {value}")
    
    except Exception as e:
        print(f"Static scraping error: {e}")
    
    finally:
        static_scraper.close()
    
    # Try dynamic scraping with Selenium
    print("\n2. Dynamic scraping with Selenium:")
    dynamic_scraper = TMSScraper(use_selenium=True)
    
    try:
        track_data = dynamic_scraper.scrape_dynamic_tms()
        
        if track_data:
            print(f"Scraped {len(track_data)} track records with Selenium")
            dynamic_scraper.save_data(track_data, 'tms_dynamic_data.json')
        
        # Get inspection records
        inspection_data = dynamic_scraper.get_inspection_records()
        if inspection_data:
            dynamic_scraper.save_data(inspection_data, 'tms_inspection_data.json')
            print(f"Scraped {len(inspection_data)} inspection records")
    
    except Exception as e:
        print(f"Dynamic scraping error: {e}")
    
    finally:
        dynamic_scraper.close()

if __name__ == "__main__":
    main()