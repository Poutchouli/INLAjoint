#!/bin/bash

# Script to download and setup INLAjoint source code
# This will be run inside the Docker container

echo "Setting up INLAjoint source code..."

# Create directory for INLAjoint source
mkdir -p /srv/shiny-server/INLAjoint-source

# Download INLAjoint from CRAN
cd /tmp
echo "Downloading INLAjoint source package..."
R -e "download.packages('INLAjoint', destdir = '.', type = 'source')"

# Extract the source package
INLAJOINT_TAR=$(ls INLAjoint_*.tar.gz 2>/dev/null | head -1)

if [ -f "$INLAJOINT_TAR" ]; then
    echo "Extracting $INLAJOINT_TAR..."
    tar -xzf "$INLAJOINT_TAR"
    
    # Find the extracted directory
    INLAJOINT_DIR=$(ls -d INLAjoint*/ 2>/dev/null | head -1)
    
    if [ -d "$INLAJOINT_DIR" ]; then
        echo "Copying source files to /srv/shiny-server/INLAjoint-source..."
        cp -r "$INLAJOINT_DIR"* /srv/shiny-server/INLAjoint-source/
        
        # Set proper permissions
        chown -R shiny:shiny /srv/shiny-server/INLAjoint-source
        chmod -R 755 /srv/shiny-server/INLAjoint-source
        
        echo "✓ INLAjoint source setup completed!"
        ls -la /srv/shiny-server/INLAjoint-source/
    else
        echo "✗ Failed to find extracted INLAjoint directory"
    fi
else
    echo "✗ Failed to download INLAjoint source package"
fi

# Clean up
rm -f /tmp/INLAjoint_*.tar.gz
rm -rf /tmp/INLAjoint*/

echo "INLAjoint source setup finished."
