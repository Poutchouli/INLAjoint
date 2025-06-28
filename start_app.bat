@echo off
REM Build and run INLAjoint Docker application on Windows

echo INLAjoint Docker Setup
echo =====================

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo Error: Docker is not installed. Please install Docker Desktop first.
    echo Visit: https://docs.docker.com/desktop/windows/
    pause
    exit /b 1
)

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo Error: Docker Compose is not installed. Please install Docker Compose first.
    echo Visit: https://docs.docker.com/compose/install/
    pause
    exit /b 1
)

echo Checking Docker service...
docker info >nul 2>&1
if errorlevel 1 (
    echo Error: Docker service is not running. Please start Docker Desktop.
    pause
    exit /b 1
)

REM Create necessary directories
echo Creating directories...
if not exist "data" mkdir data
if not exist "logs" mkdir logs

REM Check if ports are available
echo Checking port availability...
netstat -an | findstr :3838 >nul
if not errorlevel 1 (
    echo Warning: Port 3838 is already in use.
    echo Please stop any service using port 3838 or modify docker-compose.yml
    set /p continue="Continue anyway? (y/N): "
    if /i not "%continue%"=="y" exit /b 1
)

REM Build and start the application
echo Building Docker images...
docker-compose build
if errorlevel 1 (
    echo Error: Failed to build Docker images.
    pause
    exit /b 1
)

echo Starting services...
docker-compose up -d
if errorlevel 1 (
    echo Error: Failed to start services.
    pause
    exit /b 1
)

REM Wait for services to start
echo Waiting for services to start...
timeout /t 15 /nobreak >nul

REM Check if services are running
docker-compose ps | findstr "Up" >nul
if errorlevel 1 (
    echo Error: Services failed to start properly.
    echo Check logs with: docker-compose logs
    pause
    exit /b 1
)

echo.
echo ✅ INLAjoint application is now running!
echo.
echo 🌐 Web Interface: http://localhost:3838
echo 📊 PostgreSQL (optional): localhost:5432
echo.
echo 📋 Database credentials (for testing):
echo    Database: testdb
echo    Username: testuser
echo    Password: testpass
echo.
echo 📖 For help and documentation, see the Help tab in the web interface
echo.
echo 🔧 To view logs: docker-compose logs inlajoint-app
echo 🛑 To stop: docker-compose down
echo.

REM Optionally open browser
set /p open_browser="Open web browser now? (Y/n): "
if /i not "%open_browser%"=="n" (
    start http://localhost:3838
)

pause
