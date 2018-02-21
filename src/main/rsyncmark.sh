##########################################################################################
# PROGRAM STRUCTURE
##########################################################################################
# [DONE] parse args
    # [DONE] get trial name
    # [DONE] get output file name
    # [DONE] get file size arg
# [TODO] verify files_to_transfer exist #do at the end when you know what you need to check
# [DONE] read password
# [DONE] time dummy expect script
# [DONE] stage entire thing (move files over, create target dir)
# [TODO] warm up file_size
# [TODO] run and record file_size
# [TODO] clean files off of remote computer

# other things I need to do
# [TODO] make sure all functions do not use global variables
# [TODO] comment all arguments for functions
# [TODO] comment all return values for functions
# [TODO] provide better output of progress during warm ups and runs
# [TODO] write tests

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
RSYNC_OUTPUT_DUMP_FILE="rsync_output.txt" #this is used to capture the output of each timed rsync run
OUTPUT_HEADER="trial_name,real_time_seconds,user_time_seconds,sys_time_seconds,throughput_bytes_per_second,file_size_name,file_size_bytes,delta_size_bytes,speedup,trial_num"

# argument declarations
NAMEARG="-n" # the name of this trial run. Will be listed as this in the output file
OUTPUTARG="-o" # the name of the file to which output will be written (will create if it doesn't exist)
HOSTARG="-h" # the IP address of the client with which we'll rsync

##########################################################################################
# variable declarations
##########################################################################################
# argument variables. To add more, you'll need to add them to the parse_args, verify_args, and (optionally) print_args
trial_name=
file_size=
output_name=
host=
host_password=
file_to_send=
time= # used to capture time from time.txt
real_time=
user_time=
sys_time=
size=
delta=
throughput=
trial_num=

# misc variables
declare -i arg_iterator=$#
declare -i num_args=$#
verification=

##########################################################################################
# Alert message declarations
##########################################################################################
USAGE="[!] USAGE: \n\t-n [name for this trial] \n\t-o [output file name (this will write to existing files of that name)] \n\t-h [IP of computer with which you'd like to sync]"
OUTPUTFILEERROR="[*] Output file specified by $OUTPUTARG cannot be found...generating file.."

##########################################################################################
# function declarations
##########################################################################################

#### PURPOSE: attempts to assign all command line args to their variables then
####          checks to make sure each argument was passed in and is non-empty
#### ARGUMENTS: TODO
#### RETURN VALUE: TODO
#### INCLUDES GLOBALS: TODO

function parse_args
{
    for i in ${BASH_ARGV[*]}; do
        one=1
        if [ $i == $NAMEARG ]; then
            #echo "name:  ${BASH_ARGV[$num_args-1-$arg_iterator]}"
            trial_name=${BASH_ARGV[$num_args-1-$arg_iterator]}
        elif [ $i == $OUTPUTARG ]; then
            #echo "output file:  ${BASH_ARGV[5-$arg_iterator]}"
            output_name=${BASH_ARGV[$num_args-1-$arg_iterator]}
        elif [ $i == $HOSTARG ]; then
            host=${BASH_ARGV[$num_args-1-$arg_iterator]}
        fi
        arg_iterator=$arg_iterator-$one
    done

    # verify arguments were passes sucessfully
    if [ -z $trial_name ] || [ -z $output_name ] || [ -z $host ]; then
        echo $USAGE
        exit
    fi
}

#### PURPOSE: verifies that the file passed in with the $FILESIZEARG parameter
#    exists and checks that the output file does too, creating this if necessary
#### ARGUMENTS: TODO
#### RETURN VALUE: TODO
#### INCLUDES GLOBALS: TODO

function verify_args
{
    # check that the file exists
    if [ ! -f $output_name ]; then
        echo "Unable to find an output file called [$output_name]... Generating file..."
        echo $OUTPUT_HEADER > $output_name
    fi
}

#### PURPOSE: useful for debugging, prints all arguments passed in via command line
#### ARGUMENTS: TODO
#### RETURN VALUE: TODO
#### INCLUDES GLOBALS: TODO
function print_args
{
    arg_array=($trial_name $output_name $host)
    echo "[*] args: "
    for i in ${arg_array[@]}; do
        echo "\t$i"
    done
}

#### PURPOSE: to ensure the user knows we'll overwrite files named $TEST_FILE_NAME
#### ARGUMENTS: TODO
#### RETURN VALUE: TODO
#### INCLUDES GLOBALS: TODO
function verify_overwrite_is_okay
{
    echo "[*] this benchmark will overwrite files and the contents of directories named $REMOTE_DIR_BASE in directory $REMOTE_DIR_BASE_LOCATION. Are you sure you want to proceed? (yes/no)"
    read verification
    if [ "$verification" != "yes" ]; then
        echo "you must answer \"yes\" in order to continue"
        exit
    fi
}

