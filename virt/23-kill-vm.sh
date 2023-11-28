#!/bin/bash
id=$(ps aux | grep qemu | grep testvm-1 | awk '{print $2}') ; kill $id
id=$(ps aux | grep qemu | grep testvmw-1 | awk '{print $2}') ; kill $id
