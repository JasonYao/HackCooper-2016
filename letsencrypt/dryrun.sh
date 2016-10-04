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

# Runs through a dry run
if /server/letsencrypt/build/certbot-auto --config /etc/letsencrypt/cli.ini --dry-run --agree-tos certonly > /server/letsencrypt/logs/dry/letsEncrypt-"$(date +"%d-%m-%y-%H")".log ; then
	success "Letsencrypt: Dry run was a success" > /server/letsencrypt/logs/dry/letsEncrypt-"$(date +"%d-%m-%y-%H")".log
else
	fail "Letsencrypt: Dry run failed" > /server/letsencrypt/logs/dry/letsEncrypt-"$(date +"%d-%m-%y-%H")".log
fi
