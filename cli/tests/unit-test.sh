#!/usr/bin/env bash
set -e
test(){
    sudo ./azg.sh if add -n wg0 -p 12345 -t prodigy -s 10.0.0.0/8
    sleep 3
    sudo ./azg.sh if remove -n wg0 -t prodigy
}
test