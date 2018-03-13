#!/usr/bin/env bash
source $(cat ../path_to_main.txt)rsyncmark_functions.sh
source $(cat ../path_to_main.txt)global_constants.sh

expected_result=
fail_count=0
test_dir="test_dir"
path_to_script=$(cat ../path_to_main.txt)$CLEAN_SCRIPT
host_password=

if [ "$1" != "" ]; then
	host_password=$1
else
	get_host_password
	host_password=$(print_password)
fi

SUCCESS_STATEMENT="[*] SUCCESS: [test_clean] all test cases have passed"

function fail_statement
{
	echo "[!] FAIL: [test_clean]"
}

function verify_clean
{
	if [ -d $test_dir ]; then
		fail_statement
		fail_count=$[$fail_count+1]
	fi
}

function set_up
{
	mkdir $test_dir
	echo "test1" > $test_dir/test_file1.txt
	echo "test2" > $test_dir/test_file2.txt
	echo "test3" > $test_dir/test_file3.txt
	echo "test4" > $test_dir/test_file4.txt
}

##### TEST CASE #####
set_up
pwd=$(pwd)
file_to_delete=$pwd/$test_dir
ip=$(curl ipecho.net/plain ; echo)
clean $path_to_script $ip $host_password $file_to_delete
verify_clean

##### determine if we passed all tests #####
if [ $fail_count == 0 ]; then
	echo $SUCCESS_STATEMENT
fi
