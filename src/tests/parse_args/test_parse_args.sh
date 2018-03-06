#!/usr/bin/env bash
source $(cat ../path_to_main.txt)rsyncmark_functions.sh

expected_result=
fail_count=0
name="name"
host="host"
output="output"


SUCCESS_STATEMENT="[*] SUCCESS: [test_parse_args] all test cases have passed"

function fail_statement
{
	echo "[!] FAIL: [test_parse_args] with test case: [$name] != [$1] OR [$output] != [$2] OR [$host] != [$3]"
}

function verify_args
{
	if [ "$1" != "$name" ] || [ "$2" != "$output"  ]|| [ "$3" != "$host" ]; then
		fail_statement $1 $2 $3
		fail_count=$[$fail_count+1]
	fi
}

##### TEST CASE NOH #####
verify_args $(./call_parse_args.sh -n $name -o $output -h $host)

##### TEST CASE NHO #####
verify_args $(./call_parse_args.sh -n $name -h $host -o $output)

##### TEST CASE OHN #####
verify_args $(./call_parse_args.sh -o $output -h $host -n $name)

##### TEST CASE ONH #####
verify_args $(./call_parse_args.sh -o $output -n $name -h $host)

##### TEST CASE HON #####
verify_args $(./call_parse_args.sh -h $host -o $output -n $name)

##### TEST CASE HNO #####
verify_args $(./call_parse_args.sh -h $host -n $name -o $output)

##### determine if we passed all tests #####
if [ $fail_count == 0 ]; then
	echo $SUCCESS_STATEMENT
fi
