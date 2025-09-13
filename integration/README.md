# Portal Integration System

## Overview
Automated integration system for scraping and synchronizing data from Indian Railways UDM and TMS portals using Selenium and BeautifulSoup.

## Components

### 1. UDM Scraper (`scrapers/udm_scraper.py`)
- **Purpose**: Scrape parts inventory data from UDM portal
- **Technology**: Selenium WebDriver + BeautifulSoup
- **Features**:
  - Headless browser automation
  - Mock login simulation for demonstration
  - Parts inventory data extraction
  - JSON/CSV data export

### 2. TMS Scraper (`scrapers/tms_scraper.py`)
- **Purpose**: Extract track management and inspection data
- **Technology**: Requests + BeautifulSoup (static) or Selenium (dynamic)
- **Features**:
  - Dual scraping approach (static/dynamic)
  - Track fitting and inspection records
  - Mock data generation for testing

### 3. Integration Manager (`integration_manager.py`)
- **Purpose**: Coordinate data synchronization and reporting
- **Features**:
  - Automated scheduling
  - Data quality assessment
  - Sync reporting
  - Recommendations generation

## Installation

```bash
pip install -r requirements.txt
```

## Usage

### Individual Scrapers

**UDM Portal:**
```python
python scrapers/udm_scraper.py
```

**TMS Portal:**
```python
python scrapers/tms_scraper.py
```

### Full Integration
```python
python integration_manager.py
```

## Data Structure

### UDM Parts Data
```json
{
  "part_id": "BP-2024-001",
  "part_name": "Brake Pad Assembly",
  "category": "Brake System",
  "quantity": 45,
  "status": "Active",
  "location": "Warehouse-A-01",
  "last_updated": "2024-01-15"
}
```

### TMS Track Data
```json
{
  "track_id": "TRK-001-KM-125",
  "section": "Delhi-Mumbai Main Line",
  "kilometer": "125.450",
  "ballast_condition": "Good",
  "last_inspection": "2024-01-15",
  "inspector": "S.K. Sharma",
  "priority": "Medium"
}
```

## Features

### UDM Scraper
- **Headless Operation**: Runs without GUI for server deployment
- **Mock Authentication**: Simulates login for demonstration
- **Data Validation**: Checks data quality and completeness
- **Multiple Formats**: Exports JSON and CSV

### TMS Scraper
- **Flexible Scraping**: Handles both static and dynamic content
- **Track Records**: Extracts track condition and maintenance data
- **Inspection Data**: Retrieves detailed inspection records
- **Error Handling**: Graceful fallback to mock data

### Integration Manager
- **Scheduled Sync**: Automatic data synchronization every 6 hours
- **Quality Assessment**: Data quality scoring (0-100)
- **Reporting**: Daily reports with actionable recommendations
- **Error Recovery**: Robust error handling and logging

## Configuration

### Browser Settings
- Headless mode for production
- Custom user agents to avoid detection
- Optimized timeouts and waits

### Data Processing
- Standardized data formats
- Quality scoring algorithms
- Duplicate detection and handling

## Scheduling

The integration manager supports automated scheduling:

```python
# Every 6 hours
schedule.every(6).hours.do(run_full_sync)

# Daily reports at 8 AM
schedule.every().day.at("08:00").do(generate_daily_report)
```

## Output Files

### Data Files
- `udm_parts_data.json/csv` - UDM inventory data
- `tms_track_data.json/csv` - TMS track records
- `tms_inspection_data.json` - Inspection records

### Reports
- `sync_report.json` - Latest synchronization status
- `daily_report_YYYYMMDD.json` - Daily summary reports

## Error Handling

- **Network Issues**: Retry logic with exponential backoff
- **Authentication Failures**: Fallback to mock data
- **Parsing Errors**: Graceful degradation with logging
- **Resource Cleanup**: Proper browser and session cleanup

## Security Considerations

- **Credentials**: Use environment variables for real credentials
- **Rate Limiting**: Respectful scraping with delays
- **User Agents**: Rotate user agents to avoid detection
- **Session Management**: Proper cookie and session handling

## Deployment

### Local Development
```bash
python integration_manager.py
```

### Production Deployment
- Use environment variables for configuration
- Set up logging and monitoring
- Configure scheduled tasks (cron/systemd)
- Implement data backup strategies

## File Structure
```
integration/
├── scrapers/
│   ├── udm_scraper.py      # UDM portal scraper
│   └── tms_scraper.py      # TMS portal scraper
├── data/                   # Output data directory
├── integration_manager.py  # Main coordination script
├── requirements.txt        # Dependencies
└── README.md              # This file
```