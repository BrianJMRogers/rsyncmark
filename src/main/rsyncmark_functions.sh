#!/usr/bin/env bash
##########################################################################################
# PROGRAM STRUCTURE
##########################################################################################
# [DONE] parse args
    # [DONE] get trial name
    # [DONE] get output file name
    # [DONE] get file size arg
# [DONE] verify files_to_transfer exist #do at the end when you know what you need to check
# [DONE] read password
# [DONE] time dummy expect script
# [DONE] stage entire thing (move files over, create target dir)
# [DONE] warm up file_size
# [DONE] run and record file_size
# [DONE] clean files off of remote computer

# other things I need to do
# [DONE] make sure all functions do not use global variables
# [DONE] comment all arguments for functions
# [DONE] comment all return values for functions
# [DONE] provide better output of progress during warm ups and runs
# [DONE] write tests

##########################################################################################
# variables
##########################################################################################
host_password=

##########################################################################################
# function declarations
##########################################################################################

#### PURPOSE: attempts to parse out trial_name, output_name, and host_name from command line
####				  args and then returns them
#### ARGUMENTS: $1 the command line args
#### RETURN VALUE: trial_name output_name host_name
#### WILL TEST: YES
#### TESTS WRITTEN: YES
function parse_args
{
	name_arg="-n" # the name of this trial run. Will be listed as this in the output file
	output_arg="-o" # the name of the file to which output will be written (will create if it doesn't exist)
	host_arg="-h" # the IP address of the client with which we'll rsync
	trial_name=
	output_name=
	host=

	declare -i arg_iterator=$#
	declare -i num_args=$#
  for i in ${BASH_ARGV[*]}; do
    one=1
    if [ $i == $name_arg ]; then
      #echo "name:  ${BASH_ARGV[$num_args-1-$arg_iterator]}"
      trial_name=${BASH_ARGV[$num_args-1-$arg_iterator]}
    elif [ $i == $output_arg ]; then
      #echo "output file:  ${BASH_ARGV[5-$arg_iterator]}"
      output_name=${BASH_ARGV[$num_args-1-$arg_iterator]}
    elif [ $i == $host_arg ]; then
      host=${BASH_ARGV[$num_args-1-$arg_iterator]}
    fi
    arg_iterator=$arg_iterator-$one
  done
	echo "$trial_name $output_name $host"
}

#### PURPOSE: useful for debugging, prints all arguments passed in via command line
function print_args
{
    arg_array=($trial_name $output_name $host)
    echo "[*] args: "
    for i in ${arg_array[@]}; do
        echo "\t$i"
    done
}

#### PURPOSE: to ensure the user knows we'll overwrite files named $TEST_FILE_NAME
#### ARGUMENTS: $1 name of the directory we want to warn for deletion
####					  $2 the location of this directory
#### RETURN VALUE: YES
#### INCLUDES GLOBALS: NO
#### WILL TEST: NO
function verify_overwrite_is_okay
{
    echo "[*] this benchmark will create and delete the directory named [$1] in directory [$2] on the remote machine. Are you sure you want to proceed? (yes/no)"
    read verification
    if [ "$verification" != "yes" ]; then
        echo "you must answer \"yes\" in order to continue"
        exit
    fi
}

#### PURPOSE: removes the $TEST_FILE_NAME file/directory locally and remotely
#### ARGUMENTS: $1 clean script name
####					  $2 host ip
####						$3 host password
####						$4 directory to delete
#### RETURN VALUE: NONE
#### INCLUDES GLOBALS: NO
#### WILL TEST: YES
#### TESTS WRITTEN: YES
function clean
{
		./$1 $2 $3 $4
}

#### PURPOSE: retreive the password of the server
#### ARGUMENTS: NONE
#### RETURN VALUE: NONE
#### INCLUDES GLOBALS: host_password
#### WILL TEST: NO
function get_host_password
{
    printf "Enter the password for the destination machine: "
    read -s host_password
    printf "\n"
}
# used to pass the password back to main
function print_password
{
	echo $host_password
}

