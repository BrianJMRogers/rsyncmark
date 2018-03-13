#!/usr/bin/env bash
source rsyncmark.conf

# $1 is host ip
# $2 is host password
# $3 is directory to delete
host=$1
host_password=$2
dir_to_delete=$3

# use expect from here until EOF
/usr/bin/env expect<<EOF
spawn ssh $ssh_args $host
expect {
  "Are you sure you want to continue connecting (yes/no)"
  {
    send "yes\r"
    exp_continue
  }
  "$destination_password_prompt"
  {
    send "$host_password\r"
    exp_continue
  }
  "$desintation_shell_prompt"
  {
    send "rm -rf $dir_to_delete\r"
    send "exit\r"
  }
}
expect eof
EOF

