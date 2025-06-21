#!/bin/bash
# lib/wurp-terminal-functions.sh
# Function library for Wurp (Warp Terminal Clone)

# ========================================
# UTILITY FUNCTIONS
# ========================================

get_config() {
    local path=$1
    echo "$CONFIG" | jq -r "$path // empty" 2>/dev/null
}

expand_path() {
    local path=$1
    echo "${path/\$HOME/$HOME}"
}

print_color() {
    local color_name=$1
    local message=$2
    local color_code=$(get_config ".colors.$color_name")
    local nc=$(get_config ".colors.nc")
    
    case $color_name in
        "red") color_code="${color_code:-\033[0;31m}" ;;
        "green") color_code="${color_code:-\033[0;32m}" ;;
        "yellow") color_code="${color_code:-\033[1;33m}" ;;
        "blue") color_code="${color_code:-\033[0;34m}" ;;
        "cyan") color_code="${color_code:-\033[0;36m}" ;;
        *) color_code="" ;;
    esac
    nc="${nc:-\033[0m}"
    
    echo -e "${color_code}${message}${nc}"
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
        *) echo "$message" ;;
    esac
}

# ========================================
# SHELL DETECTION FUNCTIONS
# ========================================

detect_current_shell() {
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo "zsh"
    elif [[ "$SHELL" == *"bash"* ]]; then
        echo "bash"
    elif [ -n "${ZSH_VERSION:-}" ]; then
        echo "zsh"
    elif [ -n "${BASH_VERSION:-}" ]; then
        echo "bash"
    else
        echo "bash"
    fi
}

get_shell_config() {
    local shell_type=$1
    local config_key=$2
    echo "$CONFIG" | jq -r ".shell_integration.shells.$shell_type.$config_key // empty"
}

# ========================================
# DEPENDENCY FUNCTIONS
# ========================================

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

# ========================================
# BUILD FUNCTIONS
# ========================================

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

