#!/bin/bash
set -e

echo "packing Lambda..."

# Go to project root 
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)

# Clean old build
rm -rf "$ROOT_DIR/scripts/build"
mkdir -p "$ROOT_DIR/scripts/build"

# Copy 
cp "$ROOT_DIR/app/lambda_function.py" "$ROOT_DIR/scripts/build/"

# Create zip
cd "$ROOT_DIR/scripts/build"
zip -r function.zip .

echo "Lambda package created at scripts/build/function.zip"