# INLAjoint Docker Web Application

A comprehensive Dockerized R Shiny web application for joint modeling using the INLAjoint package. This application provides an intuitive interface for fitting joint longitudinal and survival models with advanced data handling and enhanced package loading capabilities.

## Credits and Acknowledgments

This application is built upon the excellent **INLAjoint** package developed by **Dr. Denis Rustand**. The INLAjoint package provides state-of-the-art Bayesian joint modeling capabilities using the INLA (Integrated Nested Laplace Approximations) approach.

- **Original INLAjoint Package**: Dr. Denis Rustand
- **Package Repository**: https://github.com/DenisRustand/INLAjoint
- **Docker Web Application**: GitHub Copilot (based on user requirements)

We gratefully acknowledge Dr. Rustand's outstanding contribution to the joint modeling community and his work in making advanced Bayesian joint models accessible to researchers worldwide.

## Features

### 🌟 Enhanced Package Loading
- **Smart Fallback System**: Automatically detects and adapts to different environments
- **Source Code Loading**: Can load INLAjoint functions directly from source code if package installation fails
- **INLA-Free Mode**: Provides realistic mock modeling when INLA is unavailable
- **Robust Error Handling**: Graceful degradation with informative user feedback

### 📊 Multiple Data Sources
- **CSV File Upload**: Drag-and-drop or browse file upload with preview
- **Database Connections**: PostgreSQL, MySQL, SQLite support with query builder
- **Sample Datasets**: Built-in datasets for immediate testing and learning
- **Data Validation**: Automatic format checking and error reporting

### 🔧 Advanced Model Configuration
- **Interactive Formula Builder**: Point-and-click formula construction
- **Parameter Optimization**: Intelligent default suggestions
- **Association Modeling**: Flexible association structures
- **Real-time Validation**: Immediate feedback on model specifications

### 📈 Rich Results Display
- **Interactive Visualizations**: Dynamic plots with zoom and pan
- **Comprehensive Tables**: Sortable and filterable result tables
- **Model Diagnostics**: Convergence checks and diagnostic plots
- **Export Options**: Download results in multiple formats (CSV, PDF, PNG)

### 🐳 Docker Advantages
- **One-Click Setup**: Complete environment with all dependencies
- **Consistent Environment**: Works the same on Windows, Mac, and Linux
- **No Installation Hassles**: No need to install R packages locally
- **Isolated Environment**: No conflicts with existing R installations

## Quick Start Guide

### Prerequisites

- Docker and Docker Compose installed on your system
- At least 4GB RAM recommended for optimal performance
- Port 3838 available (or modify in docker-compose.yml)

### 🚀 Launch the Application

1. **Clone or download** this repository to your local machine
2. **Navigate** to the project directory in your terminal
3. **Build and run** the containers:

   ```bash
   docker-compose up --build
   ```

4. **Access the application** at: `http://localhost:3838`

### 🎯 Quick Test with Sample Data

1. Open the application in your browser
2. Navigate to the **"Data Input"** tab
3. Select **"Sample Data"** from the data source options
4. Choose a sample dataset (e.g., "Longitudinal MS Data")
5. Click **"Load Sample Data"**
6. Go to **"Model Configuration"** and click **"Run Model"**
7. View results in the **"Results"** tab

## Enhanced Package Loading System

The application implements a sophisticated three-tier loading system to ensure it works in any environment:

### Tier 1: Standard Package Installation
```r
# Attempts normal package installation
library(INLAjoint)
library(INLA)
```

### Tier 2: Enhanced Source Loading
```r
# If package installation fails, loads from source
source("utils/enhanced_inlajoint.R")
# Sources all INLAjoint functions directly from GitHub
# Provides full functionality when INLA is available
```

### Tier 3: Mock Implementation
```r
# If both above fail, provides realistic mock functions
source("utils/mock_inla.R")
# Generates realistic results for demonstration and testing
# Allows users to explore the interface without INLA
```

This ensures that:
- ✅ **Researchers with INLA** get full functionality
- ✅ **Users without INLA** can still explore and learn
- ✅ **Demonstration environments** work reliably
- ✅ **CI/CD pipelines** don't break due to package issues
- Prepare your longitudinal and survival data in CSV format
## Detailed Usage Guide

