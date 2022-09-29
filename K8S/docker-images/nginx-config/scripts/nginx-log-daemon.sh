#!/bin/sh

log_dir="/var/log/nginx/"
log_path="/var/log/nginx/access.log"
K=1024
limit=50
delay=5
html_path="${HOME}/public_html"
tail_count=20
while true; do
        #collecting CPU metrics and parsing them to html
        cpu_usage=$(top -b -n 1 | sed '6,$d' | awk 'BEGIN{ ORS="<br>"; OFS="\t"} { print $0; }')
        touch $html_path/monitoring/monitoring.html && \
        awk -v CPU_UT="$cpu_usage" {' sub(/<span id="cpu-usage">.*/, "<span id=\"cpu-usage\">"CPU_UT"</span>"); print;'} $html_path/monitoring.template.html > $html_path/monitoring/monitoring.html
        date >> $html_path/monitoring/monitoring.html
        #collecting 4XX and 5XX errors, checking thier existance in logs, pushing them otherwise in logs
        #errors4XX=$(tail -n $tail_count $log_path | awk '$9 ~ /4[0-9]{2}/{print $0;}' )
        #errors5XX=$(tail -n $tail_count $log_path | awk '$9 ~ /5[0-9]{2}/{print $0;}' )
        #last4XX=$(tail -n 1 $log_dir/error4XX.log | awk '{print $4}')
        #last5XX=$(tail -n 1 $log_dir/error5XX.log | awk '{print $4}')
        #IFS=$'\n'
        #for e4XX in $errors4XX; do
        #        echo "error400 $e4XX"
        #        d4XX=$(echo $e4XX | awk '{print $4;}')
        #        if [ "$last4XX" \< "$d4XX" ]; then
        #                echo $e4XX >> $log_dir/error4XX.log
        #                echo "4XX error logged"
        #        fi
        #done
#
        #for e5XX in $errors5XX; do
        #        echo "error500 $e5XX"
        #        d4XX=$(echo $e5XX | awk '{print $4;}')
        #        if [ "$last5XX" \< "$d5XX" ]; then
        #                echo $e5XX >> $log_dir/error5XX.log
        #                echo "5XX error logged"
        #        fi
        #done
#
        #IFS=$' '
        ##checking amount of storage consumed by logs
        #disk_usage_by_access_log=$( ls -la $log_path | awk '{print $5}')
        #if [ $disk_usage_by_access_log -ge  $(( $limit * $K )) ] ; then
        #        echo "$(date) - log pruning, exceded $limit KB" > $log_dir/prune.log
        #        echo "" >> $log_path
        #        echo "$(date) access.log pruned and logged"
        #fi
#
        sleep $delay;
done