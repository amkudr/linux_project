#!/bin/bash

# Clean up folders
sudo rm -rf images Q5_B/export Q5_C/images
mkdir -p images Q5_B/export Q5_C/images

# Create shared folder for images (if not exists)
mkdir -p images

# Build Docker images 
cd Q5_B
echo "Building image for image creator..."
docker build -t q5image_b .
cd ../Q5_C
echo "Building image for watermark..."
docker build -t java_watermark .

# Run Docker containers
cd ../Q5_B
echo "Running container to create images..."
docker run --rm -v $(pwd)/export:/app/output q5image_b "$@"
cd ..
sudo mv Q5_B/export/* Q5_C/images
cd Q5_C
echo "Running container to add watermark to images..."
docker run --rm -v $(pwd)/images:/app/images java_watermark /app/images

# Move images to the shared folder
cd ..
mv Q5_C/images/* images

# Clean up
rm -r Q5_B/export
rm -r Q5_C/images
echo "All tasks done! Check the 'images' folder."

# Remove Docker images 
echo "Removing Docker images..."
docker rmi q5image_b java_watermark

echo "Done!"
