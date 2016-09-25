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

# Sets up uWSGI log file
	if [[ -d /var/log/uwsgi ]]; then
		success "uWSGI: Log directory is already created"
	else
		info "uWSGI: Log directory has not been created yet, creating now"
		if sudo mkdir -p /var/log/uwsgi/ ; then
			success "uWSGI: Log directory is now created"
		else
			fail "uWSGI: Log directory failed to be created"
		fi
	fi

# Checks uWSGI systemd status
	if [[ -L /etc/systemd/system/uwsgi.service ]]; then
		success "uWSGI: Systemd service file is already linked"
	else
		info "uWSGI: Systemd service file is not yet linked, linking now"
		if sudo ln -s /server/uwsgi/uwsgi.service /etc/systemd/system/uwsgi.service ; then
			success "uWSGI: Systemd service file is now linked"
		else
			fail "uWSGI: Systemd service file failed to be linked"
		fi
	fi
