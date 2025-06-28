# INLAjoint Web Interface Help

## Overview

This web interface provides an easy-to-use platform for fitting joint models using the INLAjoint R package. Joint models simultaneously analyze longitudinal and time-to-event data, accounting for their correlation.

## Getting Started

### 1. Data Input

Choose your data source:

- **Upload CSV Files**: Upload your own longitudinal and survival datasets in CSV format
- **Database Connection**: Connect to PostgreSQL, MySQL, or SQLite databases
- **Sample Data**: Use built-in example datasets to explore functionality

#### CSV Upload Requirements

**Longitudinal Data:**
- Each row represents one observation for one individual
- Must include: ID variable, time variable, outcome variable
- Optional: covariates, multiple outcomes

**Survival Data:**
- One row per individual (optional if survival info is in longitudinal data)
- Must include: ID variable, time-to-event, event indicator (0/1)

#### Database Connection

Supported databases:
- **PostgreSQL**: Enterprise-grade open source database
- **MySQL/MariaDB**: Popular open source database
- **SQLite**: Lightweight file-based database

Connection requirements:
- Host and port (for PostgreSQL/MySQL)
- Database name
- Username and password (except SQLite)

### 2. Model Configuration

#### Formulas

**Longitudinal Formula**: Uses lme4 syntax
```r
# Basic random intercept model
outcome ~ time + covariate + (1 | id)

# Random intercept and slope
outcome ~ time + covariate + (1 + time | id)

# Multiple covariates
outcome ~ time + age + treatment + (1 + time | id)
```

**Survival Formula**: Uses INLA survival syntax
```r
# Basic survival model
inla.surv(time_to_event, event) ~ age + treatment

# With competing risks
inla.surv(time_to_event, event, Etype) ~ age + treatment
```

#### Model Parameters

- **Family**: Distribution for longitudinal outcome
  - Gaussian: Continuous outcomes
  - Poisson: Count data
  - Binomial: Binary outcomes
  - Gamma: Positive continuous data

- **Baseline Risk**: Hazard function shape
  - Random Walk 1/2: Flexible, non-parametric
  - Exponential: Constant hazard
  - Weibull: Flexible parametric

#### Association Structures

- **Current Value (CV)**: Links current outcome level to hazard
- **Current Slope (CS)**: Links rate of change to hazard
- **CV + CS**: Both current value and slope
- **Shared Random Effects (SRE)**: Links individual deviations
- **No Association**: Independent models

### 3. Results Interpretation

#### Model Summary
- Fixed effects estimates and confidence intervals
- Random effects variance components
- Model fit statistics

#### Diagnostic Plots
- Longitudinal trajectories by individual
- Survival curves
- Residual plots for model checking
- Random effects distributions

#### Predictions
- Individual-specific predictions
- Population-level estimates
- Survival probabilities

## Advanced Features

### Prior Specifications
- Gaussian priors for fixed effects
- Inverse Wishart for random effects
- Penalized complexity priors for smoothing

### Control Options
- Silent mode: Suppress output during fitting
- Data only: Prepare data without fitting
- Custom initial values

## Data Requirements

### Longitudinal Data Structure
```
id  time  outcome  covariate1  covariate2
1   0     10.2     0           25
1   1     12.1     0           25
1   2     13.5     0           25
2   0     9.8      1           30
2   1     11.2     1           30
```

### Survival Data Structure
```
id  time_to_event  event  covariate1  covariate2
1   5.2           1      0           25
2   3.1           0      1           30
```

## Troubleshooting

### Common Issues

1. **Model fails to converge**
   - Check data quality and missing values
   - Simplify model (fewer random effects)
   - Adjust prior specifications

2. **Database connection fails**
   - Verify host, port, credentials
   - Check firewall settings
   - Ensure database is running

3. **CSV upload errors**
   - Check file encoding (use UTF-8)
   - Verify column separators
   - Remove special characters from headers

### Error Messages

- "ID variable not found": Check variable names match exactly
- "Time variable should be numeric": Convert time to numeric format
- "Insufficient observations": Need at least 2 observations per individual

## Technical Details

### Software Stack
- **R**: Statistical computing language
- **Shiny**: Web application framework
- **INLAjoint**: Joint modeling package
- **INLA**: Bayesian inference engine
- **Docker**: Containerization platform

### Performance Notes
- Model fitting time depends on:
  - Sample size
  - Model complexity
  - Number of random effects
  - Baseline risk specification

- Large datasets (>10,000 observations) may take several minutes
- Consider simplifying models for initial exploration

## References

1. Rustand, D., et al. (2024). Joint Modeling of Multivariate Longitudinal and Survival Outcomes with the R package INLAjoint. arXiv preprint arXiv:2402.08335.

2. Rue, H., Martino, S., & Chopin, N. (2009). Approximate Bayesian inference for latent Gaussian models by using integrated nested Laplace approximations. Journal of the Royal Statistical Society, 71(2), 319-392.

## Support

For technical issues or questions about the INLAjoint package:
- Email: INLAjoint@gmail.com
- GitHub: https://github.com/DenisRustand/INLAjoint

For web interface issues:
- Check Docker logs for error messages
- Ensure all dependencies are installed
- Verify data format requirements
