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

# Sets up nginx
info "Nginx: Checking status now"
if [[ $(grep "nginx" "/etc/apt/sources.list") == "" ]]; then
	# Gets the nginx signing key
	info "Nginx: Mainline repo was not found, downloading signing key now"
	if wget http://nginx.org/keys/nginx_signing.key -q --show-progress -O ~/nginx.key; then
		success "Nginx: Signing key is now downloaded"
	else
		fail "Nginx: Signing key failed to download"
	fi

	# Adds the key
	if sudo apt-key add ~/nginx.key ; then
		success "Nginx: Signing key is now added as valid"
		rm ~/nginx.key
	else
		fail "Nginx: Signing key failed to be added as valid"
	fi

	# Adds the nginx mainline trunk to the package sources
	info "Nginx: Adding mainline trunk to package sources"
	if {
		echo ""
		echo "# Nginx setings"
		echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx"
		echo "deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx"
	} | sudo tee --append /etc/apt/sources.list > /dev/null ; then
		success "Nginx: Mainline trunk is now added to the package source"
	else
		fail "Nginx: Mainline trunk failed to be added to the package source"
	fi
else
	success "Nginx: Mainline trunk is already added to the package source"
fi

# Updates current packages
info "Apt: Updating packages now"
if sudo apt-get update > /dev/null ; then
	success "Apt: Packages successfully updated"
else
	fail "Apt: Packages failed to be updated"
fi

# Checks for installed nginx package
if [[ $(dpkg --get-selections | grep nginx) == "" ]]; then
	info "Nginx: Mainline package is not installed, installing now"
	if sudo apt-get install nginx -y > /dev/null ; then
		success "Nginx: Latest mainline package is now installed"
	else
		fail "Nginx: Latest mainline package failed to be installed"
	fi
else
	info "Nginx: Mainline package is already installed, upgrading now"
	if sudo apt-get upgrade -y > /dev/null ; then
		success "Nginx: Mainline package is now updated to the latest version"
	else
		fail "Nginx: Mainline package failed to be updated to the latest version"
	fi
fi

# Checks on common directories status
info "Nginx: Checking on common directories status"

function check_nginx {
	if [[ ! -d /etc/nginx/$1 ]]; then
		info "Nginx: $1 directory is not set up, setting up now"
		if sudo mkdir /etc/nginx/"$1" ; then
			success "Nginx: $1 directory is now set up"
		else
			fail "Nginx: $1 directory failed to be set up"
		fi
	else
		success "Nginx: $1 directory is already set up"
	fi
}

check_nginx "sites-available"
check_nginx "sites-enabled"

if [[ -h /etc/nginx/nginx.conf ]]; then
	success "Nginx: Configuration file is already set up"
else
	info "Nginx: Configuration file is not correctly linked, linking now"

	# Stops current nginx service
	info "Nginx: Stopping current nginx service"
	if sudo service nginx stop ; then
		success "Nginx: Service is now stopped"
	else
		fail "Nginx: Service failed to be stopped"
	fi

	# Backs up old configuration file
	info "Nginx: Backing up old configuration file"
	if sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup ; then
		success "Nginx: Old configuration file is now backed up"
	else
		fail "Nginx: Old configuration file failed to back up"
	fi

	# Links new configuration file
	info "Nginx: Linking new configuration file"
	if sudo ln -s /server/nginx/nginx.conf /etc/nginx/nginx.conf ; then
		success "Nginx: New configuration file is now linked"
	else
		fail "Nginx: New configuration file failed to be linked"
	fi

	# Restarts the nginx service
	if sudo service nginx restart ; then
		success "Nginx: Service is now restarted"
	else
		fail "Nginx: Service failed to restart"
	fi
fi

# Links all nginx server files
for server_file in /server/nginx/*.server ; do
	server_file_name=$(basename "$server_file")
	if [[ -h /etc/nginx/sites-available/$server_file_name ]]; then
		success "Nginx: Server file $server_file_name is already linked"
	else
		info "Nginx: Server file $server_file_name is not linked, linking now"
		if sudo ln -s /server/nginx/"$server_file_name" /etc/nginx/sites-available/"$server_file_name" ; then
			success "Nginx: Server file $server_file_name is now linked"
		else
			fail "Nginx: Server file $server_file_name failed to be linked"
		fi
	fi
done
