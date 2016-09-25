# uWSGI Section
By Jason Yao

## Description
This directory contains two parts, a systemd service file to
regenerate uWSGI at boot, and the configuration files for the
uWSGI server itself.

## Setup
Symlink the new [systemd service](uwsgi.service):

```sh
sudo ln -s /server/uwsgi/uwsgi.service /etc/systemd/system/uwsgi.service
```

## Managing the service:
### Start:

```sh
sudo service uwsgi start
```
### Stop:
```sh
sudo service uwsgi stop
```

### Restart:
```sh
sudo service uwsgi restart
```
