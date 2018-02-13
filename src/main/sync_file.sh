#!/usr/bin/expect

# $1 is local file_to_sync
# $2 is host ip
# $3 is host target location
set file_to_sync [lindex $argv 0]
set host [lindex $argv 1]
set file_target_location [lindex $argv 2]
set pass [lindex $argv 3]

spawn rsync -vaz --delete $file_to_sync $host:$file_target_location
expect {
    "Are you sure you want to continue connecting (yes/no)"
    {
        send "yes\r"
        exp_continue
    }
    "*assword:"
    {
        send "$pass\r"
    }
}

expect eof
