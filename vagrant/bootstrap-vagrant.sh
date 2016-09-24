#!/usr/bin/env bash

set -e

##
# Setup script for vagrant that provisions:
# Nginx: Reverse proxy over port 8080 on the host machine, serving HTTP content
# uWSGI: Application server to serve the django application
# Django: Application framework containing all business logic and content
# Postgresql: Database set up with default values for dev purposes
##

# Settings
virtualenv_packages=(django uwsgi psycopg2)

# Sources secret settings (development only with vagrant)
db_username="dev"
db_password="password"
db_name="dev"
site_name="TakeUp"

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
function checkAndInstallPackage ()
{
	info "Checking for $1"
	if dpkg -s "$1" > /dev/null 2>&1 ; then
		success "$1 is already installed"
	else
		info "$1 not found, installing now"
		if  apt-get install "$1" -y > /dev/null ; then
			success "$1 successfully installed"
		else
			fail "$1 failed to install"
		fi
	fi
}
function install_and_upgrade_python {
	info "Pip: Checking $1 status"
	if pip install --upgrade "$1" &> /dev/null ; then
		success "Pip: $1 is now installed and updated"
	else
		fail "Pip: $1 failed to install/upgrade"
	fi
}
function update_packages {
	info "Updating packages"
	if  apt-get update -y > /dev/null ; then
		success "Packages were updated"
	else
		fail "Packages were unable to be updated"
	fi
}
function check_nginx {
	if [[ ! -d /etc/nginx/$1 ]]; then
		info "Nginx: $1 directory is not set up, setting up now"
		if  mkdir /etc/nginx/"$1" ; then
			success "Nginx: $1 directory is now set up"
		else
			fail "Nginx: $1 directory failed to be set up"
		fi
	else
		success "Nginx: $1 directory is already set up"
	fi
}

# Updates & upgrades
	update_packages
	info "Upgrading packages"
	if  apt-get dist-upgrade -y > /dev/null ; then
		success "Packages were upgraded"
	else
		fail "Packages were unable to be upgraded"
	fi

# Installs global dependencies
	checkAndInstallPackage wget						# Used in general downloading
	checkAndInstallPackage git						# Used in general project upkeep
	checkAndInstallPackage python3-pip				# Used in env setup

# Installs psql dependencies
	checkAndInstallPackage postgresql
	checkAndInstallPackage postgresql-contrib
	checkAndInstallPackage python-psycopg2
	checkAndInstallPackage libpq-dev

# Installs uWSGI dependencies
	checkAndInstallPackage python3-dev

# Auto removes any unnecessary packages
	info "Auto removing any unnecessary packages"
	if  apt-get autoremove -y > /dev/null ; then
		success "All unnecessary packages removed"
	else
		fail "Unable to remove unnecessary packages"
	fi

# Links the correct secret settings if not already
if [[ -f /server/website/"$site_name"/settings_secret.py ]]; then
	success "Linking: Secrets are already linked"
else
	info "Linking: Secrets are not yet linked, using dev values for now"

	if {
		echo "SECRET_KEY = 'dvD(!Q}aAPw+u^.VtF]e>wpjy%[BfXSdprp?cpc%/Ts6lE[_yC'"
		echo "db_user = \"$db_user\""
		echo "db_password = \"$db_password\""
		echo "db_name = \"$db_name\""
		echo ""
		echo "# SECURITY WARNING: don't run with debug turned on in production!"
		echo "DEBUG = True"
		echo ""
		echo "# Set to the domain name and any subdomains (e.g. = ['.test.com'])"
		echo "# To set only a single domain: = ['www.test.com']"
		echo "# To set all subdomains (wildcard) = ['.test.com']"
		echo "# To set all domains (don't ever do this shit in production) = ['*']"
		echo "ALLOWED_HOSTS = ['*']"
		echo ""
		echo "# Emailing setting"
		echo "ANYMAIL = {"
		echo "    \"MAILGUN_API_KEY\": \"<your_mailgun_key_here>\","
		echo "}"
		echo "EMAIL_BACKEND = "anymail.backends.mailgun.MailgunBackend"  # or sendgrid.SendGridBackend, or...
		echo "DEFAULT_FROM_EMAIL = \"example@example.com\"  # if you don't already have this in settings"
	} >> /server/website/"$site_name"/settings_secret.py ; then
		success "Linking: Secrets are now configured for a dev environment"
	else
		fail "Linking: Secrets failed to be filled with dev values"
	fi
fi

