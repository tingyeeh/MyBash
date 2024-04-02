#!/bin/bash

# Function to check version requirement
check_version() {
    local version=$1
    local requirement=$2
    version=$(echo "$version" | grep -oE '([0-9]+\.){0,2}[0-9]+')
    requirement=$(echo "$requirement" | grep -oE '([0-9]+\.){0,2}[0-9]+')
    if [[ $(printf '%s\n' "$requirement" "$version" | sort -V | head -n1) = "$requirement" ]]; then
        echo "OK"
    else
        echo "FAIL (Installed: $version, Required: $requirement)"
    fi
}

echo "Checking Composer version..."
composer_version=$(composer --version)
check_version "$composer_version" "2.6"

echo "Checking Elasticsearch version..."
# For Elasticsearch and similar services, you might need to adjust the command
# depending on how it's accessible from your host.
elasticsearch_version=$(curl -XGET 'localhost:9200')
check_version "$elasticsearch_version" "8.11"

echo "Checking OpenSearch version..."
# Adjust the command to fetch OpenSearch version if necessary
opensearch_version=$(curl -XGET 'localhost:9200')
check_version "$opensearch_version" "2.11"

echo "Checking MariaDB version..."
mariadb_version=$(mysql -V)
check_version "$mariadb_version" "10.6"

echo "Checking MySQL version..."
mysql_version=$(mysql -V)
check_version "$mysql_version" "8"

echo "Checking PHP version..."
php_version=$(php -v)
check_version "$php_version" "8.3"

echo "Checking RabbitMQ version..."
rabbitmq_version=$(rabbitmqctl status)
check_version "$rabbitmq_version" "3.12"

echo "Checking Redis version..."
redis_version=$(redis-server --version)
check_version "$redis_version" "7.2"

echo "Checking Varnish version..."
varnish_version=$(varnishd -V)
check_version "$varnish_version" "7.4"

echo "Checking Apache version..."
apache_version=$(apache2 -v)
check_version "$apache_version" "2.4"

echo "Checking nginx version..."
nginx_version=$(nginx -v)
check_version "$nginx_version" "1.24"

echo "Checking PHP extensions..."
# List of required PHP extensions
extensions=(bcmath ctype curl dom fileinfo filter gd hash iconv intl json libxml mbstring openssl pcre pdo_mysql simplexml soap sockets sodium tokenizer xmlwriter xsl zip zlib)

for ext in "${extensions[@]}"; do
    if ! php -m | grep -qi "$ext"; then
        echo "$ext extension... FAIL"
    else
        echo "$ext extension... OK"
    fi
done

echo "Checking other utilities..."
# List of required utilities
utilities=(bash gzip lsof mysql mysqldump nice php sed tar)

for util in "${utilities[@]}"; do
    if ! command -v "$util" &> /dev/null; then
        echo "$util... FAIL"
    else
        echo "$util... OK"
    fi
done

echo "Checking PHP Xdebug version..."
xdebug_version=$(php -r "echo phpversion('xdebug');")
check_version "$xdebug_version" "2.5"
