#!/bin/bash
set -e

echo "🚀 Packaging Lambda..."

# Go to project root (safe execution)
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)

# Clean previous build
rm -rf "$ROOT_DIR/scripts/build"
mkdir -p "$ROOT_DIR/scripts/build"

# Copy app code
cp "$ROOT_DIR/app/lambda_function.py" "$ROOT_DIR/scripts/build/"

# (Optional) Install dependencies if requirements.txt exists
if [ -f "$ROOT_DIR/app/requirements.txt" ]; then
  echo "📦 Installing dependencies..."
  pip install -r "$ROOT_DIR/app/requirements.txt" -t "$ROOT_DIR/scripts/build/"
fi

# Create zip
cd "$ROOT_DIR/scripts/build"
zip -r function.zip .

echo "✅ Lambda package created at scripts/build/function.zip"