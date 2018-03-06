#!/usr/bin/env bash
source $(cat ../path_to_main.txt)rsyncmark_functions.sh

expected_result=
fail_count=0

SUCCESS_STATEMENT="[*] SUCCESS: [test_check_file_exists] all test cases have passed"

function fail_statement
{
	echo "[!] FAIL: [test_check_file_exists] with test case: [$1] != [$2]"
}

function verify_check_file_exists
{
	if [ "$1" != "" ]; then
		fail_statement $1 $2
		fail_count=$[$fail_count+1]
	fi
}

##### TEST CASE #####
testcase="../../tests"
expected_result=""
result=$(check_file_exists $testcase)
if [ "$result" != "" ]; then
	fail_statement $result $expected_result
	fail_count=$[$fail_count+1]
fi


##### TEST CASE #####
testcase="../../this_does_not_exist"
result=$(check_file_exists $testcase)
if [ "$result" == "" ]; then
	fail_statement $result "file not found"
	fail_count=$[$fail_count+1]
fi

##### determine if we passed all tests #####
if [ $fail_count == 0 ]; then
	echo $SUCCESS_STATEMENT
fi
