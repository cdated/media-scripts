#!/bin/bash

# Exit on any error, undefined variables, or pipe failures
set -euo pipefail

# Configuration
OWNER="cdated"
GROUP="media"
BASE_DIR="/mnt/kurama/plex"
DIRECTORIES=("tv_shows" "anime" "movies")

# Function to fix permissions for a directory
fix_directory_permissions() {
    local dir="$1"
    local full_path="$BASE_DIR/$dir"

    if [[ ! -d "$full_path" ]]; then
        echo "Warning: Directory $full_path does not exist, skipping..."
        return 1
    fi

    echo "Fixing permissions for $full_path..."

    # Change ownership
    if ! chown "$OWNER:$GROUP" -R "$full_path"; then
        echo "Error: Failed to change ownership for $full_path"
        return 1
    fi

    # Set group permissions
    if ! chmod g+rwx -R "$full_path"; then
        echo "Error: Failed to set permissions for $full_path"
        return 1
    fi

    echo "✓ Successfully fixed permissions for $full_path"
    return 0
}

# Verify user and group exist
if ! id "$OWNER" &>/dev/null; then
    echo "Error: User '$OWNER' does not exist"
    exit 1
fi

if ! getent group "$GROUP" &>/dev/null; then
    echo "Error: Group '$GROUP' does not exist"
    exit 1
fi

# Process each directory
echo "Starting permission fix for Plex directories..."
failed_dirs=()

for dir in "${DIRECTORIES[@]}"; do
    if ! fix_directory_permissions "$dir"; then
        failed_dirs+=("$dir")
    fi
done

# Summary
if [[ ${#failed_dirs[@]} -eq 0 ]]; then
    echo "✓ All directories processed successfully"
    exit 0
else
    echo "✗ Failed to process directories: ${failed_dirs[*]}"
    exit 1
fi
