source $(cat ../path_to_main.txt)rsyncmark_functions.sh

expected_result=
fail_count=0

SUCCESS_STATEMENT="[*] SUCCESS: [test_parse_speedup] all test cases have passed"

function fail_statement
{
	echo "[!] FAIL: [test_parse_speedup] with test case: [$1] != [$2]"
}

function verify_speedup
{
	if [ "$1" == "ERROR" ] || [ "$1" != "$expected_result" ]; then
		fail_statement $1 $2
		fail_count=$[$fail_count+1]
	fi
}

##### TEST CASE #####
testcase="03.123"
expected_result="03.12"
verify_speedup $(parse_speedup $testcase) $expected_result

##### TEST CASE #####
testcase="123dadasdad45.44444444467890"
expected_result="123dadasdad45.44"
verify_speedup $(parse_speedup $testcase) $expected_result

##### TEST CASE #####
testcase="12.34\n"
expected_result="12.34"
verify_speedup $(parse_speedup $testcase) "$expected_result"


##### determine if we passed all tests #####
if [ $fail_count == 0 ]; then
	echo $SUCCESS_STATEMENT
fi
