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

# Checks that the user is a part of the www-data group
	if [[ $(groups | grep "www-data") == ""  ]]; then
		info "Group Permissions: $(whoami) is not a part of the www-data group, adding now"
		if sudo usermod -G www-data "$(whoami)" ; then
			success "Group Permissions: $(whoami) is now a part of the www-data group"
		else
			fail "Group Permissions: $(whoami) failed to be added to the www-data group"
		fi
	else
		success "Group Permissions: $(whoami) is already a part of the www-data group"
	fi

# Checks that /usr/share/nginx/html is correctly owned by www-data:www-data
	if [[ $(ls -ld /usr/share/nginx/html | grep "www-data www-data") == "" ]]; then
		info "Webroot Permissions: /usr/share/nginx/html is not yet owned by www-data:www-data, setting now"
		if sudo chown -R www-data:www-data /usr/share/nginx/html ; then
			success "Webroot Permissions: /usr/share/nginx/html is now owned by www-data:www-data"
		else
			fail "Webroot Permissions: /usr/share/nginx/html could not be owned by www-data:www-data"
		fi
	else
		success "Webroot Permissions: /usr/share/nginx/html is already owned by www-data:www-data"
	fi

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
		if git clone https://github.com/certbot/certbot.git /server/letsencrypt/build &> /dev/null ; then
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
		if echo "2" | /server/letsencrypt/build/certbot-auto --config /etc/letsencrypt/cli.ini --agree-tos certonly > /server/letsencrypt/logs/letsEncrypt-"$(date +"%d-%m-%y")".log ; then
			success "Letsencrypt: A new TLS certificate is now installed"
		else
			fail "Letsencrypt: TLS certificate renewal process failed"
		fi
	else
		# Runs the automatic TLS certification generation command (first time)
		info "Letsencrypt: Getting a new TLS certificate now (first time)"
		if /server/letsencrypt/build/certbot-auto --config /server/letsencrypt/cli.ini --agree-tos certonly > /server/letsencrypt/logs/letsEncrypt-"$(date +"%d-%m-%y")".log ; then
			success "Letsencrypt: A new TLS certificate is now installed"
		else
			fail "Letsencrypt: TLS certificate renewal process failed"
		fi
	fi

# Checks for dhparam generation and location
	if [[ -f /etc/ssl/certs/dhparam.pem ]]; then
		success "TLS: DHparam.pem is already generated and in place"
	else
		info "TLS: DHparam.pem is not yet generated, creating now"
		warn "This will take a while"
		if openssl dhparam -out ~/dhparam.pem 4096 ; then
			success "TLS: DHparam.pem is now generated, moving now to correct location"
			if sudo mv ~/dhparam.pem /etc/ssl/certs/dhparam.pem ; then
				success "TLS: DHparam.pem is now in the correct location"
			else
				fail "TLS: DHparam.pem could not be moved to its correct location"
			fi
		else
			fail "TLS: DHparam.pem could not be generated"
		fi
	fi

# Checks for https server symlinking
	if [[ -L /etc/nginx/sites-enabled/https.server ]]; then
		success "Nginx: HTTPS server is already correctly symlinked"
	else
		info "Nginx: HTTPS server is not yet symlinked, symlinking now"
		if sudo ln -s /etc/nginx/sites-available/https.server /etc/nginx/sites-enabled/https.server ; then
			success "Nginx: HTTPS server is now correctly symlinked"
		else
			fail "Nginx: HTTPS server failed to be correctly symlinked"
		fi
	fi

# Checks to make sure http server symlinking isn't still active
	if [[ -L /etc/nginx/sites-enabled/http-only.server ]]; then
		info "Nginx: HTTP server is still active, removing now"
		if sudo rm /etc/nginx/sites-enabled/http-only.server ; then
			success "Nginx: HTTP server is now removed"
		else
			fail "Nginx: HTTP server failed to be removed"
		fi
	else
		success "Nginx: HTTP server is already removed"
	fi

# Restarts nginx
	if sudo service nginx restart ; then
		success "Nginx: HTTPS is now correctly setup"
	else
		fail "Nginx: HTTPS failed to be correctly setup, please check the logs for more details"
	fi
