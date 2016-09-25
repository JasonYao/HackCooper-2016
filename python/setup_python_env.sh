#!/usr/bin/env bash

set -e

production_version="3.5.2"
virtualenv_name="production-3.5.2"
packages=(pip setuptools virtualenv virtualenvwrapper)
virtualenv_packages=(django uwsgi psycopg2)

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

# Checks for the production python version
info "Python: Checking for python version $production_version"
if [[ $(pyenv versions | grep "$production_version") == "" ]]; then
	info "Python: Version $production_version is not installed, installing now"
	if pyenv install "$production_version" ; then
		success "Python: Version $production_version is now installed"
	else
		fail "Python: Version $production_version failed to install"
	fi
else
	success "Python: Version $production_version is already installed"
fi

# Checks for the pyenv-virtualenv
info "Pyenv-virtualenv: Checking for the production virtualenv $virtualenv_name"
if [[ $(pyenv versions | grep "$production_version" | grep "$virtualenv_name") == "" ]]; then
	info "Pyenv-virtualenv: Production virtualenv is not created yet, creating now"
	if pyenv virtualenv "$production_version" "$virtualenv_name" ; then
		success "Pyenv-virtualenv: Production virtualenv is now created"
	else
		fail "Pyenv-virtualenv: Production virtualenv failed to be created"
	fi
else
	success "Pyenv-virtualenv: Production virtualenv is already created"
fi

# Sets up uWSGI server dependency
if [[ $(dpkg --get-selections | grep python-dev) == "" ]]; then
	info "uWSGI: Python dev package is not yet installed, installing now"
	if sudo apt-get install python-dev ; then
		success "uWSGI: Python dev package is now installed"
	else
		fail "uWSGI: Python dev package failed to be installed"
	fi
else
	success "uWSGI: Python dev package is already installed"
fi

# Checks on pip packages
if [[ $(uname -s) == "Linux" ]]; then
	export PYENV_ROOT="$HOME"/.pyenv
	export PATH="$PYENV_ROOT/bin:$PATH"
	export PYENV_VIRTUALENV_DISABLE_PROMPT=1

	if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
	if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
fi

pyenv global "$virtualenv_name"
pyenv activate
for package in "${packages[@]}"; do
	install_and_upgrade "${package}"
done
pyenv deactivate

# Installs the virtualenv
if [[ -d /server/.env ]]; then
	success "Virtualenv: Production env is already installed"
else
	info "Virtualenv: Production env is not yet installed, installing now"
	if virtualenv /server/.env ; then
		success "Virtualenv: Production env is now installed"
	else
		fail "Virtualenv: Production env failed to be installed"
	fi
fi

source /server/.env/bin/activate
for package in "${virtualenv_packages[@]}"; do
    install_and_upgrade "${package}"
done
deactivate
