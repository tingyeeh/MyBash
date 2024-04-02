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


# Check Composer
composer_version=$(composer --version 2>&1)
check_version "$composer_version" "2.6" "Composer"

# Check Elasticsearch
elasticsearch_version=$(curl -XGET 'localhost:9200' 2>&1 | grep 'number' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
check_version "$elasticsearch_version" "8.11" "Elasticsearch"

# Check OpenSearch
opensearch_version=$(curl -XGET 'localhost:9200' 2>&1 | grep 'number' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
check_version "$opensearch_version" "2.11" "OpenSearch"

# Check MariaDB
mariadb_version=$(mysql --version 2>&1 | grep -o 'MariaDB.*' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
check_version "$mariadb_version" "10.6" "MariaDB"

# Check MySQL
mysql_version=$(mysql --version 2>&1 | grep -v 'MariaDB' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
check_version "$mysql_version" "8.0" "MySQL"

# Check PHP
php_version=$(php -v 2>&1 | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
check_version "$php_version" "8.3|8.2" "PHP"

echo "Performing system dependency checks..."

# Check for required system dependencies
required_commands=("bash" "gzip" "lsof" "mysql" "mysqldump" "nice" "php" "sed" "tar")
for cmd in "${required_commands[@]}"; do
    check_command "$cmd"
done

# Function to check PHP extensions
check_php_extension() {
    local extension=$1
    if php -m | grep -iq "^$extension\$"; then
        print_result checked "PHP extension $extension"
    else
        print_result notfound "PHP extension $extension"
    fi
}

# Check for required PHP extensions
required_extensions=("bcmath" "ctype" "curl" "dom" "fileinfo" "filter" "gd" "hash" "iconv" "intl" "json" "libxml" "mbstring" "openssl" "pcre" "pdo_mysql" "simplexml" "soap" "sockets" "sodium" "tokenizer" "xmlwriter" "xsl" "zip" "zlib")
for ext in "${required_extensions[@]}"; do
    check_php_extension "$ext"
done

# Additional checks for other software and services can be added here following the pattern above