#### PURPOSE: removes the $TEST_FILE_NAME file/directory locally and remotely
#### ARGUMENTS: TODO
#### RETURN VALUE: TODO
#### INCLUDES GLOBALS: TODO
function clean
{
    echo "[!] TODO: write clean function"
}

#### PURPOSE: retreive the password of the server
#### ARGUMENTS: TODO
#### RETURN VALUE: TODO
#### INCLUDES GLOBALS: TODO
function get_host_password
{
    printf "Enter the password for the remote client: "
    read -s host_password
    printf "\n"
}

#### PURPOSE: check that the files we hope to transfer are here locally
#### ARGUMENTS: TODO
#### RETURN VALUE: TODO
#### INCLUDES GLOBALS: TODO
function verify_files_to_transfer
{
    # declare array to iterate through
    files_array=( $LARGE_FILE_NAME $MEDIUM_FILE_NAME $SMALL_FILE_NAME )
    for i in ${files_array[@]}; do
        # check if each file is in the new directory
        if [ ! -d $PATH_TO_NEW_FILES/$i ]; then
            echo " $PATH_TO_NEW_FILES/$i not found"
        fi

        # check if each file is in the old directory
        if [ ! -d $PATH_TO_OLD_FILES/$i ]; then
            echo " $PATH_TO_OLD_FILES/$i not found"
        fi
    done
}

#### PURPOSE: will use rsync to sync file $1 to the host $2 at host destination $3 using password $4
#### ARGUMENTS: TODO
#### RETURN VALUE: TODO
#### INCLUDES GLOBALS: TODO
function sync_file
{
    echo "syncing file"
    ./$SYNC_FILE_SCRIPT $1 $host $2 $host_password
}

#### PURPOSE: used at the beginning of the benchmark, this function moves the base
####          directory over to the remote machine
#### ARGUMENTS: TODO
#### RETURN VALUE: TODO
#### INCLUDES GLOBALS: TODO
function stage_files
{
    echo "staging files"
    # move staging dir over
    sync_file $PATH_TO_RSYNCMARK_FILE_DIR $REMOTE_DIR_BASE_LOCATION
}

#### PURPOSE: This function is used at the beginning of each sync. It moves the "old" files from
####          the staging dir on the remote location to the target dir so that the files in the
####          target are reverted back to their old stage
#### ARGUMENTS: TODO
#### RETURN VALUE: TODO
#### INCLUDES GLOBALS: TODO
function move_files_from_staging_to_target
{
    echo "moving files from staging to target"
    ./$SSH_MOVE_FILES_SCRIPT $host $host_password $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$STAGING_DIR_NAME $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$TARGET_DIR_NAME
}

#### PURPOSE: This function runs each rsync of large, medium, and small files 10 times to warm up the benchmark
#### ARGUMENTS: TODO
#### RETURN VALUE: TODO
#### INCLUDES GLOBALS: TODO
#### FUNCTION PURPOSE: TODO
#### TODO rewrite to take an argument of which thing to warm up
function warm_up
{
    echo "warming up..."
    #repeat x number of times:
    for i in {1..10}; do
        # reset files
        move_files_from_staging_to_target

        # sync large files
        ./$SYNC_FILE_SCRIPT $PATH_TO_NEW_FILES/$LARGE_FILE_NAME $host $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$TARGET_DIR_NAME $host_password

        # sync medium files
        ./$SYNC_FILE_SCRIPT $PATH_TO_NEW_FILES/$MEDIUM_FILE_NAME $host $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$TARGET_DIR_NAME $host_password

        # sync small
        ./$SYNC_FILE_SCRIPT $PATH_TO_NEW_FILES/$SMALL_FILE_NAME $host $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$TARGET_DIR_NAME $host_password

    done
}

#### PURPOSE: run the actual times trials of rsync
#### ARGUMENTS: TODO
#### RETURN VALUE: TODO
#### INCLUDES GLOBALS: TODO
#### TODO rewrite into a seperate function which takes and argument of what to run
function run_trials
{
    # output file layout:
    # trial_name, real_time, user_time, sys_time, throughput, size, delta, trial_num
    #repeat 30 times:
        # move files to target
    # sync large files
    for i in {1..10}; do
        #sync_file_record_output large
				echo
    done

    for i in {1..10}; do
        #sync_file_record_output medium
				echo
    done


    for i in {1..1}; do
        sync_file_record_output small
    done
}

