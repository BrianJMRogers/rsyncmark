#!/usr/bin/env bash
source ./rsyncmark_functions.sh
source ./global_constants.sh

##########################################################################################
# FUNCTIONS
##########################################################################################

#### PURPOSE: run the actual times trials of rsync
#### ARGUMENTS: $1 is the name and path of the file we want to sync
####						$2 is the number times we want to sync it
####						$3 is the host
####						$4 is the path to the target dir
####						$5 is the host password
####						$6 is the name of the file we're transferring
####						$7 is the name of the output file
####						$8 is the name of the file get_time should parse with
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

#### ARGUMENTS: $1 the name of the file we're gunna warm up by sending accross network
####						$2 the number of times we want to run the warm up
function call_warm_up
{
	warm_up $PATH_TO_NEW_FILES/$1 $2 $host $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$TARGET_DIR_NAME $host_password $1
}

#### ARGUMENTS: $1 the name of the file we're gunna warm up by sending accross network
####						$2 the number of times we want to run the warm up
function call_run_trials
{
 	run_trials $PATH_TO_NEW_FILES/$1 $2 $host $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$TARGET_DIR_NAME $host_password $1 $output_name $TIME_FILE_NAME
}

#### ARGUMENTS: NONE
function verify_files_to_transfer
{
	check_file_exists $PATH_TO_RSYNC_FILE_DIR
	file_array=("$PATH_TO_NEW_FILES" "$PATH_TO_NEW_FILES/$EXTRA_LARGE_FILE_NAME" "$PATH_TO_NEW_FILES/$LARGE_FILE_NAME" "$PATH_TO_NEW_FILES/$MEDIUM_FILE_NAME" "$PATH_TO_NEW_FILES/$SMALL_FILE_NAME" "$PATH_TO_NEW_FILES/$TINY_FILE_NAME" "$PATH_TO_RSYNCMARK_FILE_DIR" "$PATH_TO_RSYNCMARK_FILE_DIR/$STAGING_DIR_NAME" "$PATH_TO_RSYNCMARK_FILE_DIR/$STAGING_DIR_NAME/$EXTRA_LARGE_FILE_NAME" "$PATH_TO_RSYNCMARK_FILE_DIR/$STAGING_DIR_NAME/$LARGE_FILE_NAME" "$PATH_TO_RSYNCMARK_FILE_DIR/$STAGING_DIR_NAME/$MEDIUM_FILE_NAME" "$PATH_TO_RSYNCMARK_FILE_DIR/$STAGING_DIR_NAME/$SMALL_FILE_NAME"
	"$PATH_TO_RSYNCMARK_FILE_DIR/$STAGING_DIR_NAME/$TINY_FILE_NAME")
	for i in "${file_array[@]}"
	do
		does_exist=$(check_file_exists $i)
		if [ "$does_exist" != "" ]; then
			echo "[!] rsyncmark_main: unable to find file [$i]...exiting"
			exit
		fi
	done
}


##########################################################################################
# MAIN
##########################################################################################
#verify_files_to_transfer

# parse command line args and save arguments
args=$(parse_args)
trial_name=$(echo $args | awk '{print $1}')
output_name=$(echo $args | awk '{print $2}')
host=$(echo $args | awk '{print $3}')

# make sure arguments were passed for all of them
if [ -z $trial_name ] || [ -z $output_name ] || [ -z $host ]; then
	echo "[!] USAGE: \n\t-n [name for this trial] \n\t-o [output file name (this will write to existing files of that name)] \n\t-h [IP of computer with which you'd like to sync]"
	exit
fi

# check that the output file exists and make one if it doesn't
if [ ! -f $output_name ]; then
	echo "Unable to find an output file called [$output_name]... Generating file..."
  echo $OUTPUT_HEADER > $output_name
fi

# check that all the files are there
verify_files_to_transfer

# make sure the user is okay with overwriting files
verify_overwrite_is_okay $REMOTE_DIR_BASE $REMOTE_DIR_BASE_LOCATION

#print_args # uncomment when needed

# call first function to read in the password and second function to pass it back to this file
get_host_password
host_password=$(print_password)

# stage files in remote directory
stage_files $PATH_TO_RSYNCMARK_FILE_DIR $host $REMOTE_DIR_BASE_LOCATION $host_password $SYNC_FILE_SCRIPT

num_warm_ups=3
num_trials=10

call_warm_up $EXTRA_LARGE_FILE_NAME $num_warm_ups
call_run_trials $EXTRA_LARGE_FILE_NAME $num_trials
call_warm_up $LARGE_FILE_NAME $num_warm_ups
call_run_trials $LARGE_FILE_NAME $num_trials
call_warm_up $MEDIUM_FILE_NAME $num_warm_ups
call_run_trials $MEDIUM_FILE_NAME $num_trials
call_warm_up $SMALL_FILE_NAME $num_warm_ups
call_run_trials $SMALL_FILE_NAME $num_trials
call_warm_up $TINY_FILE_NAME $num_warm_ups
call_run_trials $TINY_FILE_NAME $num_trials

# clean up files locally and in client
clean $CLEAN_SCRIPT $host $host_password $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE

# remind the user where their ouput is
echo "[*] You can find this trial's statistics in the output file $output_name"

exit
