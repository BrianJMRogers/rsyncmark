source $(cat ../path_to_main.txt)rsyncmark_functions.sh
source $(cat ../path_to_main.txt)global_constants.sh

expected_result=
fail_count=0
test_dir="test_dir"
destination_dir="destination"
path_to_script=$(cat ../path_to_main.txt)$SYNC_FILE_SCRIPT

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

##### TEST CASE #####
get_host_password
current_directory=$(pwd)
destination_dir="$current_directory/$destination_dir"
host_password=$(print_password)
host=$(curl ipecho.net/plain ; echo)
stage_files $test_dir $host $destination_dir $host_password $path_to_script
verify_stage_files
rm -rf $destination_dir

##### determine if we passed all tests #####
if [ $fail_count == 0 ]; then
	echo $SUCCESS_STATEMENT
fi
