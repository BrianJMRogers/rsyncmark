##########################################################################################
# PROGRAM STRUCTURE
##########################################################################################

# [DONE] parse args
    # [DONE] get trial name
    # [DONE] get output file name
    # [DONE] get file size arg
# [TODO] verify files_to_transfer exist
# [DONE] read password
# [TODO] time dummy expect script
# [TODO] run warm up trials
# [TODO] run timed trials
    # [TODO] sync old version (delete not present) to client's target
    # [TODO] sync new version to client target
    # [TODO] parse output and place in file
# [TODO] remove files from destination
# [DONE] alert user when entire thing has been completed

##########################################################################################
# gloabal constants
##########################################################################################
PROG_NAME="rsyncmark"
TARGET_DIR="~/"

##########################################################################################
# argument declarations
##########################################################################################
NAMEARG="-n" # the name of this trial run. Will be listed as this in the output file
FILESIZEARG="-s" # the name of the file that this run will sync
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

# misc variables
declare -i arg_iterator=$#
declare -i num_args=$#
verification=
small_file_name_new="small_new_brew"
medium_file_name_new="medium_new_bootstrap"
large_file_name_new="large_new_rails"
small_file_name_old="small_old_brew"
medium_file_name_old="medium_old_bootstrap"
large_file_name_old="large_old_rails"


##########################################################################################
# Alert message declarations
##########################################################################################
USAGE="[!] USAGE: -n [name for this trial] -s [file size (small, medium, large)] -o [output file name (this will write to existing files of that name)] -h [IP of computer with which you'd like to sync]"
FILESIZEERROR="[!] FILE SIZE ERROR: you must pass in a file size after the \"-s\" parameter of \"small\", \"medium\", or \"large\""
OUTPUTFILEERROR="[*] Output file specified by $OUTPUTARG cannot be found...generating file.."

##########################################################################################
# function declarations
##########################################################################################

#### FUNCTION NAME: parse_args
#### FUNCTION PURPOSE: attempts to assign all command line args to their variables then
####                   checks to make sure each argument was passed in and is non-empty
function parse_args
{
    for i in ${BASH_ARGV[*]}; do
        one=1
        if [ $i == $NAMEARG ]; then
            #echo "name:  ${BASH_ARGV[$num_args-1-$arg_iterator]}"
            trial_name=${BASH_ARGV[$num_args-1-$arg_iterator]}
        elif [ $i == $FILESIZEARG ]; then
            #echo "file:  ${BASH_ARGV[5-$arg_iterator]}"
            file_size=${BASH_ARGV[$num_args-1-$arg_iterator]}
        elif [ $i == $OUTPUTARG ]; then
            #echo "output file:  ${BASH_ARGV[5-$arg_iterator]}"
            output_name=${BASH_ARGV[$num_args-1-$arg_iterator]}
        elif [ $i == $HOSTARG ]; then
            host=${BASH_ARGV[$num_args-1-$arg_iterator]}
        fi
        arg_iterator=$arg_iterator-$one
    done

    # verify arguments were passes sucessfully
    if [ -z $trial_name ] || [ -z $file_size ] || [ -z $output_name ] || [ -z $host ]; then
        echo $USAGE
        exit
    fi
}
#### FUNCTION NAME: verify_args
#### FUNCTION PURPOSE: verifies that the file passed in with the $FILESIZEARG parameter #                      exists and checks that the output file does too, creating this if
#                      necessary
function verify_args
{
    # check that the file exists
    if [ $file_size != "small" ] && [ $file_size != "medium" ] && [ $file_size != "large" ]; then
        echo $FILESIZEERROR
        exit
    fi

    if [ ! -f $output_name ]; then
        echo "Unable to find an output file called [$output_name]... Generating file..."
        touch $output_name
    fi
    exit
}

#### FUNCTION NAME: print_args
#### FUNCTION PURPOSE: useful for debugging, prints all arguments passed in via command line
function print_args
{
    arg_array=($trial_name $file_name $output_name $host)
    echo "[*] args: "
    for i in ${arg_array[@]}; do
        echo "\t$i"
    done
}

#### FUNCTION NAME: verify_overwrite_is_okay
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

#### FUNCTION NAME: clean
#### FUNCTION PUTPOSE: removes the $TEST_FILE_NAME file/directory locally and remotely
function clean
{
    printf "[*] Cleaning up...\n"
    printf "\tRemoving [$TEST_FILE_NAME] from local and client..."
    rm -rf $TEST_FILE_NAME
    printf "done\n"
    echo "\t[!] TODO: CLEAN [$TEST_FILE_NAME] from client"
    printf "    ...done\n"

}

function get_host_password
{
    printf "Enter the password for the remote client: "
    read -s host_password
    printf "\n"
}

function verify_files_to_transfer
{
    files_array($small_old_brew, $small_new_brew, $medium_old_bootstrap, $medium_new_bootstrap, $large_new_rails, $large_old_rails)

    for i in ${files_array[@]}; do
        # check if each file is there
    done


}

function run_rsync
{
    echo "start run_rsyc"
    for i in {1..10}; do
        echo $i

    /usr/bin/expect <<EOF
    spawn rsync -v rsyncmark.sh ../
    expect {
        "Are you sure you want to continue connecting (yes/no)"
        {
            send "yes\r"
            exp_continue

        }
        "*assword:"
        {
            send "password\r"
        }
    }
EOF
done

    echo "end run_rsync"
}


##########################################################################################
# MAIN
##########################################################################################
verify_files_to_transfer

parse_args

verify_args

#verify_overwrite_is_okay

# print_args # uncomment when needed

#get_host_password

#run_rsync

# clean up files locally and in client
#clean

# remind the user where their ouput is
# echo "[*] You can find this trial's statistics in the output file $output_name"

exit


