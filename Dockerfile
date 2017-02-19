FROM alpine
MAINTAINER madcatsu

# global environment settings
ENV OVERLAY_VERSION="v1.19.1.1"
ENV RCLONE_VERSION="current"
ENV PLATFORM_ARCH="amd64"
# s6 environment settings
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_KEEP_ENV=1

# install base packages
RUN \
  apk update && \
  apk add --no-cache \
    ca-certificates \
    curl \
    unzip \
    bash && \
  apk add --no-cache --repository http://nl.alpinelinux.org/alpine/edge/community \
    shadow && \

# add s6 overlay
  curl -o \
    /tmp/s6-overlay.tar.gz -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${PLATFORM_ARCH}.tar.gz" && \
  tar xfz \
    /tmp/s6-overlay.tar.gz -C /

# Fetch rclone binaries
RUN \
  curl -o \
    /tmp/rclone-binaries.zip -L \
      "http://downloads.rclone.org/rclone-${RCLONE_VERSION}-linux-${PLATFORM_ARCH}.zip" && \
  cd /tmp && \
  unzip /tmp/rclone-binaries.zip && \
  mv /tmp/rclone-*-linux-${PLATFORM_ARCH}/rclone /usr/bin

# cleanup
RUN \
  rm -rf \
	/tmp/* \
	/var/tmp/* \
	/var/cache/apk/*

# create abc user
RUN \
	groupmod -g 1000 users && \
	useradd -u 911 -U -d /config -s /bin/false abc && \
	usermod -G users abc && \

# create some files / folders and symlink verbose job logs to PID 1 stderr
	mkdir -p /config /app /defaults /data && \
	touch /var/lock/rclone.lock && \
  ln -sf /proc/1/fd/2 /var/log/rclone-cron-job.log

# add local files
COPY root/ /

VOLUME ["/config"]

ENTRYPOINT ["/init"]