#### PURPOSE: check that the files we hope to transfer are here locally
#### ARGUMENTS: path to the directory you want to check for
#### RETURN VALUE: none if the file is found, otherwise an error message
#### WILL TEST: YES
#### TESTS WRITTEN: YES
function check_file_exists
{
	if [ ! -d $1 ]; then
  	echo "[!] rsyncmark_functions -> verify_files_to_transfer: file not found [$1]"
  fi
}

#### PURPOSE: used at the beginning of the benchmark, this function moves the base
####          directory over to the remote machine
#### ARGUMENTS: $1 path to directory we want on the host machine
####					  $2 host
#### 						$3 remote directory
#### 						$4 host_password
#### 						$5 name of sync file script
#### RETURN VALUE: NONE
#### WILL TEST: YES
#### TEST WRITTEN: YES
function stage_files
{
    echo "staging files"
    # move staging dir over
    ./$5 $1 $2 $3 $4
}

#### PURPOSE: This function is used at the beginning of each sync. It moves the "old" files from
####          the staging dir on the remote location to the target dir so that the files in the
####          target are reverted back to their old stage
#### ARGUMENTS: $1 ssh and move files script name
####						$2 host ip
####						$3 host password
####						$4 path to copy from
####						$5 path to copy to
#### RETURN VALUE: NONE
#### INCLUDES GLOBALS: $host $host_password
#### WILL TEST: YES
#### TEST WRITTEN: YES
function move_files_from_staging_to_target
{
  echo "moving files from staging to target"
	./$1 $2 $3 $4 $5
}

#### PURPOSE: This function runs rsync using one of the file sets but does not record time
#### ARGUMENTS: $1 is the name and path of the file we want to warm up
####						$2 is the number of warm ups we want to run
####						$3 is the host
####						$4 is the path to the target dir
####						$5 is the host password
####						$6 is the name of the file we're transferring
#### RETURN VALUE: NONE
#### INCLUDES GLOBALS: $host $host_password
#### WILL TEST: NO
function warm_up
{
	  i=0
		num_warm_ups=$2
		while [ "$i" != "$num_warm_ups" ]; do
			# increment
			i=$[i+1]

			echo "warming up [$6]. Warm up [$i] of [$num_warm_ups]"
			# reset files
    	move_files_from_staging_to_target $SSH_MOVE_FILES_SCRIPT $host $host_password $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$STAGING_DIR_NAME $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$TARGET_DIR_NAME

      # sync large files
      ./$SYNC_FILE_SCRIPT $1 $3 $4 $5

		done
}

#### PURPOSE: run the actual times trials of rsync
#### ARGUMENTS: $1 is the name and path of the file we want to sync
####						$2 is the number times we want to sync it
####						$3 is the host
####						$4 is the path to the target dir
####						$5 is the host password
####						$6 is the name of the file we're transferring
####						$7 is the name of the output file
####						$8 is the name of the file get_time should parse with
#### RETURN VALUE: NONE
#### INCLUDES GLOBALS: NO
#### WILL TEST: NO
function run_trials
{
	i=0
	num_trials=$2
	while [ "$i" != "$num_trials" ]; do
		# increment
		i=$[i+1]

		echo "running trial for [$6]. trial [$i] of [$num_trials]"

		sync_file_record_output $1 $i $3 $4 $5 $6 $7 $8

	done
}

