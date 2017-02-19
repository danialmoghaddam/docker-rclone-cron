#!/usr/bin/with-contenv sh

# Run rclone only if the previous cron job finished
(
  flock -n 200 || echo "Warning: rclone job is already running" && exit 1

  job_command="rclone --ask-password=false --verbose --checksum $RCLONE_MODE /data $RCLONE_DESTINATION:/$RCLONE_DESTINATION_SUBPATH"

  if [ "$RCLONE_COMMAND" ]; then
    job_command="$RCLONE_COMMAND"
  elif [ -z "$RCLONE_DESTINATION" ]; then
      echo "Error: RCLONE_DESTINATION environment variable was not passed to the container."
      exit 1
  elif [ "$RCLONE_BANDWIDTH" ]; then
      job_command="rclone --ask-password=false --verbose --checksum --bwlimit $RCLONE_BANDWIDTH $RCLONE_MODE /data $RCLONE_DESTINATION:/$RCLONE_DESTINATION_SUBPATH"
  fi

  echo "Info: Executing => $job_command"
  eval "$job_command"

  if [ "$JOB_SUCCESS_URL" ]; then
    echo "Info: Reporting job success to Healtcheck.io"
    curl --retry 3 $JOB_SUCCESS_URL
  fi
)
  200>/var/lock/rclone.lock
