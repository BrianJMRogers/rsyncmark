##########################################################################################
# gloabal constants
##########################################################################################
PROG_NAME="rsyncmark"
SYNC_FILE_SCRIPT="sync_file.sh"
SSH_MOVE_FILES_SCRIPT="move_files.sh"
CLEAN_SCRIPT="remove_files.sh"
REMOTE_DIR_BASE="rsyncmark"  # this is the path on target MACHINE where STAGING/TARGET dirs exist
REMOTE_DIR_BASE_LOCATION="~/"
STAGING_DIR_NAME="staging"
TARGET_DIR_NAME="target"
PATH_TO_RSYNCMARK_FILE_DIR="../../files/rsyncmark" # this is the path to these files locally
PATH_TO_NEW_FILES="../../files/new"
LARGE_FILE_NAME="large"
MEDIUM_FILE_NAME="medium"
SMALL_FILE_NAME="small"
TIME_FILE_NAME="time.txt"
DUMP_FILE_NAME="dump.txt"
RSYNC_OUTPUT_DUMP_FILE="rsync_output.txt" #this is used to capture the output of each timed rsync run
OUTPUT_HEADER="trial_name,real_time_seconds,user_time_seconds,sys_time_seconds,throughput_bytes_per_second,file_size_name,file_size_bytes,delta_size_bytes,speedup,trial_num"
