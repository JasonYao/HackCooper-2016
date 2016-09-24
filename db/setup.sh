#!/usr/bin/env bash

set -e

###
# Helper functions
##
function info () {
	printf "\r  [ \033[00;34m..\033[0m ] %s\n" "$1"
}
function user () {
	printf "\r  [ \033[0;33m??\033[0m ] %s " "$1"
}
function success () {
	printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"
}
function warn () {
  printf "\r\033[2K  [\033[0;31mWARN\033[0m] %s\n" "$1"
}
function fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1"
  echo ''
  exit 1
}
function check_package {
	if [[ $(dpkg --get-selections | grep "$1") == "" ]]; then
		info "Apt: Package $1 is not yet installed, installing now"
		if sudo apt-get install "$1" -y &> /dev/null; then
			success "Apt: Package $1 is now installed"
		else
			fail "Apt: Package $1 failed to be installed"
		fi
	else
		success "Apt: Package $1 is already installed"
	fi
}

# Installs psql dependencies
	check_package postgresql
	check_package postgresql-contrib
	check_package python-psycopg2
	check_package libpq-dev

# Checks psql users
	# Sources secret settings
	. ./secret_settings.sh

	# Creates psql user if not already created
	if [[ $(sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$db_username'") == "1" ]]; then
		success "pSQL: Role $db_username is already created"
	else
		info "pSQL: Role $db_username is not yet created, creating now"
		if sudo -u postgres createuser "$db_username" --no-createdb --encrypted --no-createrole --no-superuser && sudo -u postgres psql postgres -tAc "ALTER USER \"$db_username\" WITH PASSWORD '$db_password'" > /dev/null ; then
			success "pSQL: Role $db_username is now created"
		else
			fail "pSQL: Role $db_username failed to be created"
		fi
	fi

# Checks psql database
	if [[ $(sudo -u postgres psql postgres -tAc "\l" | grep "$db_name") == "" ]]; then
		info "pSQL: Unable to find the database, creating now"
		if sudo -u postgres createdb "$db_name" && sudo -u postgres psql postgres -tAc "GRANT ALL PRIVILEGES ON DATABASE \"$db_name\" to \"$db_username\""; then
			success "pSQL: Database $db_name is now created"
		else
			fail "pSQL: Database $db_name failed to be created"
		fi
	else
		success "pSQL: Database $db_name is already created"
	fi

# Checks psql role attributes
	# Checks for client encoding is set to UTF-8
	if [[ $(sudo -u postgres psql postgres -tAc "SHOW CLIENT_ENCODING;" | grep "UTF8") == "" ]]; then
		info "pSQL: Client encoding is not set to UTF-8, setting now"
		if sudo -u postgres psql postgres -tAc "ALTER ROLE \"$db_username\" SET client_encoding TO 'utf8';" ; then
			success "pSQL: Client encoding is now set to UTF-8"
		else
			fail "pSQL: Client encoding could not be changed to UTF-8"
		fi
	else
		success "pSQL: Client encoding is already set to UTF-8"
	fi

	# Checks for default transaction isolation is read committed
	if [[ $(sudo -u postgres psql postgres -tAc "SHOW default_transaction_isolation;" | grep "read committed") == "" ]]; then
		info "pSQL: Default transaction isolation is not set to read committed, setting now"
		if sudo -u postgres psql postgres -tAc "ALTER ROLE \"$db_username\" SET default_transaction_isolation TO 'read committed';" ; then
			success "pSQL: Default transaction isolation is now set to read committed"
		else
			fail "pSQL: Default transaction isolation failed to be set to read committed"
		fi
	else
		success "pSQL: Default transaction isolation is already set to read committed"
	fi

	# Checks for the database timezone
	if [[ $(sudo -u postgres psql postgres -tAc "SHOW TIMEZONE;" | grep "UTC") == "" ]]; then
		info "pSQL: Database timezone is not set to UTC, setting now"
		if sudo -u postgres psql postgres -tAc "ALTER ROLE \"$db_username\" SET timezone TO 'UTC';" ; then
			success "pSQL: Database timezone is now set to UTC"
		else
			fail "pSQL: Database timezone failed to be set to UTC"
		fi
	else
		success "pSQL: Database timezone is already set to UTC"
	fi