#### PURPOSE: sync each file and record the output
#### ARGUMENTS: $1 should indicate the file size, $2 indicates trial number
#### RETURN VALUE: NONE
#### INCLUDES GLOBALS: TODO
function sync_file_record_output
{
    file=
    if [ $1 == "large" ]; then
        echo "large"
        file=$LARGE_FILE_NAME
    elif [ $1 == "medium" ]; then
        echo "medium"
        file=$MEDIUM_FILE_NAME
    elif [ $1 == "small" ]; then
        echo "small"
        file=$SMALL_FILE_NAME
    fi

    # reset files
    move_files_from_staging_to_target

    yao=

    # sync large files
    { time -p $(./$SYNC_FILE_SCRIPT $PATH_TO_NEW_FILES/$file $host $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$TARGET_DIR_NAME $host_password>$RSYNC_OUTPUT_DUMP_FILE 2>&1) 1>dump.txt ; } 2>time.txt

    # record times
    get_time real
    real_time=$time
    get_time user
    user_time=$time
    get_time sys
    sys_time=$time

    # grep througput out of $RSYNC_OUTPUT_FILE
    delta=$(cat $RSYNC_OUTPUT_DUMP_FILE | grep sent | grep received | grep "bytes/sec" | awk '{print $2}')
    throughput=$(cat $RSYNC_OUTPUT_DUMP_FILE | grep sent | grep received | grep "bytes/sec" | awk '{print $7}')
    trial_num=$2
    size_name=$1
    size_bytes=$(cat $RSYNC_OUTPUT_DUMP_FILE | grep total | grep size | grep is | awk '{print $4}')
    #speedup=$(cat $RSYNC_OUTPUT_DUMP_FILE | grep total | grep speedup | grep is | awk '{print $7}')


		# parse the speedup from the rsync output... it will have a ^M char at the end
    speedup=$(sed 's/^M//g' $RSYNC_OUTPUT_DUMP_FILE | grep total | grep speedup | grep is | awk '{print $7}')

		# call this funciton so parse out the ^M. $speedup will be correctly assigned inside this function
		speedup=$(parse_speedup $speedup)

    line="$trial_name, $real_time, $user_time, $sys_time, $throughput, $size_name, $size_bytes, $delta, $speedup, $i"

    echo $line >> $output_name

    # record time

    # sync medium
    # record time

    # sync small
    # record time

    # remove time and dump files
    rm $TIME_FILE_NAME
    rm dump.txt
    rm $RSYNC_OUTPUT_DUMP_FILE
}

#### PURPOSE: when you parse out the speedup from rsync's output, it comes with a ^M char
####									 at the end which is a pain to parse out so we do this
#### ARGUMENTS: a single string which should be formatted xxxx.xx where each x is a number
#### RETURN VALUE: the string xxxx.xx without any trailing characters
#### INCLUDES GLOBALS: NO
function parse_speedup
{
	speedup=$1
	# need to find where in $speedup the "." is, then parse two chars after that
	char="x"
	char_location=0

	# the while loop will find where in $speedup the period is. $char_location will end up being
	# one char beyond the period after this loop
	while [ "$char" != "." ]; do
		char=$(echo $speedup $char_location $[$char_location-1] | awk '{print substr($1,$2,$3)}')

		char_location=$[$char_location+1]

		# if for some reason we keep parsing and don't come across the period, break out of the loop
		# and assign variables as such so we know we failed
		if [ $char_location -gt 20 ]; then
			echo "[!] unable to find a perion in rsync's speedup number...assigning speedup to be ERROR"
			char_location=-1
			char="."
		fi
	done

	# if we couldn't find it, error
	if [ $char_location == -1 ]; then
		speedup="ERROR"
	else
		# since after identifying location, we incremented, we only need to increment once more
		# in order to be two places to the right of the decimal
		char_location=$[$char_location+1]

		# use awk to parse out the substring we want
		speedup=$(echo $speedup $char_location | awk '{print substr($1,0,$2)}')
	fi
	echo $speedup
}


#### FUNCTION PURPOSE:
#### PURPOSE: retreive the time from the file $TIME_FILE_NAME specified by $1 (real, user, sys)
#### ARGUMENTS: TODO
#### RETURN VALUE: TODO
#### INCLUDES GLOBALS: TODO

function get_time
{
    time=$(cat $TIME_FILE_NAME | grep $1 | awk '{print $2}')
}

#### PURPOSE:
#### ARGUMENTS:
#### RETURN VALUE:
#### INCLUDES GLOBALS:


