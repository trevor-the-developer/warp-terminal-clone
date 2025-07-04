#!/bin/bash
# lib/wurp-terminal-functions.sh
# Modular function library for Wurp (Warp Terminal Clone)

# ========================================
# MODULE LOADING SYSTEM
# ========================================

# Get the directory of this script
FUNCTIONS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$FUNCTIONS_DIR/modules"

# Debug function (available immediately)
debug_print() {
    if [[ "${DEBUG:-}" == "true" || "${DEBUG:-}" == "1" ]]; then
        echo "DEBUG: $*" >&2
    fi
}

# Initialise module loading
init_module_system() {
    debug_print "Initialising module system..."
    debug_print "Functions dir: $FUNCTIONS_DIR"
    debug_print "Modules dir: $MODULES_DIR"

    # Check if modules directory exists
    if [ ! -d "$MODULES_DIR" ]; then
        echo "⚠️ Modules directory not found: $MODULES_DIR"
        echo "Using legacy mode..."
        return 1
    fi

    return 0
}

# Load all modules in numerical order
load_modules() {
    debug_print "Loading modules from: $MODULES_DIR"

    local loaded_count=0
    local failed_modules=()

    # Source all modules in order (00-*, 10-*, etc.)
    for module in "$MODULES_DIR"/*.sh; do
        if [ -f "$module" ]; then
            local module_name=$(basename "$module")
            debug_print "Loading module: $module_name"

            if source "$module"; then
                debug_print "✅ Successfully loaded: $module_name"
                ((loaded_count++))
            else
                echo "❌ Failed to load module: $module_name"
                failed_modules+=("$module_name")
            fi
        fi
    done

    debug_print "Loaded $loaded_count modules successfully"

    if [ ${#failed_modules[@]} -gt 0 ]; then
        echo "❌ Failed to load modules: ${failed_modules[*]}"
        return 1
    fi

    print_status "success" "Modular system loaded successfully"
    return 0
}

# ========================================
# LEGACY COMPATIBILITY FUNCTIONS
# ========================================
# These provide basic functionality when modules aren't available

# Basic config functions
get_config() {
    local path=$1
    echo "$CONFIG" | jq -r "$path // empty" 2>/dev/null
}

get_config_array() {
    local path=$1
    echo "$CONFIG" | jq -r "$path[]? // empty" 2>/dev/null
}

expand_path() {
    local path=$1
    echo "${path/\$HOME/$HOME}"
}

# Basic output functions
print_color() {
    local color_name=$1
    local message=$2
    case $color_name in
        "red") echo -e "\033[0;31m${message}\033[0m" ;;
        "green") echo -e "\033[0;32m${message}\033[0m" ;;
        "yellow") echo -e "\033[1;33m${message}\033[0m" ;;
        "blue") echo -e "\033[0;34m${message}\033[0m" ;;
        "cyan") echo -e "\033[0;36m${message}\033[0m" ;;
        *) echo "$message" ;;
    esac
}

print_status() {
    local status=$1
    local message=$2
    case $status in
        "success") print_color "green" "✅ $message" ;;
        "error") print_color "red" "❌ $message" ;;
        "warning") print_color "yellow" "⚠️  $message" ;;
        "info") print_color "cyan" "ℹ️  $message" ;;
        "working") print_color "yellow" "🔨 $message" ;;
        "folder") print_color "blue" "📁 $message" ;;
        "file") print_color "green" "📝 $message" ;;
        "computer") print_color "cyan" "💻 $message" ;;
        "gear") print_color "yellow" "⚙️ $message" ;;
        "wrench") print_color "yellow" "🔧 $message" ;;
        "book") print_color "blue" "📖 $message" ;;
        "rocket") print_color "cyan" "🚀 $message" ;;
        "party") print_color "green" "🎉 $message" ;;
        "target") print_color "cyan" "🎯 $message" ;;
        *) echo "$message" ;;
    esac
}

# Basic dependency check
check_dependencies() {
    print_status "working" "Checking dependencies..."
    local missing_deps=()
    local has_errors=false

    while IFS= read -r dep_json; do
        [ -z "$dep_json" ] && continue

        local name=$(echo "$dep_json" | jq -r '.name')
        local command=$(echo "$dep_json" | jq -r '.command')
        local install_hint=$(echo "$dep_json" | jq -r '.install_hint')

        if ! command -v "$command" &> /dev/null; then
            missing_deps+=("$name: $install_hint")
            has_errors=true
        fi
    done < <(echo "$CONFIG" | jq -c '.dependencies.required[]? // empty')

    if [ "$has_errors" = true ]; then
        print_status "error" "Missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            print_color "yellow" "  • $dep"
        done
        return 1
    fi

    print_status "success" "All dependencies satisfied"
    return 0
}

# Basic build function
build_app() {
    print_status "working" "Building application..."

    cd "$PROJECT_ROOT" || return 1

    local build_args=$(get_config '.build.dotnet_args.build')
    build_args="${build_args:--c Release}"

    if dotnet build $build_args; then
        print_status "success" "Build successful"
        return 0
    else
        print_status "error" "Build failed"
        return 1
    fi
}

# Basic publish function
publish_app() {
    print_status "working" "Publishing application..."

    cd "$PROJECT_ROOT" || return 1

    local binary_name=$(get_config '.project.binary_name')
    binary_name="${binary_name:-wurp-terminal}"

    local publish_args="-c Release --self-contained false"

    if dotnet publish $publish_args; then
        print_status "success" "Publish successful"

        local user_bin_path=$(get_config '.paths.user_bin')
        local user_bin=$(expand_path "${user_bin_path:-$HOME/.local/bin}")

        # Find the actual binary location
        local actual_binary=""
        local search_paths=(
            "bin/Release/net9.0/linux-x64/publish/$binary_name"
            "bin/Release/net9.0/publish/$binary_name"
            "bin/Release/net9.0/linux-x64/$binary_name"
            "bin/Release/net9.0/linux-x64/publish/$binary_name.dll"
            "bin/Release/net9.0/publish/$binary_name.dll"
        )

        for path in "${search_paths[@]}"; do
            if [ -f "$PROJECT_ROOT/$path" ]; then
                actual_binary="$PROJECT_ROOT/$path"
                print_status "info" "Found binary at: $path"
                break
            fi
        done

        if [ -z "$actual_binary" ]; then
            print_status "error" "Published binary not found"
            return 1
        fi

        chmod +x "$actual_binary"

        mkdir -p "$user_bin"
        [ -L "$user_bin/$binary_name" ] && rm -f "$user_bin/$binary_name"
        [ -f "$user_bin/$binary_name" ] && rm -f "$user_bin/$binary_name"

        # Create a wrapper script if it's a .dll
        if [[ "$actual_binary" == *.dll ]]; then
            cat > "$user_bin/$binary_name" << WRAPPER_EOF
#!/bin/bash
exec dotnet "$actual_binary" "\$@"
WRAPPER_EOF
            chmod +x "$user_bin/$binary_name"
            print_color "cyan" "🔗 Wrapper script created: $user_bin/$binary_name"
        else
            ln -s "$actual_binary" "$user_bin/$binary_name"
            print_color "cyan" "🔗 Symlink created: $user_bin/$binary_name"
        fi

        if [[ ":$PATH:" != *":$user_bin:"* ]]; then
            print_status "warning" "Add $user_bin to your PATH:"
            echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
            echo "  source ~/.bashrc"
        fi
        return 0
    else
        print_status "error" "Publish failed"
        return 1
    fi
}

# Basic run function
run_app() {
    local binary_name=$(get_config '.project.binary_name')
    binary_name="${binary_name:-wurp-terminal}"

    # Try to find the published binary
    local actual_binary=""
    local search_paths=(
        "bin/Release/net9.0/linux-x64/publish/$binary_name"
        "bin/Release/net9.0/publish/$binary_name"
        "bin/Release/net9.0/linux-x64/$binary_name"
        "bin/Release/net9.0/linux-x64/publish/$binary_name.dll"
        "bin/Release/net9.0/publish/$binary_name.dll"
    )

    for path in "${search_paths[@]}"; do
        if [ -f "$PROJECT_ROOT/$path" ]; then
            actual_binary="$PROJECT_ROOT/$path"
            break
        fi
    done

    if [ -n "$actual_binary" ]; then
        if [[ "$actual_binary" == *.dll ]]; then
            exec dotnet "$actual_binary" "$@"
        else
            exec "$actual_binary" "$@"
        fi
    else
        print_status "error" "Application not found. Please build first."
        return 1
    fi
}

# Basic status function
show_status() {
    local project_name=$(get_config '.project.name')
    project_name="${project_name:-Wurp (Warp Terminal Clone)}"

    print_color "cyan" "🚀 $project_name Status"
    echo ""

    local binary_name=$(get_config '.project.binary_name')
    binary_name="${binary_name:-wurp-terminal}"

    # Check if application is built
    local actual_binary=""
    local search_paths=(
        "bin/Release/net9.0/linux-x64/publish/$binary_name"
        "bin/Release/net9.0/publish/$binary_name"
        "bin/Release/net9.0/linux-x64/$binary_name"
        "bin/Release/net9.0/linux-x64/publish/$binary_name.dll"
        "bin/Release/net9.0/publish/$binary_name.dll"
    )

    for path in "${search_paths[@]}"; do
        if [ -f "$PROJECT_ROOT/$path" ]; then
            actual_binary="$PROJECT_ROOT/$path"
            break
        fi
    done

    if [ -n "$actual_binary" ]; then
        print_status "success" "Application built and published"
        echo -e "   Location: $actual_binary"
    else
        print_status "error" "Application not built"
    fi

    local user_bin_path=$(get_config '.paths.user_bin')
    local user_bin=$(expand_path "${user_bin_path:-$HOME/.local/bin}")

    # Check symlink
    [ -L "$user_bin/$binary_name" ] && print_status "success" "Symlink installed" || print_status "warning" "Symlink not installed"

    # Check PATH
    [[ ":$PATH:" == *":$user_bin:"* ]] && print_status "success" "PATH configured correctly" || print_status "warning" "~/.local/bin not in PATH"

    echo ""
}

# Basic help function
show_help() {
    local project_name=$(get_config '.project.name')
    project_name="${project_name:-Wurp (Warp Terminal Clone)}"

    local binary_name=$(get_config '.project.binary_name')
    binary_name="${binary_name:-wurp-terminal}"

    print_color "cyan" "$project_name - Build & Installation Script"
    echo ""
    print_color "yellow" "Usage:"
    echo "  ./scripts/$binary_name [command] [options]"
    echo ""
    print_color "yellow" "Commands:"
    echo "  build         - Build the application"
    echo "  publish       - Build and publish as single file"
    echo "  install       - Full installation (build, publish, integrate)"
    echo "  run           - Run the application"
    echo "  status        - Show installation status"
    echo "  check         - Check dependencies"
    echo "  help          - Show this help"
}

# Stub functions for missing functionality (will be implemented in future modules)
install_shell_integration() {
    print_status "info" "Shell integration not yet implemented in modular system"
}

create_desktop_entry() {
    print_status "info" "Desktop integration not yet implemented in modular system"
}

check_freelance_ai() {
    print_status "info" "Service checks not yet implemented in modular system"
}

check_ollama() {
    print_status "info" "Service checks not yet implemented in modular system"
}

uninstall() {
    print_status "info" "Uninstall not yet implemented in modular system"
}

# ========================================
# BOOTSTRAP ORCHESTRATION
# ========================================

# Execute the bootstrap process with modular support
execute_bootstrap_with_args() {
    local base_dir="$1"
    local project_name="$2"

    print_color "cyan" "🚀 Creating Wurp (Warp Terminal Clone) Project Structure"
    print_color "cyan" "=================================================="
    echo ""

    local project_dir="$base_dir/$project_name"

    debug_print "Using provided base_dir: '$base_dir'"
    debug_print "Using provided project_name: '$project_name'"
    debug_print "final project_dir: '$project_dir'"
    echo ""

    # Initialise module system
    if ! init_module_system; then
        print_status "warning" "Module system not available, using legacy mode"
    else
        # Try to load modules
        if load_modules; then
            print_status "success" "Modular system loaded successfully"
        else
            print_status "warning" "Module loading failed, using legacy mode"
        fi
    fi

    # Create project structure and change to it
    if ! create_project_structure "$project_dir"; then
        print_status "error" "Failed to create project structure"
        return 1
    fi

    # Verify we're in the right directory
    print_status "info" "Current working directory: $(pwd)"
    echo ""

    # Create all project files
    print_status "working" "Creating project files..."

    # Use modular functions if available, otherwise use legacy individual functions
    if command -v create_all_project_files &> /dev/null; then
        create_all_project_files || { print_status "error" "Failed to create project files"; return 1; }
    else
        # Legacy file creation
        print_status "warning" "Using legacy file creation mode"
        create_csproj_file || { print_status "error" "Failed to create .csproj file"; return 1; }
        create_program_cs || { print_status "error" "Failed to create Program.cs"; return 1; }
        create_core_files || { print_status "error" "Failed to create Core files"; return 1; }
        create_wurp_config || { print_status "error" "Failed to create wurp-config.json"; return 1; }
        create_readme || { print_status "error" "Failed to create README.md"; return 1; }
    fi

    create_wurp_functions || { print_status "error" "Failed to create functions library"; return 1; }
    create_main_launcher || { print_status "error" "Failed to create main launcher"; return 1; }

    # Make scripts executable
    local main_script="scripts/wurp-terminal"
    local functions_script="scripts/lib/wurp-terminal-functions.sh"

    if [ -f "$main_script" ]; then
        chmod +x "$main_script"
        print_status "success" "Made executable: $main_script"
    fi

    if [ -f "$functions_script" ]; then
        chmod +x "$functions_script"
        print_status "success" "Made executable: $functions_script"
    fi

    # Final status
    echo ""
    print_status "party" "Wurp Terminal project structure created successfully!"
    echo ""
    print_status "folder" "Project location: $project_dir"
    echo ""
    print_status "rocket" "Next steps:"
    echo "   cd \"$project_dir\""
    echo "   ./scripts/wurp-terminal check    # Check dependencies"
    echo "   ./scripts/wurp-terminal install  # Build and install"
    echo "   wurp-terminal                    # Run the terminal"
    echo ""
    print_status "success" "All files created:"
    echo "   ├── Program.cs (Main entry point)"
    echo "   ├── Core/ (Modular class architecture)"
    echo "   │   ├── WurpTerminalService.cs"
    echo "   │   ├── AIIntegration.cs"
    echo "   │   └── ThemeManager.cs"
    echo "   ├── WurpTerminal.csproj"
    echo "   ├── wurp-config.json (Complete configuration)"
    echo "   ├── scripts/wurp-terminal (Main launcher)"
    echo "   ├── scripts/lib/wurp-terminal-functions.sh (Modular library)"
    echo "   └── README.md"
    echo ""
    print_status "target" "The project is ready for testing!"
    echo ""
    print_status "info" "💡 To enable full modular functionality:"
    echo "   1. Create scripts/lib/modules/ directory in generated project"
    echo "   2. Add the modular function files (00-core.sh, 10-project.sh, 20-files.sh)"
    echo "   3. Restart to use enhanced modular features"

    return 0
}

# Keep the old function for backward compatibility
execute_bootstrap() {
    local base_dir=$(get_config '.bootstrap.base_dir')
    local project_subdir=$(get_config '.bootstrap.project_subdir')

    if [ -z "$base_dir" ]; then
        base_dir="$HOME/Development"
    fi

    if [ -z "$project_subdir" ]; then
        project_subdir="wurp-terminal"
    fi

    base_dir=$(expand_path "$base_dir")

    execute_bootstrap_with_args "$base_dir" "$project_subdir"
}

# ========================================
# MODULE SYSTEM INITIALIZATION
# ========================================

# Initialise the module system when this file is sourced
if init_module_system; then
    load_modules
fi

# Export key functions for external use
export -f execute_bootstrap execute_bootstrap_with_args
export -f print_status print_color get_config expand_path debug_print
