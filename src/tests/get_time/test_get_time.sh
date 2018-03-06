#!/usr/bin/env bash
source $(cat ../path_to_main.txt)rsyncmark_functions.sh

expected_result=
fail_count=0
time_file_name="time.txt"

SUCCESS_STATEMENT="[*] SUCCESS: [test_get_time] all test cases have passed"

function fail_statement
{
	echo "[!] FAIL: [test_get_time] with test case: [$1] != [$2]"
}

function verify_time
{
	if [ "$1" == "ERROR" ] || [ "$1" != "$expected_result" ]; then
		fail_statement $1 $2
		fail_count=$[$fail_count+1]
	fi
}

##### TEST CASE #####
testcase="real"
expected_result="0.38"
verify_time $(get_time $testcase $time_file_name) $expected_result

##### TEST CASE #####
testcase="user"
expected_result="0.03"
verify_time $(get_time $testcase $time_file_name) $expected_result

##### TEST CASE #####
testcase="sys"
expected_result="0.04"
verify_time $(get_time $testcase $time_file_name) $expected_result


##### determine if we passed all tests #####
if [ $fail_count == 0 ]; then
	echo $SUCCESS_STATEMENT
fi
