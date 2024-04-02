#!/bin/bash

# Function to check version requirement
check_version() {
    local version=$1
    local requirement=(${2//|/ })
    version=$(echo "$version" | grep -oE '([0-9]+\.){0,2}[0-9]+')
    for req in "${requirement[@]}"; do
        if [[ $(printf '%s\n' "$req" "$version" | sort -V | head -n1) == "$req" ]]; then
            return 0 # Version meets requirement
        fi
    done
    return 1 # Version does not meet any requirement
}

# Function to check web servers (Apache, nginx, OpenResty)
check_web_server() {
    local web_servers=("Apache 2.4" "nginx 1.24" "OpenResty 1.24")
    local check_commands=("apache2 -v" "nginx -v" "openresty -v")
    local i=0

    for ws in "${web_servers[@]}"; do
        local version=$(${check_commands[$i]} 2>&1)
        if [ $? -eq 0 ]; then # Command executed successfully
            if check_version "$version" "${ws##* }"; then
                echo "${ws%% *}... OK"
                return
            fi
        fi
        ((i++))
    done
    echo "Web server... FAIL (None found or does not meet the requirement)"
}

# Function to check databases (MariaDB, MySQL)
check_database() {
    local databases=("MariaDB 10.6" "MySQL 8")
    local check_commands=("mysql -V" "mysql -V")
    local i=0

    for db in "${databases[@]}"; do
        local version=$(${check_commands[$i]} 2>&1)
        if [ $? -eq 0 ]; then # Command executed successfully
            local name="${db%% *}"
            local req_version="${db##* }"
            if [[ $version == *"$name"* ]] && check_version "$version" "$req_version"; then
                echo "$name... OK"
                return
            fi
        fi
        ((i++))
    done
    echo "Database... FAIL (None found or does not meet the requirement)"
}

echo "Checking Composer version..."
composer_version=$(composer --version 2>&1)
if check_version "$composer_version" "2.6"; then
    echo "Composer... OK"
else
    echo "Composer... FAIL (Installed: $composer_version, Required: 2.6)"
fi

echo "Checking Elasticsearch version..."
elasticsearch_version=$(curl -XGET 'localhost:9200' 2>/dev/null)
if check_version "$elasticsearch_version" "8.11"; then
    echo "Elasticsearch... OK"
else
    echo "Elasticsearch... FAIL (Installed: $elasticsearch_version, Required: 8.11)"
fi

echo "Checking OpenSearch version..."
opensearch_version=$(curl -XGET 'localhost:9200' 2>/dev/null)
if check_version "$opensearch_version" "2.11"; then
    echo "OpenSearch... OK"
else
    echo "OpenSearch... FAIL (Installed: $opensearch_version, Required: 2.11)"
fi

echo "Checking Database version..."
check_database

echo "Checking PHP version..."
php_version=$(php -v 2>&1)
if check_version "$php_version" "8.3|8.2"; then
    echo "PHP... OK"
else
    echo "PHP... FAIL (Installed: $php_version, Required: 8.3 or 8.2)"
fi

echo "Checking RabbitMQ version..."
rabbitmq_version=$(rabbitmqctl status 2>/dev/null)
if check_version "$rabbitmq_version" "3.12"; then
    echo "RabbitMQ... OK"
else
    echo "RabbitMQ... FAIL (Installed: $rabbitmq_version, Required: 3.12)"
fi

echo "Checking Redis version..."
redis_version=$(redis-server --version 2>/dev/null)
if check_version "$redis_version" "7.2"; then
    echo "Redis... OK"
else
    echo "Redis... FAIL (Installed: $redis_version, Required: 7.2)"
fi

echo "Checking Varnish version..."
varnish