# Installs db
	# Checks psql users status (creates user if not already created)
	if [[ $(sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$db_username'") == "1" ]]; then
		success "pSQL: Role $db_username is already created"
	else
		info "pSQL: Role $db_username is not yet created, creating now"
		if sudo -u postgres createuser "$db_username" --no-createdb --encrypted --no-createrole --no-superuser && sudo -u postgres psql postgres -tAc "ALTER USER \"$db_username\" WITH PASSWORD '$db_password'" postgres ; then
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

# Python env install
	if sudo pip3 install virtualenv virtualenvwrapper &> /dev/null ; then
		success "Python: virtualenv and virtualenvwrapper is now installed"
	else
		fail "Python: virtualenv and virtualenvwrapper failed to install"
	fi

	{
		echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3"
		echo "export WORKON_HOME=/home/ubuntu/.env"
		echo "source /usr/local/bin/virtualenvwrapper.sh"
	} >> /home/ubuntu/.bashrc
	source /home/ubuntu/.bashrc

	# Creates the virtualenv
	virtualenv /server/.env
	source /server/.env/bin/activate

	# Adds in the needed python packages
	for package in "${virtualenv_packages[@]}"; do
			install_and_upgrade_python "${package}"
	done

	# Sets up the logging file
	info "Setting up logging directory now"
	mkdir -p /var/log/django
	sudo chown -R $(whoami):www-data /var/log/django
	sudo chmod -R 777 /var/log/django

	# Sets up application
	if echo "yes" | /server/website/manage.py migrate ; then
		success "Manage.py: Migrations completed successfully"
	else
		fail "Manage.py: Migrations failed to complete"
	fi

	if echo "yes" | /server/website/manage.py collectstatic ; then
		success "Manage.py: Collect static completed successfully"
	else
		fail "Manage.py: Collect static failed to complete"
	fi

	if deactivate ; then
		success "Python env is now deactivated"
	else
		fail "Python env failed to deactivate"
	fi

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
	if  apt-key add ~/nginx.key ; then
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
	} |  tee --append /etc/apt/sources.list > /dev/null ; then
		success "Nginx: Mainline trunk is now added to the package source"
	else
		fail "Nginx: Mainline trunk failed to be added to the package source"
	fi
else
	success "Nginx: Mainline trunk is already added to the package source"
fi

	# We update now that we've added the mainline
	update_packages
	checkAndInstallPackage nginx

	# Sets the ubuntu user as a part of www-data (depends on nginx being installed first)
	usermod -a -G www-data ubuntu

	# Checks on common directories status
	info "Nginx: Checking on common directories status"

	check_nginx "sites-available"
	check_nginx "sites-enabled"

	if [[ -L /etc/nginx/nginx.conf ]]; then
		success "Nginx: Configuration file is already set up"
	else
		info "Nginx: Configuration file is not correctly linked, linking now"

		# Stops current nginx service
		info "Nginx: Stopping current nginx service"
		if  service nginx stop ; then
			success "Nginx: Service is now stopped"
		else
			fail "Nginx: Service failed to be stopped"
		fi

		# Backs up old configuration file
		info "Nginx: Backing up old configuration file"
		if  mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup ; then
			success "Nginx: Old configuration file is now backed up"
		else
			fail "Nginx: Old configuration file failed to back up"
		fi

		# Links new configuration file
		info "Nginx: Linking new configuration file"
		if  ln -s /server/nginx/nginx.conf /etc/nginx/nginx.conf ; then
			success "Nginx: New configuration file is now linked"
		else
			fail "Nginx: New configuration file failed to be linked"
		fi

		# Restarts the nginx service
		if  service nginx restart ; then
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
			if  ln -s /server/nginx/"$server_file_name" /etc/nginx/sites-available/"$server_file_name" ; then
				success "Nginx: Server file $server_file_name is now linked"
			else
				fail "Nginx: Server file $server_file_name failed to be linked"
			fi
		fi
	done

	# Links the HTTP server file
	if sudo ln -s /etc/nginx/sites-available/http-only.server /etc/nginx/sites-enabled/http-only.server ; then
		success "Nginx: HTTP server file is now linked"
	else
		fail "Nginx: HTTP server file failed to be linked"
	fi

	# Restarts the nginx service
	if  service nginx restart ; then
		success "Nginx: Service is now restarted"
	else
		fail "Nginx: Service failed to restart"
	fi

# Sets up uWSGI
	# Sets up uWSGI log file
	if [[ -d /var/log/uwsgi ]]; then
		success "uWSGI: Log directory is already created"
	else
		info "uWSGI: Log directory has not been created yet, creating now"
		if  mkdir -p /var/log/uwsgi/ ; then
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
		if  ln -s /server/uwsgi/uwsgi.service /etc/systemd/system/uwsgi.service ; then
			success "uWSGI: Systemd service file is now linked"
		else
			fail "uWSGI: Systemd service file failed to be linked"
		fi
	fi

	# Starts the uWSGI service
	if sudo service uwsgi restart ; then
		success "uWSGI: Service is now started"
	else
		fail "uWSGI: Service failed to start"
	fi

	# The service just now created the debug, need to chown it again
	info "uWSGI: Chowning debug file"
	if sudo chown -R www-data:www-data /var/log/django ; then
		success "uWSGI: Debug file is now correctly owned"
	else
		fail "uWSGI: Debug file failed to be correctly owned"
	fi

	# Starts the uWSGI service (again)
    if sudo service uwsgi restart ; then
        success "uWSGI: Service is now started"
    else
        fail "uWSGI: Service failed to start"
    fi
