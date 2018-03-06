#!/usr/bin/env bash

source ../main/rsyncmark_functions.sh
get_host_password
host_pass=$(print_password)

cd ./parse_speedup/
./test_parse_speedup.sh

cd ../get_time
./test_get_time.sh

cd ../parse_args
./test_parse_args.sh

cd ../check_file_exists
./test_check_file_exists.sh

cd ../clean
./test_clean.sh $host_pass

cd ../stage_files
./test_stage_files.sh $host_pass

cd ../move_files_from_staging_to_target
./test_move_files_from_staging_to_target.sh $host_pass
