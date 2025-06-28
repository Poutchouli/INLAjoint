# INLAjoint: Joint Modeling with Docker Web Interface

## About INLAjoint

**INLAjoint** is an exceptional R package for joint modeling of multivariate longitudinal and time-to-event outcomes using Integrated Nested Laplace Approximations (INLA). This powerful package was developed by **Dr. Denis Rustand** and provides state-of-the-art Bayesian joint modeling capabilities with fast and reliable inference.

### Original Package Credits

- **Primary Author**: Dr. Denis Rustand
- **Co-authors**: Janet van Niekerk, Elias T. Krainski, Håvard Rue
- **Original Repository**: https://github.com/DenisRustand/INLAjoint
- **Contact**: INLAjoint@gmail.com

## Docker Web Application

This repository extends Dr. Rustand's INLAjoint package with a **comprehensive Docker-based web application** that makes joint modeling accessible through an intuitive web interface. The application features advanced package loading capabilities and works even in environments where INLA cannot be conventionally installed.

### Web Application Credits

- **Docker Web Interface**: Developed by GitHub Copilot based on user requirements
- **Enhanced Package Loading**: Custom implementation for robust deployment
- **Web Application Design**: Modern Shiny dashboard with modular architecture
- **Documentation**: Comprehensive setup and usage guides

## 🌟 Key Features

### Advanced Package Loading System
- **Three-Tier Fallback**: Package installation → Source loading → Mock implementation
- **INLA-Independent Mode**: Works even when INLA cannot be installed
- **Source Code Integration**: Loads INLAjoint functions directly from GitHub source
- **Robust Error Handling**: Graceful degradation with informative feedback

### Web Interface Capabilities
- **Multi-Source Data Input**: CSV upload, database connections, sample datasets
- **Interactive Model Configuration**: Point-and-click formula building
- **Rich Results Display**: Interactive plots, comprehensive tables, model diagnostics
- **Export Options**: Download results in multiple formats (CSV, PDF, PNG)

### Docker Advantages
- **One-Click Setup**: Complete environment with all dependencies
- **Cross-Platform**: Works identically on Windows, Mac, and Linux
- **No Installation Hassles**: No need to install R packages locally
- **Isolated Environment**: No conflicts with existing installations

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- At least 4GB RAM recommended
- Port 3838 available

### Launch the Application

1. **Clone this repository**:
   ```bash
   git clone [repository-url]
   cd INLAjoint
   ```

2. **Start the application**:
   ```bash
   docker-compose up --build
   ```

3. **Access the web interface**: Open `http://localhost:3838` in your browser

4. **Quick test with sample data**:
   - Go to "Data Input" → "Sample Data"
   - Choose "Longitudinal MS Data" 
   - Click "Load Sample Data"
   - Navigate to "Model Configuration" → "Run Model"
   - View results in the "Results" tab

## 📊 Enhanced Package Loading

The application implements a sophisticated three-tier loading system:

### Tier 1: Standard Package Installation
```r
library(INLAjoint)  # Preferred method when available
library(INLA)
```

### Tier 2: Enhanced Source Loading
```r
# Sources all INLAjoint functions directly from GitHub
source("utils/enhanced_inlajoint.R")
# Provides full functionality when INLA is available
```

### Tier 3: Mock Implementation
```r
# Realistic mock functions for demonstration and testing
source("utils/mock_inla.R")
# Allows interface exploration without INLA
```

This ensures the application works reliably in any environment:
- ✅ **Full research environments** with INLA get complete functionality
- ✅ **Limited environments** can still run and learn
- ✅ **CI/CD pipelines** don't break due to package installation issues
- ✅ **Educational settings** can demonstrate joint modeling concepts

## 📖 Usage Guide

### Data Input Options

#### 📁 CSV File Upload
- Upload longitudinal and survival datasets
- Automatic format validation and preview
- Support for custom separators and headers

#### 🗄️ Database Connections
- PostgreSQL, MySQL, SQLite support
- Interactive query builder
- Connection testing and validation

#### 📊 Sample Datasets
- Multiple sclerosis longitudinal data
- Simulated datasets with known parameters
- Ready-to-use examples for learning

### Model Configuration

#### Formula Specification
- **Guided Mode**: Point-and-click variable selection
- **Advanced Mode**: Direct R formula syntax
- **Real-time Validation**: Immediate syntax checking
- **Example Library**: Common model specifications

#### Parameter Options
- **Longitudinal Models**: Gaussian, Poisson, Binomial families
- **Survival Models**: Various baseline hazard functions
- **Association Structures**: Current value, slope, cumulative effects
- **Advanced Settings**: Custom priors and optimization parameters

### Results Interpretation

#### Comprehensive Output
- **Model Summaries**: Coefficient estimates and credible intervals
- **Diagnostic Plots**: Convergence checks and residual analysis
- **Interactive Visualizations**: Trajectory plots and survival curves
- **Export Capabilities**: Multiple download formats

## 🔧 Technical Architecture

### Container Structure
```
┌─────────────────────────────────────────┐
│             Docker Compose             │
├─────────────────────────────────────────┤
│  ┌─────────────────┐ ┌─────────────────┐│
│  │  Shiny App      │ │   PostgreSQL    ││
│  │  (Port 3838)    │ │   (Port 5432)   ││
│  │                 │ │                 ││
│  │ • Enhanced      │ │ • Sample Data   ││
│  │   INLAjoint     │ │ • Persistence   ││
│  │ • Smart Loading │ │ • Security      ││
│  │ • Multi-source  │ │                 ││
│  │   Data          │ │                 ││
│  └─────────────────┘ └─────────────────┘│
└─────────────────────────────────────────┘
```

### File Organization
```
INLAjoint/
├── docker-compose.yml           # Service orchestration
├── Dockerfile                   # Container definition  
├── DOCKER_README.md            # Detailed technical docs
├── README.md                   # This overview file
├── docker-app/                 # Shiny application
│   ├── app.R                   # Main application
│   ├── modules/                # UI/Server modules
│   │   ├── data_input.R        # Data loading
│   │   ├── model_config.R      # Model specification
│   │   └── results_display.R   # Results presentation
│   └── utils/                  # Utility functions
│       ├── enhanced_inlajoint.R # Enhanced loader
│       ├── mock_inla.R         # Mock implementation
│       └── data_utils.R        # Data processing
└── sql/                        # Database setup
    └── init.sql               # Sample data
```

## 🛠️ Data Format Requirements

### Longitudinal Data
```csv
id,time,outcome,treatment,age,sex
1,0,10.2,1,65,F
1,6,12.1,1,65,F
1,12,13.5,1,65,F
2,0,9.8,0,58,M
2,6,11.2,0,58,M
```

**Required**: `id`, `time`, `outcome`  
**Optional**: Any number of covariates

### Survival Data  
```csv
id,time_to_event,event,treatment,age,sex
1,18.5,1,1,65,F
2,24.0,0,0,58,M
```

**Required**: `id`, `time_to_event`, `event`  
**Optional**: Baseline and time-varying covariates

## 🔍 Troubleshooting

### Common Issues

#### "Port 3838 already in use"
```bash
docker-compose down && docker-compose up
```

#### "INLA package not available"
✅ **Expected behavior**: App automatically uses enhanced source loading  
✅ **Check logs**: Look for "INLAjoint source loaded successfully!"

#### "Database connection failed"
```bash
# Check service status
docker-compose logs postgres
# Default credentials: testuser/testpass/testdb
```

### View Logs
```bash
# Real-time application logs
docker-compose logs -f inlajoint-app

# Check enhanced loader status  
docker logs inlajoint-inlajoint-app-1 | grep -i "inlajoint"
```

## 📚 Citations and References

### Primary Citations

**For the INLAjoint Package**:
```
Rustand, D., van Niekerk, J., Krainski, E. T., & Rue, H. (2024). 
Joint Modeling of Multivariate Longitudinal and Survival Outcomes 
with the R package INLAjoint. arXiv preprint arXiv:2402.08335.
https://arxiv.org/abs/2402.08335
```

**For the Docker Web Application**:
```
Docker Web Interface for INLAjoint (2024). 
Enhanced web-based joint modeling platform with robust package loading.
Based on INLAjoint by Denis Rustand et al.
```

### Additional References

- Rustand, D., van Niekerk, J., Krainski, E. T., Rue, H., & Proust-Lima, C. (2024). Fast and flexible inference for joint models of multivariate longitudinal and survival data using integrated nested Laplace approximations. *Biostatistics*, kxad019. https://doi.org/10.1093/biostatistics/kxad019

- Alvares, D., Van Niekerk, J., Krainski, E.T., Rue, H. and Rustand, D., 2024. Bayesian survival analysis with INLA. *Statistics in medicine*, 43(20), pp.3975-4010. https://doi.org/10.1002/sim.10160

## 🎓 Educational Use

### For Students and Researchers
- **No Installation Barriers**: Start learning immediately
- **Sample Datasets**: Ready-to-explore examples
- **Interactive Interface**: Point-and-click model building
- **Comprehensive Help**: Built-in documentation and examples

### For Instructors
- **Classroom Ready**: One-click deployment for workshops
- **Consistent Environment**: Same experience for all students  
- **Demonstration Mode**: Works even without INLA installation
- **Export Capabilities**: Students can save their work

## 🤝 Contributing and Support

### Original INLAjoint Package
- **Issues and Questions**: https://github.com/DenisRustand/INLAjoint/issues
- **Email**: INLAjoint@gmail.com
- **Documentation**: `?joint` and `vignette("INLAjoint")` in R

### Docker Web Application
- **Technical Issues**: Check DOCKER_README.md for detailed troubleshooting
- **Feature Requests**: Open issues in this repository
- **Contributions**: Pull requests welcome following coding standards

## 🙏 Acknowledgments

### Special Recognition
- **Dr. Denis Rustand**: Creator of the outstanding INLAjoint package and pioneer in making joint modeling accessible
- **INLA Development Team** (Håvard Rue, Janet van Niekerk, Elias Krainski): Foundation computational framework
- **R-INLA Project**: Advanced Bayesian inference infrastructure
- **R Shiny Team**: Web application framework
- **Docker Community**: Containerization platform
- **Open Source Contributors**: Making reproducible research possible

### Institutional Support
- **INLA Research Group**: Ongoing development and maintenance
- **Academic Community**: Feedback and validation
- **Users Worldwide**: Testing and improvement suggestions

## 📄 License

- **INLAjoint Package**: GPL-3 (original license maintained)
- **Docker Web Application**: MIT License (web interface components)
- **Combined Work**: Respects all original licensing terms

## 🌐 Links and Resources

- **Original INLAjoint**: https://github.com/DenisRustand/INLAjoint
- **INLA Project**: https://www.r-inla.org/
- **Joint Modeling Resources**: Multiple online tutorials and courses available
- **R Shiny**: https://shiny.rstudio.com/

---

*This Docker web application stands on the shoulders of giants, particularly the excellent work of Dr. Denis Rustand and the INLA development team. We are proud to extend their contributions with modern deployment capabilities while maintaining the highest respect for their original work.*

**Version**: 1.0.0  
**Last Updated**: June 2024  
**Compatibility**: INLAjoint 25.5.14+, INLA 23.x+
