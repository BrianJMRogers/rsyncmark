#!/usr/bin/env bash
source rsyncmark.conf

### args
# $1 is host ip
# $2 is host password
# $3 is directory from which to wanna move the files
# $4 is directory to which you wanna move the files

host=$1
host_password=$2
staging_dir=$3
target_dir=$4

# use expect from here until EOF
/usr/bin/env expect<<EOF

spawn ssh $ssh_args $host
expect {
	"*(yes/no)"
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
    send "rsync -a --delete $staging_dir/ $target_dir\r"
    send "exit\r"
  }
}
expect eof
EOF

