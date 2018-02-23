source ./rsyncmark_functions.sh

##########################################################################################
# gloabal constants
##########################################################################################
PROG_NAME="rsyncmark"
SYNC_FILE_SCRIPT="sync_file.sh"
SSH_MOVE_FILES_SCRIPT="move_files.sh"
REMOTE_DIR_BASE="rsyncmark"  # this is the path on target MACHINE where STAGING/TARGET dirs exist
REMOTE_DIR_BASE_LOCATION="~/"
STAGING_DIR_NAME="staging"
TARGET_DIR_NAME="target"
#testing
#PATH_TO_RSYNCMARK_FILE_DIR="../../files_test/rsyncmark" # this is the path to these files locally
#PATH_TO_NEW_FILES="../../files_test/new"
#PATH_TO_OLD_FILES="../../files_test/old"
PATH_TO_RSYNCMARK_FILE_DIR="../../files/rsyncmark" # this is the path to these files locally
PATH_TO_NEW_FILES="../../files/new"
PATH_TO_OLD_FILES="../../files/old"
LARGE_FILE_NAME="large_django"
MEDIUM_FILE_NAME="medium_bootstrap"
SMALL_FILE_NAME="small_homebrew"
TIME_FILE_NAME="time.txt"
DUMP_FILE_NAME="dump.txt"
RSYNC_OUTPUT_DUMP_FILE="rsync_output.txt" #this is used to capture the output of each timed rsync run
OUTPUT_HEADER="trial_name,real_time_seconds,user_time_seconds,sys_time_seconds,throughput_bytes_per_second,file_size_name,file_size_bytes,delta_size_bytes,speedup,trial_num"


##########################################################################################
# variable declarations
##########################################################################################
# argument variables. To add more, you'll need to add them to the parse_args, verify_args, and (optionally) print_args
trial_name=
output_name=
host=
host_password=


##########################################################################################
# FUNCTIONS
##########################################################################################
function call_warm_up
{
	warm_up $PATH_TO_NEW_FILES/$1 $2 $host $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$TARGET_DIR_NAME $host_password $1
}

function call_run_trials
{
 run_trials $PATH_TO_NEW_FILES/$1 $2 $host $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$TARGET_DIR_NAME $host_password $1 $output_name
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

# make sure the user is okay with overwriting files
#verify_overwrite_is_okay

#print_args # uncomment when needed

# call first function to read in the password and second function to pass it back to this file
get_host_password
host_password=$(print_password)

# stage files in remote directory
#stage_files $PATH_TO_RSYNCMARK_FILE_DIR $host $REMOTE_DIR_BASE_LOCATION $host_password

num_warm_ups=10
num_trials=30
call_warm_up $LARGE_FILE_NAME $num_warm_ups
call_run_trials $LARGE_FILE_NAME $num_trials
call_warm_up $MEDIUM_FILE_NAME $num_warm_ups
call_run_trials $MEDIUM_FILE_NAME $num_trials
call_warm_up $SMALL_FILE_NAME $num_warm_ups
call_run_trials $SMALL_FILE_NAME $num_trials

# clean up files locally and in client
#clean

# remind the user where their ouput is
# echo "[*] You can find this trial's statistics in the output file $output_name"

exit

