# Vagrant
By Jason Yao

## Description
This section contains the files required to use [vagrant](https://www.vagrantup.com/),
a way for developers to get the same development environment regardless of their
underlying platform.

The project root directory is automatically shared by vagrant, and is found at `/server`
in the virtual machine client. This means that you can have an IDE open and editing
the source files on your own development machine, and have the files be updated in
real-time on the development server.

## Setup
### Download virtualbox
```sh
# OSX only
brew update && brew upgrade
brew tap caskroom/cask
brew cask install virtualbox
```
OR

http://download.virtualbox.org/virtualbox/

### Download Vagrant
```sh
brew cask install vagrant
```

OR

https://www.vagrantup.com/downloads.html

```sh
# Ain't this shit just dandy
vagrant up && vagrant ssh
```

## Common errors
if you get a `'vboxf' is not available` error, try:
```sh
vagrant plugin install vagrant-vbguest
```

## Common commands
Start the virtual machine
```sh
vagrant up
```

SSH into the virtual machine
```sh
vagrant ssh
```

Stop the virtual machine
```sh
vagrant halt
```

Destroy the virtual machine (all files purged)
```sh
vagrant destroy
```
