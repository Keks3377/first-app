#!/bin/sh

set -e
composer install

exec docker-php-entrypoint "$@"