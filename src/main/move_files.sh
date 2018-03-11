#!/usr/bin/env bash

### args
# $1 is host ip
# $2 is host password
# $3 is directory from which to wanna move the files
# $4 is directory to which you wanna move the files

host=$1
host_password=$2
staging_dir=$3
target_dir=$4

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
EOF
fi
