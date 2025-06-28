# INLAjoint Docker Web Interface

A Docker-based web application for the INLAjoint R package, providing an easy-to-use interface for joint modeling of longitudinal and survival data.

## Features

- **Web Interface**: User-friendly Shiny dashboard
- **Multiple Data Sources**: 
  - CSV file upload
  - Database connections (PostgreSQL, MySQL, SQLite)
  - Built-in sample datasets
- **Database Support**: Easy connection to external databases
- **Interactive Results**: Plots, tables, and model summaries
- **Export Capabilities**: Download results in various formats
- **Docker Deployment**: Easy setup and deployment

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- At least 4GB RAM recommended
- Port 3838 available

### Launch the Application

1. Clone or download this repository
2. Navigate to the project directory
3. Build and run the Docker containers:

```bash
docker-compose up --build
```

4. Open your web browser and go to: `http://localhost:3838`

### Using Sample Data

The application includes sample datasets to help you get started:
- Navigate to "Data Input" tab
- Select "Sample Data"
- Choose a sample dataset
- Click "Load Sample Data"

## Usage Guide

### 1. Data Input

#### CSV Upload
- Prepare your longitudinal and survival data in CSV format
- Upload files using the web interface
- Specify column separators and headers

#### Database Connection
- Support for PostgreSQL, MySQL, and SQLite
- Enter connection details
- Write SQL queries to extract your data
- Test connection before loading data

### 2. Model Configuration

- **Formulas**: Specify longitudinal and survival model formulas
- **Parameters**: Choose appropriate families and baseline risks
- **Association**: Define how longitudinal and survival components relate
- **Advanced Options**: Configure priors and control parameters

### 3. Results

- **Summary**: Model coefficients and fit statistics
- **Plots**: Diagnostic plots and visualizations
- **Predictions**: Generate individual and population predictions
- **Export**: Download results in various formats

## Data Format Requirements

### Longitudinal Data
```csv
id,time,outcome,covariate1,covariate2
1,0,10.2,0,25
1,1,12.1,0,25
1,2,13.5,0,25
2,0,9.8,1,30
2,1,11.2,1,30
```

### Survival Data
```csv
id,time_to_event,event,covariate1,covariate2
1,5.2,1,0,25
2,3.1,0,1,30
```

## Architecture

### Technology Stack
- **Frontend**: Shiny Dashboard with Bootstrap styling
- **Backend**: R with INLAjoint package
- **Database**: Support for PostgreSQL, MySQL, SQLite
- **Containerization**: Docker with rocker/shiny base image
- **Dependencies**: INLA, database connectors, data manipulation packages

### File Structure
```
.
├── Dockerfile                 # Docker image definition
├── docker-compose.yml        # Docker Compose configuration
├── docker-app/              # Shiny application
│   ├── app.R                # Main application file
│   ├── modules/             # Shiny modules
│   ├── utils/               # Utility functions
│   └── help/                # Help documentation
└── sql/                     # Database initialization
```

## Configuration

### Environment Variables

- `SHINY_LOG_STDERR`: Enable/disable logging (default: 1)

### Volumes

- `./data`: Local data directory (mounted to container)
- `./logs`: Application logs
- `postgres_data`: PostgreSQL data persistence

### Ports

- `3838`: Shiny application
- `5432`: PostgreSQL (optional)

## Database Examples

### PostgreSQL Connection
```
Host: postgres (or localhost if external)
Port: 5432
Database: testdb
Username: testuser
Password: testpass
```

### Sample Queries
```sql
-- Longitudinal data
SELECT id, time, outcome, treatment, age 
FROM longitudinal_data;

-- Survival data
SELECT id, time_to_event, event, treatment, age 
FROM survival_data;
```

## Troubleshooting

### Common Issues

1. **Port 3838 already in use**
   ```bash
   docker-compose down
   # Wait a moment, then
   docker-compose up
   ```

2. **Out of memory errors**
   - Increase Docker memory allocation to 4GB+
   - Simplify model complexity for large datasets

3. **Database connection fails**
   - Check firewall settings
   - Verify database credentials
   - Ensure database service is running

4. **Model fitting takes too long**
   - Use sample data for testing
   - Reduce model complexity
   - Consider data subsetting

### Logs

View application logs:
```bash
docker-compose logs inlajoint-app
```

View PostgreSQL logs:
```bash
docker-compose logs postgres
```

## Advanced Usage

### Custom Database Setup

To use your own database:

1. Modify `docker-compose.yml` to point to your database
2. Update connection parameters in the web interface
3. Ensure your database is accessible from the Docker container

### Data Persistence

- Uploaded CSV files are temporary (lost on container restart)
- Database data persists in Docker volumes
- Export results to preserve analysis outputs

### Scaling

For production deployment:
- Use external database server
- Configure reverse proxy (nginx)
- Set up SSL certificates
- Monitor resource usage

## Development

### Local Development Setup

1. Install R and required packages locally
2. Run the Shiny app directly:
   ```r
   shiny::runApp("docker-app", port = 3838)
   ```

### Adding Features

- Modify modules in `docker-app/modules/`
- Add utility functions in `docker-app/utils/`
- Update help documentation in `docker-app/help/`

### Testing

Test with sample data before using production data:
- Use built-in sample datasets
- Verify model specifications
- Check result interpretations

## Support

### INLAjoint Package
- Documentation: `?joint` in R console
- Vignette: `vignette("INLAjoint")`
- Email: INLAjoint@gmail.com
- GitHub: https://github.com/DenisRustand/INLAjoint

### Docker Interface
- Check logs for error messages
- Verify data format requirements
- Ensure sufficient system resources

## License

This Docker interface is provided as-is. The INLAjoint package is licensed under GPL-3.

## Citation

If you use this software in your research, please cite:

Rustand, D., van Niekerk, J., Krainski, E. T., & Rue, H. (2024). Joint Modeling of Multivariate Longitudinal and Survival Outcomes with the R package INLAjoint. arXiv preprint arXiv:2402.08335.
