#!/bin/bash

# Ensure it doesn't exit on error, or you can choose to enable set -e
# set -e

# Define directories
EXAMPLES_DIR="examples"
# Intermediate build output directory
BUILD_DIR=".build_examples"
# Final directory for extracted zip files
DIST_DIR="dist_examples"

# Get the absolute path when the script is running
ROOT_DIR=$(pwd)
EXAMPLES_ABS_DIR="$ROOT_DIR/$EXAMPLES_DIR"
DIST_ABS_DIR="$ROOT_DIR/$DIST_DIR"

echo "🧹 Preparation: Cleaning and creating directories..."
rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$DIST_DIR"

echo "🚀 Starting batch packaging of projects in the examples directory..."

# Iterate over all .json files in the examples directory
for config_file in "$EXAMPLES_ABS_DIR"/*.json; do
  # Defensive check: if there are no json files in the directory, skip
  [ -e "$config_file" ] || continue

  # Extract the filename to use as the generated project name, e.g., comic-explainer
  project_name=$(basename "$config_file" .json)
  
  echo "=================================================="
  echo "📦 Processing project: $project_name"
  
  # Enter the intermediate build directory
  cd "$ROOT_DIR/$BUILD_DIR" || exit
  
  # 1. Execute the create command
  echo ">> Executing skillpack creation..."
  npx @cremini/skillpack create "$project_name" --config "$config_file"
  
  # If the directory is generated normally, enter it to package
  if [ -d "$project_name" ]; then
    cd "$project_name" || exit
    
    # 2. Execute the zip command
    echo ">> Executing zip packaging..."
    npx @cremini/skillpack zip
    
    # 3. Extract the generated zip package to the centralized directory
    # Use ls to check if any zip file is generated
    if ls *.zip 1> /dev/null 2>&1; then
      mv *.zip "$DIST_ABS_DIR/"
      echo "✅ Successfully extracted zip to $DIST_DIR directory."
    else
      echo "⚠️ Warning: Packaging finished, but no .zip file was found!"
    fi
  else
    echo "❌ Error: Intermediate project directory $project_name was not generated, skipping packaging."
  fi
done

# Finally, return to the root directory
cd "$ROOT_DIR" || exit

echo "=================================================="
echo "🎉 Batch packaging process completed!"
echo "📂 Intermediate products directory: $BUILD_DIR"
echo "🎁 All ZIP packages storage directory: $DIST_DIR"
