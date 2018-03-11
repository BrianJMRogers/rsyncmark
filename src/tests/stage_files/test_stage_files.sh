#!/usr/bin/env bash
source $(cat ../path_to_main.txt)rsyncmark_functions.sh
source $(cat ../path_to_main.txt)global_constants.sh

expected_result=
fail_count=0
test_dir="test_dir"
destination_dir="destination"
path_to_script=$(cat ../path_to_main.txt)$SYNC_FILE_SCRIPT
host_password=

if [ "$1" != "" ]; then
	host_password=$1
else
	get_host_password
	host_password=$(print_password)
fi


SUCCESS_STATEMENT="[*] SUCCESS: [test_stage_files] all test cases have passed"

function fail_statement
{
	echo "[!] FAIL: [test_stage_files]"
}

function verify_stage_files
{
	echo checking for directory $destination_dir
	if [ ! -d $destination_dir ]; then
		fail_statement
		fail_count=$[$fail_count+1]
	fi
}

function set_up
{
	mkdir test_dir
	echo yao1 >> test_dir/test1.txt
	echo yao2 >> test_dir/test2.txt
	echo yao3 >> test_dir/test3.txt
	echo yao4 >> test_dir/test4.txt

	cp $(cat ../path_to_main.txt)rsync_args.sh rsync_args.sh
}

function clean_up
{
 rm -rf test_dir
 rm rsync_args.sh
}

set_up

##### TEST CASE #####
current_directory=$(pwd)
destination_dir="$current_directory/$destination_dir"
host=$(curl ipecho.net/plain ; echo)
stage_files $test_dir $host $destination_dir $host_password $path_to_script
verify_stage_files
rm -rf $destination_dir

clean_up

##### determine if we passed all tests #####
if [ $fail_count == 0 ]; then
	echo $SUCCESS_STATEMENT
fi

