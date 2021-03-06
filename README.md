![Rclone Logo](http://rclone.org/img/rclone-120x120.png)

This is an Unofficial Docker container for rclone based on freely available Linux (x64) binaries at [http://rclone.org/downloads/](http://rclone.org/downloads/) and forked from **tynor88's** original project @ [https://github.com/tynor88/docker-rclone](https://github.com/tynor88/docker-rclone)

# madcatsu/docker-rclone-cron

[![Docker Version](https://images.microbadger.com/badges/version/madcatsu/docker-rclone-cron.svg)][hub]
[![Docker Layers](https://images.microbadger.com/badges/image/madcatsu/docker-rclone-cron.svg)][hub]
[![Docker Build](https://img.shields.io/docker/automated/tynor88/rclone.svg)][hub]
[![Docker Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://hub.docker.com/r/madcatsu/airvideohd/builds/)
[hub]: https://hub.docker.com/r/madcatsu/docker-rclone-cron/


rclone for Docker - rclone provides a set of commands similar to rsync for working with Public or Private Cloud Storage providers that leverage the S3 or Swift REST API.

**Cloud Services**
* Google Drive
* Amazon S3
* Openstack Swift / Rackspace cloud files / Memset Memstore
* Dropbox
* Google Cloud Storage
* Amazon Drive
* Microsoft One Drive
* Hubic
* Backblaze B2
* Yandex Disk
* The local filesystem

**Features**

* MD5/SHA1 hashes checked at all times for file integrity
* Timestamps preserved on files
* Partial syncs supported on a whole file basis
* Copy mode to just copy new/changed files
* Sync (one way) mode to make a directory identical
* Check mode to check for file hash equality
* Can sync to and from network, eg two different cloud accounts
* Optional encryption (Crypt)

## Usage

### First run
```
docker run -it --rm \
-e PUID=<host user ID> \
-e PGID=<host user group ID> \
-v </path/to/your/persistent/config/folder>:/config \
-v </path/to/your/data/folder/>:/data \
madcatsu/docker-rclone-cron \
rclone --config=/config/.rclone.conf config
```

### Custom rclone job
_You will need to specify the full rclone command in the format 'rclone <operation> source destination' if you elect to use this environment variable_

_Be mindful that the container will not terminate when your custom command completes as the s6-overlay acts as a supervisor for the cron daemon, which will keep running your custom rclone command with the default hourly schedule_

```
docker run --name=<container name> \
-e PUID=<host user ID> \
-e PGID=<host user group ID> \
-e RCLONE_COMMAND=<your custom rclone command>
-v /etc/localtime:/etc/localtime:ro \
-v </path/to/your/persistent/config/folder>:/config \
-v </path/to/your/data/folder/>:/data \
madcatsu/docker-rclone-cron
```

### Regular Container scheduling
```
docker run -d --name=<container name> \
-e PUID="<host user ID>" \
-e PGID="<host user group ID>" \
-e RCLONE_MODE="<sync, copy, etc>" \
-e CRON_SCHEDULE="0/30 * * * *" \ ** OPTIONAL **
-e RCLONE_CONFIG_PASS=""<password>" \ ** OPTIONAL **
-e RCLONE_SOURCE="<rclone source>" \
-e RCLONE_DESTINATION="<rclone destination>" \
-e RCLONE_BANDWIDTH="<bandwidth value>" \
-e JOB_SUCCESS_URL="<healthcheck API endpoint>" ** OPTIONAL **
-e JOB_NOTIFY_URL="<notification API endpoint>" ** OPTIONAL **
-v /etc/localtime:/etc/localtime:ro \
-v </path/to/your/persistent/config/folder>:/config \
-v </path/to/your/data/folder/>:/data \
madcatsu/docker-rclone-cron
```

### User / Group / Environment Variables

* `-e PUID` & `-e PGID` - The container leverages s6-overlay supervisor and init system which allows users to specify a user and group from the Docker host machine to run the in-container processes and access any bind mounts on the host without messing up permissions which can easily occur when processes in a container run as "root".

The container avoids this issue by allowing users to specify an existing Docker host user account and group with the `PUID` and `PGID` environment variables. To lookup the User and Group ID of the Docker host user account, enter the following command in the CLI on the Docker host as below:

```
    $ id <username>
    uid=1000(username) gid=1000(usergroup) groups=1000(usergroup),27(sudo) ... etc
```
* `-e RCLONE_MODE` - Available modes are normally `copy` or `sync`. **This parameter is mandatory unless you specify the RCLONE_COMMAND environment variable** See more available sub-commands at [http://rclone.org/docs/](http://rclone.org/docs/)
* `-e RCLONE_COMMAND` A custom rclone command which will override the default job
* `-e CRON_SCHEDULE` A custom cron schedule which will override the default value of: 0 * * * * (hourly)
* `-e RCLONE_CONFIG_PASS` If the `.rclone.conf` configuration file is encrypted, specify the password here
* `-e RCLONE_BANDWIDTH` Bandwidth to be allocated to the rclone data mover. Specify as a number followed by an extension in bytes, kilobytes or megabytes (per second). Eg. 1G = 1GB/sec, 50M = 50MB/sec, 512K = 512KB/sec, etc. If this value is not set, rclone will utilise whatever bandwidth is available
* `-e RCLONE_SOURCE` The source for data that should be backed up. Must match either `/data` for data being pushed to a remote location, or the name of the remote specified in .rclone.conf if data is being pulled from the remote specified in .rclone.conf **This parameter is mandatory unless you specify the RCLONE_COMMAND environment variable**
* `-e RCLONE_DESTINATION` The destination that the data should be backed up to. Must match either `/data` for data being pulled from a remote location, or the name of the remote specified in .rclone.conf **This parameter is mandatory unless you specify the RCLONE_COMMAND environment variable**
* `-e JOB_SUCCESS_URL` At the end of each rclone cron job, report to a healthcheck API endpoint at a defined web URI (eg. WDT.io or Healthchecks.io)

#### RCLONE_SOURCE and RCLONE_DESTINATION usage
As rclone allows data to be uploaded to a pre-defined remote, or downloaded from the same, the `RCLONE_SOURCE` and `RCLONE_DESTINATION` environment variables can be used interchangeably. In either form, one of these variables must be specified as "/data" as this path is bind mounted to the Docker container with access to the host file system. To demonstrate, both a push and pull scenario are further outlined:

* **Uploading local data to remote cloud storage:** In this form, `RCLONE_SOURCE` should be passed to the container with the value of "/data" (without the literal quotes). The `RCLONE_DESTINATION` variable should take the form of "<remote name>:/<sub-path>". Eg. `RCLONE_DESTINATION="Amazon-Cloud-Drive:/Backups"`
* **Downloading data from remote cloud storage:** In this form, `RCLONE_SOURCE` and `RCLONE_DESTINATION` variables in the previous example should be swapped. Thus, `RCLONE_SOURCE="Amazon-Cloud-Drive:/Backups"`.

### Bind mounts

* `-v </path/to/your/persistent/config/folder>:/config` The path where the .rclone.conf file is stored
* `-v </path/to/your/data/folder/>:/data` The path which rclone should use for backup or restore operations
* `-v /etc/localtime:/etc/localtime:ro` Will capture the local host system time for log output. _If you prefer UTC output, you can skip this bind mount_

### Info

* Shell access whilst the container is running: docker exec -it <container name / ID> /bin/bash
* To monitor the logs of the container in realtime: docker logs -f <container name / ID>
* When running a custom rclone job via the `RCLONE_COMMAND` environment variable, using `--verbose --log-file=/var/log/rclone-cron-job.log` will provide a way to view job output with the above "docker logs" command

### Known Issues
+ `rclone mount` is not available and will fail / crash rclone if used within the container as the Fuse binaries/libraries are not included in the container image. FUSE is known to have issues with bind mounted paths inside a container and requires access to kernel on the host

### Versions

+ **2017/02/11:**
  * Initial release and push to Docker Hub
+ **2017/02/19:**
  * Tweaks to README file and first run logic
  * Added options for bandwidth throttling
+ **2017/02/20:**
  * Added verbose logging by default to rclone cron job
  * Changed environment vars to allow both upload and download jobs
