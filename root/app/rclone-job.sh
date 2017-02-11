#!/usr/bin/with-contenv sh

# Run rclone only if the previous cron job finished
(
  flock -n 200 || echo "Warning: rclone job is already running" && exit 1

  job_command="rclone --ask-password=false $RCLONE_MODE /data $RCLONE_DESTINATION:/$RCLONE_DESTINATION_SUBPATH"

  if [ "$RCLONE_COMMAND" ]; then
  job_command="$RCLONE_COMMAND"
  else
    if [ -z "$RCLONE_DESTINATION" ]; then
      echo "Error: RCLONE_DESTINATION environment variable was not passed to the container."
      exit 1
    fi
  fi

  echo "Info: Executing => $job_command"
  eval "$job_command"
)
  200>/var/lock/rclone.lock
