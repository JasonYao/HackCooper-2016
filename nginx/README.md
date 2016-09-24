# NGINX Section
By Jason Yao

## Description
The nginx reverse proxy will serve the satic content from the site directly,
without the need to reach the application layer unless the cache object is stale.

## Setup
Setup is covered by the [setup script](setup.sh), which
sets up the nginx server itself, and then symlinks all
configuration files to their proper place, though leaves
the final symlinking to `sites-enabled` to you.

## Running
Start:

```sh
sudo service nginx start
```

Stop:

```sh
sudo service nginx stop
```

Restart:

```sh
sudo service nginx restart
```

**NOTE:** if you get the error message:
```
Failed to restart nginx.service: Unit nginx.service is masked.
```
Then simply run the following to unmask the `nginx` service:
```sh
sudo systemctl unmask nginx.service
```

## Checking log files
Access and error logs will be written to disk, respectively at `/var/log/nginx/access.log` and `/var/log/nginx/error.log`.
You'll need `sudo` privileges to go into the `/var/log/nginx` folder.

To check the last 10 entries quickly:

- The access log:

	- `sudo tail /var/log/nginx/access.log`

- The error log:

	- `sudo tail /var/log/nginx/error.log`

To check the last k entries, where k is a positive integer value:

- The access log:

	- `sudo tail -n k /var/log/nginx/access.log`

	- E.g.: `sudo tail -n 50 /var/log/nginx/access.log` # Will print the last 50 entries in the access log file

- The error log:

	- `sudo tail -n k /var/log/nginx/error.log`

	- E.g.: `sudo tail -n 50 /var/log/nginx/error.log` # Will print the last 50 entries in the error log file
