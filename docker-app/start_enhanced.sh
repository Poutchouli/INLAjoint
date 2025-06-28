#!/bin/bash

# Enhanced INLAjoint Docker Startup Script
echo "=================================================="
echo "INLAjoint Docker Web Application"
echo "Enhanced with Three-Tier Package Loading"
echo "=================================================="
echo ""
echo "🚀 Starting enhanced INLAjoint web application..."
echo ""
echo "📦 Package Loading System:"
echo "   Tier 1: Standard package installation"
echo "   Tier 2: Enhanced source code loading"  
echo "   Tier 3: Mock implementation fallback"
echo ""
echo "👨‍🔬 Credits:"
echo "   Original INLAjoint Package: Dr. Denis Rustand"
echo "   Docker Web Interface: GitHub Copilot"
echo ""
echo "🌐 Access the application at: http://localhost:3838"
echo "=================================================="
echo ""

# Start the standard shiny server
exec /usr/bin/shiny-server