publish_app() {
    print_status "working" "Publishing application..."
    
    cd "$PROJECT_ROOT" || return 1
    
    local binary_name=$(get_config '.project.binary_name')
    binary_name="${binary_name:-wurp-terminal}"
    
    # Publish (let .NET use its default structure)
    local publish_args="-c Release --self-contained false"
    
    if dotnet publish $publish_args; then
        print_status "success" "Publish successful"
        
        local user_bin_path=$(get_config '.paths.user_bin')
        local user_bin=$(expand_path "${user_bin_path:-$HOME/.local/bin}")
        
        # Find the actual binary location (check common .NET publish paths)
        local actual_binary=""
        local search_paths=(
            "bin/Release/net8.0/linux-x64/publish/$binary_name"
            "bin/Release/net8.0/publish/$binary_name"
            "bin/Release/net8.0/linux-x64/$binary_name"
            "bin/Release/net8.0/linux-x64/publish/$binary_name.dll"
            "bin/Release/net8.0/publish/$binary_name.dll"
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
            print_status "info" "Searched locations:"
            for path in "${search_paths[@]}"; do
                echo "  - $path"
            done
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

# ========================================
# SHELL INTEGRATION FUNCTIONS
# ========================================

install_shell_integration() {
    print_status "working" "Installing shell integration..."
    
    local current_shell=$(detect_current_shell)
    print_color "cyan" "Detected shell: $current_shell"
    
    local rc_file_path=$(get_shell_config "$current_shell" "rc_file")
    local rc_file=$(expand_path "${rc_file_path:-$HOME/.bashrc}")
    
    local marker=$(get_config '.shell_integration.marker')
    marker="${marker:-# Wurp Terminal Integration}"
    
    if grep -q "$marker" "$rc_file" 2>/dev/null; then
        print_status "info" "Shell integration already installed"
        return 0
    fi
    
    local binary_name=$(get_config '.project.binary_name')
    binary_name="${binary_name:-wurp-terminal}"
    
    # Build integration block
    local integration_block=""
    integration_block+="\n$marker\n"
    
    while IFS= read -r alias_line; do
        [ -n "$alias_line" ] && integration_block+="$alias_line\n"
    done < <(echo "$CONFIG" | jq -r '.shell_integration.aliases[]? // empty')
    
    integration_block+="\n# AI helper functions\n"
    integration_block+="wurp_explain() { $binary_name ai explain \"\$*\"; }\n"
    integration_block+="wurp_suggest() { $binary_name ai suggest \"\$*\"; }\n"
    integration_block+="wurp_debug() { $binary_name ai debug \"\$*\"; }\n\n"
    
    while IFS= read -r alias_line; do
        [ -n "$alias_line" ] && integration_block+="$alias_line\n"
    done < <(echo "$CONFIG" | jq -r '.shell_integration.quick_aliases[]? // empty')
    
    echo -e "$integration_block" >> "$rc_file"
    
    print_status "success" "Shell integration installed"
    print_color "cyan" "Restart your shell or run: source $rc_file"
}

# ========================================
# SERVICE FUNCTIONS
# ========================================

check_freelance_ai() {
    print_status "working" "Checking FreelanceAI service..."
    
    local health_url=$(get_config '.services.freelance_ai.health_url')
    health_url="${health_url:-http://localhost:5000/health}"
    
    if curl -s "$health_url" > /dev/null 2>&1; then
        print_status "success" "FreelanceAI API is running"
        return 0
    else
        print_status "warning" "FreelanceAI API not running"
        return 1
    fi
}

check_ollama() {
    local health_url=$(get_config '.services.ollama.health_url')
    health_url="${health_url:-http://localhost:11434/api/tags}"
    
    if curl -s "$health_url" > /dev/null 2>&1; then
        print_status "success" "Ollama is running"
        return 0
    else
        print_status "info" "Ollama not running (optional)"
        return 1
    fi
}

# ========================================
# DESKTOP INTEGRATION FUNCTIONS
# ========================================

create_desktop_entry() {
    print_status "working" "Creating desktop entry..."
    
    local desktop_dir_path=$(get_config '.paths.desktop_dir')
    local desktop_dir=$(expand_path "${desktop_dir_path:-$HOME/.local/share/applications}")
    
    local binary_name=$(get_config '.project.binary_name')
    binary_name="${binary_name:-wurp-terminal}"
    
    local desktop_file="$desktop_dir/$binary_name.desktop"
    
    local publish_path=$(get_config '.paths.publish_dir')
    local publish_dir=$(expand_path "${publish_path:-bin/Release/net8.0/publish}")
    
    mkdir -p "$desktop_dir"
    
    local entry_name=$(get_config '.desktop_entry.name')
    entry_name="${entry_name:-Wurp (Warp Terminal Clone)}"
    
    local entry_comment=$(get_config '.desktop_entry.comment')
    entry_comment="${entry_comment:-AI-Powered Terminal built with .NET}"
    
    local entry_icon=$(get_config '.desktop_entry.icon')
    entry_icon="${entry_icon:-utilities-terminal}"
    
    local entry_categories=$(get_config '.desktop_entry.categories')
    entry_categories="${entry_categories:-System;TerminalEmulator;}"
    
    local entry_keywords=$(get_config '.desktop_entry.keywords')
    entry_keywords="${entry_keywords:-terminal;console;command;shell;ai;}"
    
    cat > "$desktop_file" << DESKTOP_EOF
[Desktop Entry]
Name=$entry_name
Comment=$entry_comment
Exec=$PROJECT_ROOT/$publish_dir/$binary_name
Icon=$entry_icon
Type=Application
Categories=$entry_categories
Terminal=false
StartupNotify=true
Keywords=$entry_keywords
DESKTOP_EOF
    
    chmod +x "$desktop_file"
    print_status "success" "Desktop entry created"
}

# ========================================
# STATUS FUNCTIONS
# ========================================

show_status() {
    local project_name=$(get_config '.project.name')
    project_name="${project_name:-Wurp (Warp Terminal Clone)}"
    
    print_color "cyan" "🚀 $project_name Status"
    echo ""
    
    local binary_name=$(get_config '.project.binary_name')
    binary_name="${binary_name:-wurp-terminal}"
    
    # Use same search logic as publish_app
    local actual_binary=""
    local search_paths=(
        "bin/Release/net8.0/linux-x64/publish/$binary_name"
        "bin/Release/net8.0/publish/$binary_name"
        "bin/Release/net8.0/linux-x64/$binary_name"
        "bin/Release/net8.0/linux-x64/publish/$binary_name.dll"
        "bin/Release/net8.0/publish/$binary_name.dll"
    )
    
    for path in "${search_paths[@]}"; do
        if [ -f "$PROJECT_ROOT/$path" ]; then
            actual_binary="$PROJECT_ROOT/$path"
            break
        fi
    done
    
    local user_bin_path=$(get_config '.paths.user_bin')
    local user_bin=$(expand_path "${user_bin_path:-$HOME/.local/bin}")
    
    # Check build status
    if [ -n "$actual_binary" ]; then
        print_status "success" "Application built and published"
        echo -e "   Location: $actual_binary"
    else
        print_status "error" "Application not built"
    fi
    
    # Check symlink
    [ -L "$user_bin/$binary_name" ] && print_status "success" "Symlink installed" || print_status "warning" "Symlink not installed"
    
    # Check PATH
    [[ ":$PATH:" == *":$user_bin:"* ]] && print_status "success" "PATH configured correctly" || print_status "warning" "~/.local/bin not in PATH"
    
    # Check shell integration
    local marker=$(get_config '.shell_integration.marker')
    marker="${marker:-# Wurp Terminal Integration}"
    
    local current_shell=$(detect_current_shell)
    local rc_file_path=$(get_shell_config "$current_shell" "rc_file")
    local rc_file=$(expand_path "$rc_file_path")
    
    if [ -f "$rc_file" ] && grep -q "$marker" "$rc_file" 2>/dev/null; then
        print_status "success" "Shell integration installed ($current_shell)"
    else
        print_status "warning" "Shell integration not installed"
    fi
    
    # Check services
    check_freelance_ai > /dev/null 2>&1 && print_status "success" "FreelanceAI API available" || print_status "warning" "FreelanceAI API not available"
    
    echo ""
}

# ========================================
# RUN FUNCTIONS
# ========================================

run_app() {
    local binary_name=$(get_config '.project.binary_name')
    binary_name="${binary_name:-wurp-terminal}"
    
    # Use same search logic as publish_app
    local actual_binary=""
    local search_paths=(
        "bin/Release/net8.0/linux-x64/publish/$binary_name"
        "bin/Release/net8.0/publish/$binary_name"
        "bin/Release/net8.0/linux-x64/$binary_name"
        "bin/Release/net8.0/linux-x64/publish/$binary_name.dll"
        "bin/Release/net8.0/publish/$binary_name.dll"
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

# ========================================
# CLEANUP FUNCTIONS
# ========================================

uninstall() {
    local project_name=$(get_config '.project.name')
    project_name="${project_name:-Wurp (Warp Terminal Clone)}"
    
    print_status "working" "Uninstalling $project_name..."
    
    local binary_name=$(get_config '.project.binary_name')
    binary_name="${binary_name:-wurp-terminal}"
    
    local user_bin_path=$(get_config '.paths.user_bin')
    local user_bin=$(expand_path "${user_bin_path:-$HOME/.local/bin}")
    
    local desktop_dir_path=$(get_config '.paths.desktop_dir')
    local desktop_dir=$(expand_path "${desktop_dir_path:-$HOME/.local/share/applications}")
    
    local marker=$(get_config '.shell_integration.marker')
    marker="${marker:-# Wurp Terminal Integration}"
    
    # Remove symlink
    if [ -L "$user_bin/$binary_name" ]; then
        rm -f "$user_bin/$binary_name"
        print_status "success" "Symlink removed"
    fi
    
    # Remove desktop entry
    local desktop_file="$desktop_dir/$binary_name.desktop"
    if [ -f "$desktop_file" ]; then
        rm -f "$desktop_file"
        print_status "success" "Desktop entry removed"
    fi
    
    # Remove shell integration
    local current_shell=$(detect_current_shell)
    local rc_file_path=$(get_shell_config "$current_shell" "rc_file")
    local rc_file=$(expand_path "$rc_file_path")
    
    if [ -f "$rc_file" ] && grep -q "$marker" "$rc_file" 2>/dev/null; then
        cp "$rc_file" "$rc_file.wurp.bak"
        sed -i "/$marker/,/^$/d" "$rc_file"
        print_status "success" "Shell integration removed"
        print_color "cyan" "Backup created: $rc_file.wurp.bak"
    fi
    
    # Clean build artifacts
    cd "$PROJECT_ROOT" || return 1
    local clean_dirs_str
    clean_dirs_str=$(echo "$CONFIG" | jq -r '.build.clean_dirs[]? // empty' | tr '\n' ' ')
    IFS=' ' read -r -a clean_dirs <<< "$clean_dirs_str"
    for dir in "${clean_dirs[@]}"; do
        [ -n "$dir" ] && [ -d "$dir" ] && rm -rf "$dir"
    done
    
    print_status "success" "Uninstall complete"
}

# ========================================
# HELP FUNCTIONS
# ========================================

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
    echo "  shell         - Install shell integration only"
    echo "  desktop       - Create desktop entry"
    echo "  uninstall     - Remove all traces"
    echo "  check         - Check dependencies"
    echo "  help          - Show this help"
    echo ""
    print_color "yellow" "Examples:"
    print_color "green" "  ./scripts/$binary_name install"
    echo "    # Full installation"
    print_color "green" "  ./scripts/$binary_name run"
    echo "    # Run directly"
    print_color "green" "  ./scripts/$binary_name status"
    echo "    # Check status"
    echo ""
    print_color "cyan" "After installation, use:"
    print_color "green" "  $binary_name"
    echo "                      # Start terminal"
    print_color "green" "  wt"
    echo "                                 # Short alias"
    print_color "green" "  explain 'docker ps'"
    echo "               # Explain command"
    print_color "green" "  suggest 'deploy to kubernetes'"
    echo "    # Get suggestions"
}
