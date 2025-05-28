#!/bin/bash

# Define colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Enable immediate exit if any command has a non-zero exit status
set -e

# Define PHP versions to build
PHP_VERSIONS=("7.4" "8.0" "8.1" "8.2" "8.3" "8.4")

# Define image types
IMAGE_TYPES=("php" "nginx-php-fpm")

# Function to build and tag images
build_image() {
    local image_type=$1
    local php_version=$2
    local tag_name="copex/${image_type}:${php_version}"

    echo -e "${GREEN}Building ${image_type} with PHP ${php_version}...${NC}"

    if docker build \
        --build-arg PHP_VERSION=${php_version} \
        -t ${tag_name} \
        ${image_type}/ \
        --squash; then
        echo -e "${GREEN}Successfully built and tagged ${tag_name}${NC}"
        return 0
    else
        echo -e "${RED}Failed to build ${tag_name}${NC}"
        return 1
    fi
}

# Function to push images
push_image() {
    local image_type=$1
    local php_version=$2
    local tag_name="copex/${image_type}:${php_version}"

    echo -e "${GREEN}Pushing ${tag_name}...${NC}"

    if docker push ${tag_name}; then
        echo -e "${GREEN}Successfully pushed ${tag_name}${NC}"
        return 0
    else
        echo -e "${RED}Failed to push ${tag_name}${NC}"
        return 1
    fi
}

# Parse command line arguments
PUSH=false
BUILD_ONLY=""
PHP_VERSION_FILTER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --push)
            PUSH=true
            shift
            ;;
        --php-only)
            BUILD_ONLY="php"
            shift
            ;;
        --nginx-only)
            BUILD_ONLY="nginx-php-fpm"
            shift
            ;;
        --version)
            PHP_VERSION_FILTER="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --push              Push images after building"
            echo "  --php-only          Build only PHP images"
            echo "  --nginx-only        Build only nginx-php-fpm images"
            echo "  --version VERSION   Build only specific PHP version"
            echo "  --help              Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                           # Build all images"
            echo "  $0 --push                    # Build and push all images"
            echo "  $0 --php-only --version 8.2  # Build only PHP 8.2 image"
            echo "  $0 --nginx-only --push       # Build and push only nginx-php-fpm images"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Filter PHP versions if specified
if [[ -n "$PHP_VERSION_FILTER" ]]; then
    if [[ " ${PHP_VERSIONS[@]} " =~ " ${PHP_VERSION_FILTER} " ]]; then
        PHP_VERSIONS=("$PHP_VERSION_FILTER")
    else
        echo -e "${RED}Invalid PHP version: $PHP_VERSION_FILTER${NC}"
        echo "Available versions: ${PHP_VERSIONS[*]}"
        exit 1
    fi
fi

# Filter image types if specified
if [[ -n "$BUILD_ONLY" ]]; then
    IMAGE_TYPES=("$BUILD_ONLY")
fi

echo -e "${YELLOW}Building images for PHP versions: ${PHP_VERSIONS[*]}${NC}"
echo -e "${YELLOW}Building image types: ${IMAGE_TYPES[*]}${NC}"
echo -e "${YELLOW}Push after build: $PUSH${NC}"
echo ""

# Build images
failed_builds=()

for image_type in "${IMAGE_TYPES[@]}"; do
    for php_version in "${PHP_VERSIONS[@]}"; do
        if ! build_image "$image_type" "$php_version"; then
            failed_builds+=("${image_type}:${php_version}")
        fi
    done
done

# Check for build failures
if [[ ${#failed_builds[@]} -gt 0 ]]; then
    echo -e "${RED}The following builds failed:${NC}"
    for failed in "${failed_builds[@]}"; do
        echo -e "${RED}  - copex/${failed}${NC}"
    done
    exit 1
fi

# Push images if requested
if [[ "$PUSH" == "true" ]]; then
    echo -e "${YELLOW}Pushing images...${NC}"
    failed_pushes=()

    for image_type in "${IMAGE_TYPES[@]}"; do
        for php_version in "${PHP_VERSIONS[@]}"; do
            if ! push_image "$image_type" "$php_version"; then
                failed_pushes+=("${image_type}:${php_version}")
            fi
        done
    done

    # Check for push failures
    if [[ ${#failed_pushes[@]} -gt 0 ]]; then
        echo -e "${RED}The following pushes failed:${NC}"
        for failed in "${failed_pushes[@]}"; do
            echo -e "${RED}  - copex/${failed}${NC}"
        done
        exit 1
    fi
fi

echo -e "${GREEN}All operations completed successfully!${NC}"
