id=$(ps aux | grep qemu | grep testvm-1 | awk '{print $2}') ; kill $id
