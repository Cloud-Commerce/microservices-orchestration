#!/bin/bash

# Configuration
PARENT_REPO_URL="https://github.com/Cloud-Commerce/microservices-orchestration.git"
PARENT_BRANCH="main"  # Branch of the parent repository

# Submodules: Format ("<URL>" "<BRANCH>" "<PATH>")
SUBMODULES=(
    "https://github.com/Cloud-Commerce/service-registry.git" "main" "service-registry"
    "https://github.com/Cloud-Commerce/gateway-service.git" "main" "gateway-service"
    "https://github.com/Cloud-Commerce/authN-service.git" "main" "authN-service"
	"https://github.com/Cloud-Commerce/authZ-lib.git" "main" "authZ-lib"
	"https://github.com/Cloud-Commerce/user-service.git" "main" "user-service"
)

# Clone the parent repository with the specified branch
echo "Cloning parent repository ($PARENT_BRANCH)..."
git clone --branch "$PARENT_BRANCH" --recurse-submodules "$PARENT_REPO_URL"

# Navigate into the parent repository
cd "$(basename "$PARENT_REPO_URL" .git)"

# Add submodules with specified branches
for ((i=0; i<${#SUBMODULES[@]}; i+=3)); do
    SUBMODULE_URL="${SUBMODULES[i]}"
    SUBMODULE_BRANCH="${SUBMODULES[i+1]}"
    SUBMODULE_PATH="${SUBMODULES[i+2]}"

    if [ ! -d "$SUBMODULE_PATH" ]; then
        echo "Adding submodule: $SUBMODULE_PATH (branch: $SUBMODULE_BRANCH)"
        git submodule add --branch "$SUBMODULE_BRANCH" "$SUBMODULE_URL" "$SUBMODULE_PATH"
    else
        echo "Submodule $SUBMODULE_PATH already exists."
    fi
done

# Initialize and update submodules to their specified branches
echo "Updating submodules to their respective branches..."
git submodule update --init --remote

echo "Setup complete! Parent repo is on branch '$PARENT_BRANCH', and submodules are on their specified branches."