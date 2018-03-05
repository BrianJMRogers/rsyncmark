#!/usr/bin/expect

# $1 is host ip
# $2 is host password
# $3 is directory to delete

set host [lindex $argv 0]
set host_password [lindex $argv 1]
set dir_to_delete [lindex $argv 2]

spawn ssh $host
expect {
    "Are you sure you want to continue connecting (yes/no)"
    {
        send "yes\r"
        exp_continue
    }
    "*assword:"
    {
        send "$host_password\r"
        exp_continue
    }
    "$ "
    {
        send "rm -rf $dir_to_delete\r"
        send "exit\r"
    }
}
expect eof
