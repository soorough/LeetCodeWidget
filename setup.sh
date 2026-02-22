#!/bin/bash
set -e

echo "=== LeetCode Heatmap Widget Setup ==="

# Check for Xcode
if ! xcode-select -p &>/dev/null || [[ "$(xcode-select -p)" == */CommandLineTools ]]; then
    echo "Error: Xcode (not just Command Line Tools) is required."
    echo "Install Xcode from the App Store, then run:"
    echo "  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    exit 1
fi

# Install xcodegen if not present
if ! command -v xcodegen &>/dev/null; then
    echo "Installing XcodeGen via Homebrew..."
    if ! command -v brew &>/dev/null; then
        echo "Error: Homebrew is required. Install from https://brew.sh"
        exit 1
    fi
    brew install xcodegen
fi

# Generate Xcode project
echo "Generating Xcode project..."
cd "$(dirname "$0")"
xcodegen generate

echo ""
echo "=== Setup complete! ==="
echo "Open LeetCodeWidget.xcodeproj in Xcode to build and run."
echo ""
echo "Steps:"
echo "1. Open LeetCodeWidget.xcodeproj"
echo "2. Select your development team in Signing & Capabilities"
echo "3. Add App Group 'group.com.souravh.leetcodewidget' to both targets"
echo "4. Build and run the LeetCodeWidget scheme"
echo "5. Add the widget to your desktop via Widget Gallery"
