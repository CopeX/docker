#!/bin/bash

# Define colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Enable immediate exit if any command has a non-zero exit status
set -e

# Function to extract the tag name
get_tag_name() {
    local directory=$1
    local tag_name=$(basename "$directory")

    # Check if there are subdirectories
    if [[ "$directory" != "$tag_name" ]]; then
        tag_name=${directory//\//:}
    fi

    tag_name="copex/$tag_name"
    echo "$tag_name"
}

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo -e "${GREEN}Please provide at least one directory name where the Dockerfiles are located.${NC}"
    exit 1
fi

# Loop through each provided directory and build the Docker image
for directory in "$@"; do
    if [ -d "$directory" ]; then
        echo -e "${GREEN}Entering directory: $directory${NC}"
        cd "$directory" || { echo -e "${RED}Could not enter directory: $directory${NC}"; exit 1; }

        tag_name=$(get_tag_name "$directory")

        echo -e "${GREEN}Building Docker container in $directory...${NC}"
        if docker build -t "$tag_name" . --squash; then
            echo -e "${GREEN}Build, Squashed and Tagged the container with $tag_name...${NC}"
        else
            echo -e "${RED}Failed to build $directory.${NC}"
            exit 1
        fi

        cd - > /dev/null || { echo -e "${RED}Could not return to the previous directory.${NC}"; exit 1; }
    else
        echo -e "${RED}Directory $directory not found.${NC}"
    fi
done

# Loop through each provided directory and push the Docker images
for directory in "$@"; do

  tag_name=$(get_tag_name "$directory")

  # Pushing the container if the build was successful
  echo -e "${GREEN}Pushing the container $tag_name ${NC}"
  docker push "$tag_name"
  echo -e "${GREEN}Successfully pushed $tag_name!${NC}"
done