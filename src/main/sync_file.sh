#!/usr/bin/env bash
source rsyncmark.conf

#### args
# $1 is local file_to_sync
# $2 is host ip
# $3 is host target location
# $4 is password to remote machine
file_to_sync=$1
host=$2
file_target_location=$3
pass=$4

temp_command_script="temp_command_script.sh"

# write command to file since the single quotes inside the varaiables get
# misinterpretted by bash
args=($(echo $rsync_args))
echo rsync ${args[@]} $file_to_sync $host:$file_target_location > $temp_command_script
chmod +x $temp_command_script

# use expect from here until EOF
/usr/bin/env expect<<EOF
spawn ./$temp_command_script
expect {
  "*(yes/no)"
  {
    send "yes\r"
    exp_continue
  }
  "$destination_password_prompt"
  {
    send "$pass\r"
  }
}
expect eof
EOF
rm $temp_command_script

