#!/bin/bash

# Wurp Terminal - Build Script
# Usage: ./build.sh [command]
# Commands: build, run, publish, clean, help

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

show_help() {
    echo "🚀 Wurp Terminal - Build Script"
    echo "================================"
    echo ""
    echo "Usage: ./build.sh [command]"
    echo ""
    echo "Commands:"
    echo "  build     - Build the project (Debug)"
    echo "  release   - Build the project (Release)"
    echo "  run       - Run the terminal in development mode"
    echo "  publish   - Create single-file executable"
    echo "  clean     - Clean build artifacts"
    echo "  test      - Quick test of the terminal"
    echo "  help      - Show this help"
    echo ""
    echo "Examples:"
    echo "  ./build.sh build     # Build and run"
    echo "  ./build.sh publish   # Create deployable binary"
}

build_project() {
    echo "🔨 Building Wurp Terminal..."
    dotnet build --configuration Debug
    echo "✅ Build completed!"
}

build_release() {
    echo "🔨 Building Wurp Terminal (Release)..."
    dotnet build --configuration Release
    echo "✅ Release build completed!"
}

run_project() {
    echo "🚀 Running Wurp Terminal..."
    dotnet run
}

publish_project() {
    echo "📦 Publishing Wurp Terminal..."
    dotnet publish --configuration Release --self-contained false --output ./publish
    echo "✅ Published to ./publish/"
    echo "📁 Binary: ./publish/wurp-terminal"
}

clean_project() {
    echo "🧹 Cleaning build artifacts..."
    dotnet clean
    rm -rf ./publish
    echo "✅ Clean completed!"
}

test_project() {
    echo "🧪 Testing Wurp Terminal..."
    echo -e "help\nversion\ntheme\nexit" | dotnet run
    echo "✅ Test completed!"
}

case "${1:-build}" in
    "build")
        build_project
        ;;
    "release")
        build_release
        ;;
    "run")
        run_project
        ;;
    "publish")
        publish_project
        ;;
    "clean")
        clean_project
        ;;
    "test")
        test_project
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo "Run './build.sh help' for available commands."
        exit 1
        ;;
esac
