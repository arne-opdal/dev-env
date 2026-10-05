#!/bin/bash
set -e

echo "🔧 Running post-create setup..."

# Upgrade pip
echo "📦 Upgrading pip..."
pip install --upgrade pip

# Install Python runtime requirements
if [ -f "requirements.txt" ]; then
    echo "📦 Installing runtime dependencies (aoscx, netbox)..."
    pip install -r requirements.txt
else
    echo "⚠️  requirements.txt not found, skipping..."
fi

# Install and setup pre-commit hooks
if [ -f ".pre-commit-config.yaml" ]; then
    echo "🪝 Setting up pre-commit hooks..."
    pre-commit install
    pre-commit install --hook-type commit-msg
    echo "✅ Pre-commit hooks installed"
else
    echo "⚠️  .pre-commit-config.yaml not found, skipping pre-commit setup..."
fi

echo ""
echo "✅ Post-create setup complete!"
echo ""
