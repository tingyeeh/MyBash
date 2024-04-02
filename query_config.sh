#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Function to print result in color
print_result() {
    local status=$1
    local message=$2
    case $status in
        checked)
            echo -e "${GREEN}${message} Checked${NC}"
            ;;
        failed)
            echo -e "${RED}${message} Failed${NC}"
            ;;
        notfound)
            echo -e "${ORANGE}${message} Not Found${NC}"
            ;;
    esac
}

# Function to check version requirement
check_version() {
    local version=$1
    local requirement=$2
    local name=$3

    if [[ -z "$version" ]]; then
        print_result notfound "$name"
        return
    fi

    version=$(echo "$version" | grep -oE '([0-9]+\.){0,2}[0-9]+')
    requirement=$(echo "$requirement" | grep -oE '([0-9]+\.){0,2}[0-9]+')
    if [[ $(printf '%s\n' "$requirement" "$version" | sort -V | head -n1) = "$requirement" ]]; then
        print_result checked "$name V $version"
    else
        print_result failed "$name V $version"
    fi
}

# Function to check PHP extensions
check_php_extension() {
    local extension=$1
    if php -m | grep -iq "^$extension\$"; then
        print_result checked "PHP extension $extension"
    else
        print_result notfound "PHP extension $extension"
    fi
}

# Perform checks
echo "Performing system checks..."

# Sample checks for software versions
# You can uncomment or add similar checks for other software as needed

# Check Composer
# composer_version=$(composer --version 2>&1)
# check_version "$composer_version" "2.6" "Composer"

# Check for required PHP extensions
required_extensions=("bcmath" "ctype" "curl" "dom" "fileinfo" "filter" "gd" "hash" "iconv" "intl" "json" "libxml" "mbstring" "openssl" "pcre" "pdo_mysql" "simplexml" "soap" "sockets" "sodium" "tokenizer" "xmlwriter" "xsl" "zip" "zlib")
for ext in "${required_extensions[@]}"; do
    check_php_extension "$ext"
done

# Additional checks for other software and services can be added here following the pattern above
