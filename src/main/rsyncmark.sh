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
# [TODO] rsync (warm up then run, this is a for loop)
    # [DONE] move files from staging to target
    # [TODO] sync files from local to target
    # [TODO] record output
# [TODO] remove staging files and target files
# [DONE] alert user when entire thing has been completed

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
PATH_TO_RSYNCMARK_FILE_DIR="../../files_test/rsyncmark" # this is the path to these files locally
PATH_TO_NEW_FILES="../../files_test/new"
PATH_TO_OLD_FILES="../../files_test/old"
#PATH_TO_STAGING_DIR="../../files/staging_files" # this is the path to these files locally
#PATH_TO_NEW_FILES="../../files/new"
#PATH_TO_OLD_FILES="../../files/old"
LARGE_FILE_NAME="large_rails"
MEDIUM_FILE_NAME="medium_bootstrap"
SMALL_FILE_NAME="small_homebrew"
TIME_FILE_NAME="time.txt"

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

#### FUNCTION PURPOSE: attempts to assign all command line args to their variables then
####                   checks to make sure each argument was passed in and is non-empty
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

#### FUNCTION PURPOSE: verifies that the file passed in with the $FILESIZEARG parameter #                      exists and checks that the output file does too, creating this if
#                      necessary
function verify_args
{
    # check that the file exists
    if [ ! -f $output_name ]; then
        echo "Unable to find an output file called [$output_name]... Generating file..."
        touch $output_name
    fi
}

#### FUNCTION PURPOSE: useful for debugging, prints all arguments passed in via command line
function print_args
{
    arg_array=($trial_name $output_name $host)
    echo "[*] args: "
    for i in ${arg_array[@]}; do
        echo "\t$i"
    done
}

#### FUNCTION PURPOSE: to ensure the user knows we'll overwrite files named $TEST_FILE_NAME
function verify_overwrite_is_okay
{
    echo "[*] this benchmark will overwrite files and the contents of directories named $TEST_FILE_NAME. Are you sure you want to proceed? (yes/no)"
    read verification
    if [ "$verification" != "yes" ]; then
        echo "you must answer \"yes\" in order to continue"
        exit
    fi
}

#### FUNCTION PUTPOSE: removes the $TEST_FILE_NAME file/directory locally and remotely
function clean
{
    echo "[!] TODO: write clean function"
}

#### FUNCTION PUTPOSE: retreive the password of the server
function get_host_password
{
    printf "Enter the password for the remote client: "
    read -s host_password
    printf "\n"
}

#### FUNCTION PUTPOSE: check that the files we hope to transfer are here locally
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

#### FUNCTION PURPOSE: will use rsync to sync file $1 to the host $2 at host destination $3
####                   using password $4
function sync_file
{
    echo "syncing file"
    ./$SYNC_FILE_SCRIPT $1 $host $2 $host_password
}

#### FUNCTION PURPOSE: used at the beginning of the benchmark, this function moves the base
####                   directory over to the remote machine
function stage_files
{
    echo "staging files"
    # move staging dir over
    sync_file $PATH_TO_RSYNCMARK_FILE_DIR $REMOTE_DIR_BASE_LOCATION
}

#### FUNCTION PURPOSE: This function is used at the beginning of each sync. It moves the "old" files from
####                   the staging dir on the remote location to the target dir so that the files in the
####                   target are reverted back to their old stage
function move_files_from_staging_to_target
{
    echo "moving files from staging to target"
    ./$SSH_MOVE_FILES_SCRIPT $host $host_password $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$STAGING_DIR_NAME $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$TARGET_DIR_NAME
}

function sync_files_to_target
{
    echo
}

function remove_staging_and_target_dirs
{
    echo
}

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

function run_trials
{
    # output file layout:
    # trial_name, real_time, user_time, sys_time, throughput, size, delta, trial_num
    #repeat 30 times:
        # move files to target
    #move_files_from_staging_to_target
    for i in {1..10}; do
        # reset files
        move_files_from_staging_to_target

        # sync large files
        # { time -p plz_work 1>dump.txt ; } 2>time.txt
        { time -p $(./$SYNC_FILE_SCRIPT $PATH_TO_NEW_FILES/$LARGE_FILE_NAME $host $REMOTE_DIR_BASE_LOCATION$REMOTE_DIR_BASE/$TARGET_DIR_NAME $host_password) 1>dump.txt ; } 2>time.txt

        get_time real
        real_time=$time

        get_time user
        user_time=$time

        get_time sys
        sys_time=$time

        throughput=throughput
        delta=delta
        trial_num=$1

        line="$trial_name, $real_time, $user_time, $sys_time, throughput_TODO, size_TODO, delta_TODO, $i"

        echo $line >> $output_name

        # record time

        # sync medium
        # record time

        # sync small
        # record time

        # remove time and dump files
        rm time.txt
        rm dump.txt

    done
}

# $1 should indicate the file size
function sync_time
{
    if [ $1 == "real" ]; then
        echo "real"
    elif [ $1 == "user" ]; then
        echo "user"
    elif [ $1 == "sys" ]; then
        echo "sys"
    fi
}

function get_time
{
    time=$(cat $TIME_FILE_NAME | grep $1 | awk '{print $2}')
}


##########################################################################################
# MAIN
##########################################################################################
#verify_files_to_transfer

parse_args

verify_args

#verify_overwrite_is_okay

print_args # uncomment when needed

get_host_password

stage_files

#warm_up

run_trials

# clean up files locally and in client
#clean

rm dump.txt
rm time.txt

# remind the user where their ouput is
# echo "[*] You can find this trial's statistics in the output file $output_name"

exit