### 1. Data Input Options

#### 📁 CSV File Upload
Perfect for local datasets, one-time analyses, and quick prototyping:
1. Prepare your data in CSV format (see format requirements below)
2. Use the file upload interface in the "Data Input" tab
3. Preview your data to verify correct loading
4. Specify ID and time variables for longitudinal data

#### 🗄️ Database Connection
Perfect for large datasets, production environments, and automated workflows:
- **PostgreSQL** (recommended for large datasets)
- **MySQL/MariaDB**
- **SQLite** (good for local development)

Steps:
1. Enter connection details in the database configuration panel
2. Test connection to verify accessibility
3. Write SQL queries to extract your data
4. Preview results before loading into the model

#### 📊 Sample Datasets
Perfect for learning, testing, and demonstrations:
- **Longitudinal MS Data**: Multiple sclerosis progression data
- **Simulated Longitudinal**: Generated data with known parameters
- **Survival MS Data**: Time-to-event outcomes
- **Simulated Survival**: Generated survival data

### 2. Model Configuration

The application provides both **guided** and **advanced** formula entry:

**Guided Mode** (Recommended for beginners):
- Point-and-click variable selection
- Automatic syntax generation
- Real-time validation
- Example formulas for reference

**Advanced Mode** (For experienced users):
- Direct R formula syntax entry
- Full flexibility for complex models
- Syntax highlighting and validation
- Custom function support

## Data Format Requirements

### Longitudinal Data Structure
```csv
id,time,outcome,treatment,age,sex
1,0,10.2,1,65,F
1,6,12.1,1,65,F
1,12,13.5,1,65,F
2,0,9.8,0,58,M
2,6,11.2,0,58,M
2,12,10.5,0,58,M
```

**Required columns**:
- `id`: Subject identifier (numeric or character)
- `time`: Time point (numeric, 0 = baseline)
- `outcome`: Longitudinal outcome (numeric)

### Survival Data Structure
```csv
id,time_to_event,event,treatment,age,sex
1,18.5,1,1,65,F
2,24.0,0,0,58,M
3,12.3,1,1,72,F
```

**Required columns**:
- `id`: Subject identifier (must match longitudinal data)
- `time_to_event`: Time to event or censoring (numeric)
- `event`: Event indicator (1 = event, 0 = censored)

## Troubleshooting Guide

### 🔧 Common Issues and Solutions

#### "Port 3838 already in use"
```bash
# Solution 1: Stop existing containers
docker-compose down
docker-compose up

# Solution 2: Use different port
# Edit docker-compose.yml: "3839:3838"
```

#### "INLA package not available"
```
✅ Expected behavior: App automatically switches to enhanced mode
✅ Check logs: Look for "Using enhanced INLAjoint loader" message
✅ Verify functionality: Mock results should still be generated
```

#### "Database connection failed"
```bash
# Check database service
docker-compose logs postgres

# Verify credentials in docker-compose.yml
# Default: testuser/testpass/testdb
```

#### "Model fitting takes too long"
1. Use sample data for initial testing
2. Reduce data size for complex models
3. Simplify model specification
4. Check available memory (4GB+ recommended)

### 📊 View Application Logs
```bash
# Real-time logs
docker-compose logs -f inlajoint-app

# Recent logs
docker-compose logs --tail=100 inlajoint-app
```

## Citations and References

### Primary Citation
If you use this application in your research, please cite:

```
Rustand, D., van Niekerk, J., Krainski, E. T., & Rue, H. (2024). 
Joint Modeling of Multivariate Longitudinal and Survival Outcomes 
with the R package INLAjoint. arXiv preprint arXiv:2402.08335.
```

### Acknowledgments

Special thanks to:
- **Dr. Denis Rustand** for the excellent INLAjoint package and his pioneering work in joint modeling
- **INLA Development Team** for the computational framework
- **R Shiny Team** for the web application framework
- **Open Source Community** for making this possible

## License

This Docker web application is provided under the MIT License. The underlying INLAjoint package retains its original GPL-3 license.

---

*For questions about the INLAjoint package, please contact Dr. Denis Rustand via the GitHub repository.*
*For questions about this Docker application, please open an issue in the project repository.*
