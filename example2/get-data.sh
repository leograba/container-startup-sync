#!/bin/bash

JENKINS_URL="https://jenkins.int.toradex.com/buildStatus/text"
JOB_LIST=(
    "kirkstone-6.x.y-nightly"
    "kirkstone-6.x.y-release"
    "dunfell-5.x.y-nightly"
    "dunfell-5.x.y-release"
    "master-extint"
)
INFLUX_MEASUREMENT_NAME="jenkinsbuild"
INFLUX_BUCKET_NAME="jenkinsdatabucket"
INFLUX_BUCKET_RETENTION="180d"
POLL_INTERVAL_SEC=60

function insert_into_influxdb() {
    
    # Get data points in a line protocol format
    # https://docs.influxdata.com/influxdb/v2/get-started/write/?t=influx+CLI#line-protocol
    local buildstatus="$INFLUX_MEASUREMENT_NAME "

    for job in "${JOB_LIST[@]}"; do
        # Jenkins Embeddable Build Status strings
        # https://plugins.jenkins.io/embeddable-build-status/#plugin-content-text-variant
        jobstatus=$(curl --silent "${JENKINS_URL}?job=image-torizoncore-${job}-matrix")
        if [ -n "$jobstatus" ]; then
            buildstatus="${buildstatus}${job}=\"${jobstatus}\","
            echo "Element: $job     | Value: $jobstatus"
        else
            echo "Element: $job returned an empty value"
            buildstatus="${buildstatus}${job}=\"Unavailable\","
        fi
    done

    # Remove trailing comma
    buildstatus=${buildstatus::-1}
    echo "Line protocol data: $buildstatus"

    # Write data into DB
    influx write --bucket $INFLUX_BUCKET_NAME "$buildstatus"
}

# Wait for services to be up and running
while ! influx ping; do
    echo "Waiting for InfluxDB to be ready..."
    sleep 1
done
echo "InfluxDB ready!"

# Create bucket with a defined retention period
influx bucket create --name $INFLUX_BUCKET_NAME --retention $INFLUX_BUCKET_RETENTION

while true; do
    # Get data points into database
    insert_into_influxdb

    # Wait POLL_INTERVAL_SEC until the next data acquisition
    sleep $POLL_INTERVAL_SEC
done
