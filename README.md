![Rclone Logo](http://rclone.org/img/rclone-120x120.png)

This is an Unofficial Docker container for rclone based on freely available Linux (x64) binaries at [http://rclone.org/downloads/](http://rclone.org/downloads/)

# madcatsu/docker-rclone-cron

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
docker run -it -rm \
-e PUID=<host user ID> \
-e PGID=<host group ID> \
-e RCLONE_MODE=config
-v /etc/localtime:/etc/localtime:ro \
-v </path/to/your/persistent/config/folder>:/config \
-v </path/to/your/data/folder/>:/data \
madcatsu/docker-rclone-cron
```

### Custom rclone job
```
docker run --name=<container name> \
-e PUID=<host user ID> \
-e PGID=<host group ID> \
-e RCLONE_COMMAND=
-v /etc/localtime:/etc/localtime:ro \
-v </path/to/your/persistent/config/folder>:/config \
-v </path/to/your/data/folder/>:/data \
madcatsu/docker-rclone-cron
```

### Regular Container scheduling
```
docker run --name=<container name> \
-e PUID=<host user ID> \
-e PGID=<host group ID> \
-e RCLONE_MODE=<sync, copy, etc>
-e CRON_SCHEDULE="0/30 * * * *"
-e RCLONE_CONFIG_PASS=<password> ** OPTIONAL **
-e RCLONE_DESTINATION=<rclone destination>
-e RCLONE_DESTINATION_SUBPATH=<rclone destination sub-path> ** OPTIONAL **
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
* `-e RCLONE_MODE` - Available modes are normally `copy`, `sync` or `config`. **This parameter is mandatory unless you specify the RCLONE_COMMAND environment variable** See more available sub-commands at [http://rclone.org/docs/](http://rclone.org/docs/)
* `-e RCLONE_COMMAND` A custom rclone command which will override the default
* `-e CRON_SCHEDULE` A custom cron schedule which will override the default value of: 0 * * * * (hourly)
* `-e RCLONE_CONFIG_PASS` If the `.rclone.conf` configuration file is encrypted, specify the password here
* `-e RCLONE_DESTINATION` The destination that the data should be backed up to (must be the same name as specified in .rclone.conf)
* `-e RCLONE_DESTINATION_SUBPATH` If the data should be backed up to a subpath on the destination (the path will be automatically created if it does not exist)

### Bind mounts

* `-v /config` The path where the .rclone.conf file is
* `-v /data` The path to the data which should be backed up by Rclone

### Info

* Shell access whilst the container is running: docker exec -it <container name / ID> /bin/bash
* To monitor the logs of the container in realtime: docker logs -f <container name / ID>

### Known Issues
+ `rclone mount` is not available and will fail / crash rclone if used within the container as the Fuse binaries/libraries are not included in the container image. FUSE is known to have issues with bind mounted paths inside a container and requires access to kernel on the host

### Versions

+ **2017/02/11:**
  * Initial release
