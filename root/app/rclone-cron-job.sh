#!/usr/bin/with-contenv sh

# Run rclone only if the previous cron job finished
(
  flock -n 200 || echo "Warning: rclone job is already running" >> /var/log/rclone-cron-job.log && exit 1

  job_command="rclone --ask-password=false --verbose --log-file=/var/log/rclone-cron-job.log --checksum $RCLONE_MODE /data $RCLONE_DESTINATION:/$RCLONE_DESTINATION_SUBPATH"

  if [ "$RCLONE_COMMAND" ]; then
    job_command="$RCLONE_COMMAND"
  elif [ -z "$RCLONE_DESTINATION" ]; then
      echo "Error: RCLONE_DESTINATION environment variable was not passed to the container." >> /var/log/rclone-cron-job.log
      exit 1
  elif [ "$RCLONE_BANDWIDTH" ]; then
      job_command="rclone --ask-password=false --verbose --log-file=/var/log/rclone-cron-job.log --checksum --bwlimit $RCLONE_BANDWIDTH $RCLONE_MODE /data $RCLONE_DESTINATION:/$RCLONE_DESTINATION_SUBPATH"
  fi

  echo "Info: Executing => $job_command" >> /var/log/rclone-cron-job.log
  eval "$job_command"

  if [ "$JOB_SUCCESS_URL" ]; then
    echo "Info: Reporting job success to Healtcheck.io" >> /var/log/rclone-cron-job.log
    curl --retry 3 $JOB_SUCCESS_URL
  fi
)
  200>/var/lock/rclone.lock
