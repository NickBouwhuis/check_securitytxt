#!/bin/bash

# Parse command line arguments
while [[ $# -gt 0 ]]
do
  case "$1" in
    -u|--url)
      URL="$2/.well-known/security.txt"
      shift 2
      ;;
    -w|--warning)
      WARNING="$2"
      shift 2
      ;;
    -c|--critical)
      CRITICAL="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Check if required arguments are provided
if [[ -z "$URL" || -z "$WARNING" || -z "$CRITICAL" ]]; then
  echo "Usage: $(basename "$0") -u <url> -w <warning_days> -c <critical_days>"
  exit 1
fi

# Get the current date and calculate the warning and critical thresholds
CURR_DATE=$(date +%s)
WARNING_THRESHOLD=$(($CURR_DATE + $WARNING * 86400))
CRITICAL_THRESHOLD=$(($CURR_DATE + $CRITICAL * 86400))

# Get the expiration date from the URL
EXP_DATE=$(curl -sL "$URL" | grep -i "expires" | tr -d '\r' | awk -F'Expires: ' '{print $2}' | xargs -I {} date -d "{}" +%s)

# Check if the expiration date is within the warning or critical threshold
if [[ "$EXP_DATE" -gt "$WARNING_THRESHOLD" ]]; then
  echo "OK: The security.txt expires on $(date -d @$EXP_DATE +"%Y-%m-%d %H:%M:%S"). More than $WARNING days away."
  exit 0
elif [[ "$EXP_DATE" -gt "$CRITICAL_THRESHOLD" ]]; then
  echo "WARNING: The security.txt expires on $(date -d @$EXP_DATE +"%Y-%m-%d %H:%M:%S"). Within $WARNING days."
  exit 1
else
  echo "CRITICAL: The security.txt expires on $(date -d @$EXP_DATE +"%Y-%m-%d %H:%M:%S"). Within $CRITICAL days."
  exit 2
fi
