#!/usr/bin/with-contenv sh

# Run rclone only if the previous cron job finished
(

  flock -n 200 || exit 1

  # Setup a basic rclone command
  job_command="rclone --ask-password=false --config=/config/.rclone.conf --verbose --checksum $RCLONE_MODE $RCLONE_SOURCE $RCLONE_DESTINATION"

  # Check if the container is running a customer rclone command, otherwise,
  # ensure a mode, source and destination are provided. If not, bail out.
  if [ "$RCLONE_COMMAND" ]; then
    job_command="$RCLONE_COMMAND"
  else
    if [ -z "$RCLONE_MODE" ]; then
      echo "Error: No rclone mode was specified for job execution"
      exit 1
    elif [ -z "$RCLONE_SOURCE" ] || [ -z "$RCLONE_DESTINATION" ]; then
      echo "Error: Source or Destination options for rclone were not passed to the container."
      exit 1
    elif [ "$RCLONE_BANDWIDTH" ]; then
      job_command="rclone --ask-password=false --config=/config/.rclone.conf --verbose --checksum --bwlimit $RCLONE_BANDWIDTH $RCLONE_MODE $RCLONE_SOURCE $RCLONE_DESTINATION"
    fi
  fi

  echo "Info: Executing => $job_command"
  eval "$job_command"

  if [ "$JOB_SUCCESS_URL" ]; then
    echo "Info: Reporting job success to health check endpoint"
    curl --retry 3 $JOB_SUCCESS_URL
  fi
  
  if [ "$JOB_NOTIFY_URL" ]; then
    echo "Info: Reporting job done to notification url"
    curl --retry 3 $JOB_NOTIFY_URL
  fi
  
) 200>/var/lock/rclone.lock
