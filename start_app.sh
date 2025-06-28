#!/bin/bash

# Build and run INLAjoint Docker application

echo "INLAjoint Docker Setup"
echo "====================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

# Function to check if port is available
check_port() {
    local port=$1
    if netstat -tuln | grep -q ":$port "; then
        echo "Warning: Port $port is already in use."
        echo "Please stop any service using port $port or modify docker-compose.yml"
        return 1
    fi
    return 0
}

# Check if required ports are available
echo "Checking port availability..."
if ! check_port 3838; then
    echo "Port 3838 (Shiny app) is in use."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

if ! check_port 5432; then
    echo "Port 5432 (PostgreSQL) is in use."
    echo "This is optional if you don't need the PostgreSQL service."
fi

# Create necessary directories
echo "Creating directories..."
mkdir -p data
mkdir -p logs

# Build and start the application
echo "Building Docker images..."
docker-compose build

echo "Starting services..."
docker-compose up -d

# Wait for services to start
echo "Waiting for services to start..."
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo ""
    echo "✅ INLAjoint application is now running!"
    echo ""
    echo "🌐 Web Interface: http://localhost:3838"
    echo "📊 PostgreSQL (optional): localhost:5432"
    echo ""
    echo "📋 Database credentials (for testing):"
    echo "   Database: testdb"
    echo "   Username: testuser"
    echo "   Password: testpass"
    echo ""
    echo "📖 For help and documentation, see the Help tab in the web interface"
    echo ""
    echo "🔧 To view logs: docker-compose logs inlajoint-app"
    echo "🛑 To stop: docker-compose down"
    echo ""
else
    echo "❌ Error: Services failed to start properly."
    echo "Check logs with: docker-compose logs"
    exit 1
fi
