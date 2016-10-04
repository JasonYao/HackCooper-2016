# Let's Encrypt: Free Automated TLS certificate
By Jason Yao - [letsencrypt](https://letsencrypt.org/)

## Description
We'll use the Let's Encrypt service to automate the generation and deployment of each of our TLS certs, 
such that automatic generation and deployment will occur.

## Letsencrypt download

```sh
git clone https://github.com/letsencrypt/letsencrypt build
```

## Running the program

### Using the [run](run.sh) script
```sh
./run.sh
```

### Using the [manual run](run-manually.sh) script
```sh
./run-manually.sh
```

### The really manual way
```sh
cd build
./letsencrypt-auto --config /etc/letsencrypt/cli.ini --agree-tos certonly
```

## `Cron` job
To have the server automatically run the `cron` job once a month, follow the steps only ONCE 
(otherwise the program will run multiple times at the same time, crashing your system).

0.) Opens up your system's root crontab
```sh
sudo crontab -e
```

1.) Scroll to the bottom, and paste the following code on a new line:
```sh
# Dryrun runs it twice a day for status checking
0 */12 * * * /bin/bash /server/letsencrypt/dryrun.sh

# Actual runs it once a month
0 0 1 * * /bin/bash /server/letsencrypt/setup.sh
```

2.) hit `ENTER` again so there's a newline at the end of the file, then save your work.

## Configuration file
The [configuration file](cli.ini) for LE will be symlinked to /etc/letsencrypt/cli.ini.

