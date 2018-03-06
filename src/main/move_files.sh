#!/usr/bin/env expect

# $1 is host ip
# $2 is host password
# $3 is directory from which to wanna move the files
# $4 is directory to which you wanna move the files

set host [lindex $argv 0]
set host_password [lindex $argv 1]
set staging_dir [lindex $argv 2]
set target_dir [lindex $argv 3]

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
        send "rsync -a --delete $staging_dir/ $target_dir\r"
        send "exit\r"
    }
}
expect eof