#### PURPOSE: sync each file and record the output
#### ARGUMENTS: $1 is the name and path of the file we want to warm up
####						$2 is the current warm up number we're on
####						$3 is the host
####						$4 is the path to the target dir
####						$5 is the host password
####						$6 is the name of the file we're transferring
####						$7 is the name of the output file
####						$8 is the name of the file get_time should parse with
#### RETURN VALUE: NONE
#### INCLUDES GLOBALS: $host $host_password $output_name $trial_name
#### WILL TEST: NO
function sync_file_record_output
{
    file=$1
		output_name=$7
		get_time_file=$8

    # reset files
    move_files_from_staging_to_target $SSH_MOVE_FILES_SCRIPT $host $host_password $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$STAGING_DIR_NAME $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$TARGET_DIR_NAME

		# sync large files
    { time -p $(./$SYNC_FILE_SCRIPT $1 $3 $4 $5>$RSYNC_OUTPUT_DUMP_FILE 2>&1) 1>dump.txt ; } 2>time.txt

    # record times
		real_time=$(get_time real $get_time_file)
		user_time=$(get_time user $get_time_file)
		sys_time=$(get_time sys $get_time_file)

    # grep througput out of $RSYNC_OUTPUT_FILE
    delta=$(cat $RSYNC_OUTPUT_DUMP_FILE | grep sent | grep received | grep "bytes/sec" | awk '{print $2}')
    throughput=$(cat $RSYNC_OUTPUT_DUMP_FILE | grep sent | grep received | grep "bytes/sec" | awk '{print $7}')
    trial_num=$2
    size_name=$6
    size_bytes=$(cat $RSYNC_OUTPUT_DUMP_FILE | grep total | grep size | grep is | awk '{print $4}')
    #speedup=$(cat $RSYNC_OUTPUT_DUMP_FILE | grep total | grep speedup | grep is | awk '{print $7}')

		# parse the speedup from the rsync output... it will have a ^M char at the end
    speedup=$(sed 's/^M//g' $RSYNC_OUTPUT_DUMP_FILE | grep total | grep speedup | grep is | awk '{print $7}')

		# call this funciton so parse out the ^M. $speedup will be correctly assigned inside this function
		speedup=$(parse_speedup $speedup)

		# create line variable
    line="$trial_name, $real_time, $user_time, $sys_time, $throughput, $size_name, $size_bytes, $delta, $speedup, $trial_num"

		# add line variable to the end of output
    echo $line >> $output_name

    # remove time and dump files
    rm $TIME_FILE_NAME
    rm $DUMP_FILE_NAME
		rm $RSYNC_OUTPUT_DUMP_FILE
}

#### PURPOSE: when you parse out the speedup from rsync's output, it comes with a ^M char
####									 at the end which is a pain to parse out so we do this
#### ARGUMENTS: a single string which should be formatted xxxx.xx where each x is a number
#### RETURN VALUE: the string xxxx.xx without any trailing characters
#### INCLUDES GLOBALS: NO
#### WILL TEST: YES
#### TEST WRITTEN: YES
function parse_speedup
{
	# declare variables
	speedup=$1
	char="x"
	char_location=0

	# the while loop will find where in $speedup the period is. $char_location will end up being
	# one char beyond the period after this loop
	while [ "$char" != "." ]; do
		char=$(echo ${speedup:$char_location:1})

		char_location=$[$char_location+1]

		# if for some reason we keep parsing and don't come across the period, break out of the loop
		# and assign variables as such so we know we failed
		if [ $char_location -gt 20 ]; then
			char_location=-1
			char="."
		fi
	done

	# if we couldn't find it, error
	if [ $char_location == -1 ]; then
		speedup="ERROR"
	else
		# since after identifying location, we increment twice to get the two digits after the decimal
		char_location=$[$char_location+2]

		# use awk to parse out the substring we want
		speedup=$(echo $speedup $char_location | awk '{print substr($1,0,$2)}')
	fi
	echo $speedup
}

#### FUNCTION PURPOSE:
#### PURPOSE: retreive the time from the file $TIME_FILE_NAME specified by $1 (real, user, sys)
#### ARGUMENTS: $1 the word referring to what we're grepping for (user, real, sys)
####						$2 the name of the file to parse from
#### RETURN VALUE: the numerical time found in $TEST_FILE_NAME referring to $1
#### INCLUDES GLOBALS: NO
#### WILL TEST: YES
#### TEST WRITTEN: YES
function get_time
{
    time=$(cat $2 | grep $1 | awk '{print $2}')
		echo $time
}

#### PURPOSE:
#### ARGUMENTS:
#### RETURN VALUE:
#### INCLUDES GLOBALS:
