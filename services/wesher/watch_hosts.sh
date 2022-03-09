#!/bin/bash


while inotifywait -e close_write /etc/hosts; do ./hosts_updated.sh; done
