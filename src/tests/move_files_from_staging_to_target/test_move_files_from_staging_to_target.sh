#!/usr/bin/env bash
source $(cat ../path_to_main.txt)rsyncmark_functions.sh
source $(cat ../path_to_main.txt)global_constants.sh

expected_result=
fail_count=0
test_dir="test_dir"
destination_dir="destination"
staging="staging"
target="target"
path_to_script=$(cat ../path_to_main.txt)$SSH_MOVE_FILES_SCRIPT

SUCCESS_STATEMENT="[*] SUCCESS: [test_move_files_from_staging_to_target] all test cases have passed"

function fail_statement
{
	echo "[!] FAIL: [test_move_files_from_staging_to_target]"
}

function verify_move_files
{
	addition=$(cat $target/file1.txt | grep "addition")
	if [ "$addition" != "" ] || [ -f $target/file5.txt ]; then
		fail_statement
		fail_count=$[$fail_count+1]
	fi
}

function set_up
{
	# create dirs
	mkdir $staging
	mkdir $target

	# generate staging files
	cd $staging
	echo yao1 > file1.txt
	echo yao2 > file2.txt
	echo yao3 > file3.txt
	echo yao4 > file4.txt

	# copy files from staging to target
	cp ./* ../$target
	cd ../$target

	# make additions to target files
	echo this is an addition >> file1.txt
	echo yao5 > file5.txt

	cd ..
}

function clean_up
{
	rm -rf $target
	rm -rf $staging
}

##### TEST CASE #####
set_up
get_host_password
path_to_staging=$(pwd)/$staging
path_to_target=$(pwd)/$target
host_password=$(print_password)
host=$(curl ipecho.net/plain ; echo)
move_files_from_staging_to_target $path_to_script $host $host_password $path_to_staging $path_to_target
verify_move_files
clean_up

##### determine if we passed all tests #####
if [ $fail_count == 0 ]; then
	echo $SUCCESS_STATEMENT
fi
