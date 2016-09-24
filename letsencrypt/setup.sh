#!/usr/bin/env bash

set -e

production_version="production-3.5.2"

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
function install_and_upgrade {
	info "Pip: Checking $1 status"
	if pip install --upgrade "$1" &> /dev/null ; then
		success "Pip: $1 is now installed and updated"
	else
		fail "Pip: $1 failed to install/upgrade"
	fi
}

# Switches over the python version temporarily
if pyenv global 2.7.12 ; then
	success "Pyenv: Switching to python version 2.7.12 for now"
else
	fail "Pyenv: Failed to switch to python version 2.7.12"
fi
install_and_upgrade virtualenv

# Checks on the LE build status
if [[ -d /server/letsencrypt/build ]]; then
	success "Letsencrypt: LE is already downloaded, updating now"
	if git -C /server/letsencrypt/build pull &> /dev/null ; then
		success "Letsencrypt: LE is now updated"
	else
		fail "Letsencrypt: LE failed to update"
	fi
else
	info "Letsencrypt: LE has not been downloaded yet, downloading now"
	if git clone https://github.com/letsencrypt/letsencrypt /server/letsencrypt/build &> /dev/null ; then
		success "Letsencrypt: LE is now downloaded"
	else
		fail "Letsencrypt: LE failed to download"
	fi
fi

# Executes and gets a new certificate
if [[ -d /etc/letsencrypt ]]; then
	# Cert has already been installed

	# Checks for proper .ini linking
	if [[ ! -L /etc/letsencrypt/cli.ini ]]; then
		info "Letsencrypt: Linking configuration file now"
		if sudo ln -s /server/letsencrypt/cli.ini ; then
			success "Letsencrypt: Configuration file is now linked"
		else
			fail "Letsencrypt: Configuration file failed to be linked"
		fi
	fi

	# Requests a new cert
	info "Letsencrypt: Getting a new TLS certificate now"
	if echo "E" | /server/letsencrypt/build/letsencrypt-auto --config /etc/letsencrypt/cli.ini --agree-tos certonly > /server/letsencrypt/logs/letsEncrypt-"$(date +"%d-%m-%y")".log ; then
		success "Letsencrypt: A new TLS certificate is now installed"
	else
		fail "Letsencrypt: TLS certificate renewal process failed"
	fi
else
	# Runs the automatic TLS certification generation command (first time)
	info "Letsencrypt: Getting a new TLS certificate now (first time)"
	if /server/letsencrypt/build/letsencrypt-auto --config /server/letsencrypt/cli.ini --agree-tos certonly > /server/letsencrypt/logs/letsEncrypt-"$(date +"%d-%m-%y")".log ; then
		success "Letsencrypt: A new TLS certificate is now installed"
	else
		fail "Letsencrypt: TLS certificate renewal process failed"
	fi
fi

# Switches back the python version
if pyenv global "$production_version" ; then
	success "Pyenv: Switched back to production python env $production_version"
else
	fail "Pyenv: Failed to switch to production python env $production_version"
fi
