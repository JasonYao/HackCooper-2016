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

# Creates any new migrations
	info "Update: Creating any new database migrations"
	if echo "yes" | ./manage.py makemigrations ; then
		success "Update: Database migrations now created"
	else
		fail "Update: Database migrations failed to be created"
	fi

# Runs all migrations
	info "Update: Running all database migrations"
	if echo "yes" | ./manage.py migrate ; then
		success "Update: Database is now migrated"
	else
		fail "Update: Database failed to migrate"
	fi

# Collects all static files
	info "Update: Collecting all static files"
	if echo "yes" | ./manage.py collectstatic ; then
		success "Update: All static assets are now collected"
	else
		fail "Update: Failed to collect all static assets"
	fi

# Clears session data
	info "Update: Clearing session data"
	if echo "yes" | ./manage.py clearsessions ; then
		success "Update: All session data is now cleared"
	else
		fail "Update: Session data failed to be cleared"
	fi

# Resets uWSGI
	info "Update: Resetting uWSGI..."
	if sudo service uwsgi restart ; then
		success "Update: uWSGI has now restarted"
	else
		fail "Update: uWSGI failed to restart"
	fi

# Resets Nginx
	info "Update: Resetting Nginx"
	if sudo service nginx restart ; then
		success "Update: Nginx has now restarted"
	else
		fail "Update: Nginx failed to restart"
	fi
