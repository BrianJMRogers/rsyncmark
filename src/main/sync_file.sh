#!/usr/bin/env bash

#### args
# $1 is local file_to_sync
# $2 is host ip
# $3 is host target location
# $4 is password to remote machine
file_to_sync=$1
host=$2
file_target_location=$3
pass=$4

# check that the args file exists and throw and error if it does not
if [ ! -f rsync_args.sh ]; then
	echo [!] sync_file: unable to find rsync args file [rsync_args.sh]

# else run the command
else
	# pull args from file
	rsync_args=$(./rsync_args.sh)
	args=($(echo $rsync_args))

	echo ${args[@]}
	exit
	# use expect from here until EOF
	/usr/bin/env expect<<EOF
	spawn $rsync_command
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
EOF
fi
