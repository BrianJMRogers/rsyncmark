#!/usr/bin/env bash

# $1 is host ip
# $2 is host password
# $3 is directory to delete
host=$1
host_password=$2
dir_to_delete=$3

# check that the args file exists and throw and error if it does not
if [ ! -f ssh_args.sh ]; then
	echo [!] move_files: unable to find ssh args file [ssh_args.sh]

# else run the command
else
	# pull args from file
	ssh_args=$(./ssh_args.sh)

	# use expect from here until EOF
	/usr/bin/env expect<<EOF
	spawn ssh $ssh_args $host
	expect {
    "Are you sure you want to continue connecting (yes/no)"
    {
      send "yes\r"
      exp_continue
    }
    "*:"
    {
      send "$host_password\r"
      exp_continue
    }
    "# "
    {
      send "rm -rf $dir_to_delete\r"
      send "exit\r"
    }
		"$ "
    {
      send "rm -rf $dir_to_delete\r"
      send "exit\r"
    }

	}
	expect eof
EOF
fi
