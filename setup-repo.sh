#!/bin/bash

# Main repository URL
MAIN_REPO_URL="https://github.com/Cloud-Commerce/microservices-orchestration.git"

# Submodule repositories
SUBMODULES=(
    "https://github.com/Cloud-Commerce/service-registry.git"
    "https://github.com/Cloud-Commerce/gateway-service.git"
    "https://github.com/Cloud-Commerce/authN-service.git"
	"https://github.com/Cloud-Commerce/authZ-service.git"
)

# Clone the main repository with submodules
echo "Cloning main repository..."
git clone --recurse-submodules "$MAIN_REPO_URL"

# Navigate into the main repository directory
cd "$(basename "$MAIN_REPO_URL" .git)"

# Add submodules if they are not already added
for SUBMODULE_URL in "${SUBMODULES[@]}"; do
    SUBMODULE_NAME=$(basename "$SUBMODULE_URL" .git)
    if [ ! -d "$SUBMODULE_NAME" ]; then
        echo "Adding submodule: $SUBMODULE_NAME"
        git submodule add "$SUBMODULE_URL"
    else
        echo "Submodule $SUBMODULE_NAME already exists."
    fi
done

# Initialize and update submodules
echo "Initializing and updating submodules..."
git submodule update --init --recursive

echo "Repository setup complete!"