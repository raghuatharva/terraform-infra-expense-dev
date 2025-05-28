#!/bin/bash

start_date="2024-11-01"
end_date="2024-11-31"
total_commits=40

commit_messages=(
  "Fix CI pipeline trigger"
  "Update Terraform output names"
  "Add logs to debug ECS rollout"
  "Tweak ALB target group settings"
  "Refactor VPC module"
  "Remove unused security group"
  "Tag EC2 instances with env"
  "Add lifecycle rule to S3 bucket"
  "Fix subnet CIDR overlap"
  "Update Jenkins agent AMI"
  "Improve Lambda timeout config"
  "Test secret rotation schedule"
  "Enable cloudwatch log group retention"
  "Adjust IAM trust relationship"
  "Cleanup unused Lambda layers"
  "Document README for setup"
  "Restructure Terraform modules"
  "Patch SSM access issue"
  "Fix RDS backup window timing"
  "Add NAT Gateway alarm"
)

dummyfile="dummyfile.txt"
touch $dummyfile

# Generate all July days
july_days=()
current_date="$start_date"
while [[ "$current_date" < "$end_date" ]] || [[ "$current_date" == "$end_date" ]]; do
  july_days+=("$current_date")
  current_date=$(date -j -v+1d -f "%Y-%m-%d" "$current_date" "+%Y-%m-%d")
done
day_count=${#july_days[@]}

# Array to store how many commits per day (high-low spread)
declare -A daily_commit_count

# Distribute commits unevenly
remaining=$total_commits
while [ $remaining -gt 0 ]; do
  # Pick random day
  rand_index=$((RANDOM % day_count))
  day="${july_days[$rand_index]}"
  
  # Max 4 commits per day for uneven feel
  add=$((1 + RANDOM % 4))
  if [ $add -gt $remaining ]; then
    add=$remaining
  fi
  ((daily_commit_count["$day"]+=add))
  ((remaining-=add))
done

commit_counter=0
for day in "${!daily_commit_count[@]}"; do
  for ((i=0; i<daily_commit_count["$day"]; i++)); do
    hour=$(( RANDOM % 24 ))
    min=$(( RANDOM % 60 ))
    sec=$(( RANDOM % 60 ))
    time=$(printf "%02d:%02d:%02d" $hour $min $sec)
    full_datetime="$day""T""$time"

    message="${commit_messages[$((commit_counter % ${#commit_messages[@]}))]}"
    echo "$full_datetime - $message" > $dummyfile

    git add $dummyfile
    GIT_COMMITTER_DATE="$full_datetime" git commit --date="$full_datetime" -m "$message"

    echo "✅ Commit #$((commit_counter+1)) done on $day at $time"
    ((commit_counter++))
  done
done
