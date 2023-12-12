#!/bin/bash
for ii in $(ps aux | grep qemu | grep testvm | awk '{print $2}') ; do kill $ii ; done
