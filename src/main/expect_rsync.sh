#!/usr/bin/expect
set pass [lindex $argv 0]

spawn rsync -v rsyncmark.sh 141.195.27.246:~/tmp/destination
expect "Password:"
send "$pass\r"

expect eof
