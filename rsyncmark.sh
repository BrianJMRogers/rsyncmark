##########################################################################################
# PROGRAM STRUCTURE
##########################################################################################

# parse args
    # get trial name
    # determine file structure
        # if given a file, use that
            # cp it to a new directory called testdir
        # else create a file dir and use that
    # determine which output file to use
        # if none is specified, default to PROGNAME_OUTPUT
# read password
# run trials
    # test x starting...
    # delete testdir on client end using rsync
    # sync testdir
    # parse output and place in file
    # ...test x finished.
# alert user when entire thing has been completed

##########################################################################################
# argument declarations
##########################################################################################

NAMEARG="-n" # the name of this trial run. Will be listed as this in the output file
FILEARG="-f" # the name of the file that this run will sync
OUTPUTARG="-o" # the name of the file to which output will be written (will create if it doesn't exist)
HOSTARG="-h" # the IP address of the client with which we'll rsync


##########################################################################################
# Alert message declarations
##########################################################################################
USAGE="[!] USAGE: -n [name for this trial] -f [path to file you'd like to sync] -o [output file name (this will write to existing files of that name)] -h [IP of computer with which you'd like to sync]"
FILEERROR="[!] FILE ERROR: the file specified by $FILEARG cannot be found"
OUTPUTFILEERROR="[*] Output file specified by $OUTPUTARG cannot be found...generating file.."

##########################################################################################
# variable declarations
##########################################################################################
# argument variables. To add more, you'll need to add them to the parse_args, verify_args, and (optionally) print_args
trial_name=
file_name=
output_name=
host=

# misc variables
declare -i arg_iterator=$#
declare -i num_args=$#

##########################################################################################
# function declarations
##########################################################################################

# this will parse args (backwards) and save them to each variable
function parse_args
{
    for i in ${BASH_ARGV[*]}; do
        one=1
        if [ $i == $NAMEARG ]; then
            #echo "name:  ${BASH_ARGV[$num_args-1-$arg_iterator]}"
            trial_name=${BASH_ARGV[$num_args-1-$arg_iterator]}
        elif [ $i == $FILEARG ]; then
            #echo "file:  ${BASH_ARGV[5-$arg_iterator]}"
            file_name=${BASH_ARGV[$num_args-1-$arg_iterator]}
        elif [ $i == $OUTPUTARG ]; then
            #echo "output file:  ${BASH_ARGV[5-$arg_iterator]}"
            output_name=${BASH_ARGV[$num_args-1-$arg_iterator]}
        elif [ $i == $HOSTARG ]; then
            host=${BASH_ARGV[$num_args-1-$arg_iterator]}
        fi
        arg_iterator=$arg_iterator-$one
    done

    # verify arguments were passes sucessfully
    if [ -z $trial_name ] || [ -z $file_name ] || [ -z $output_name ] || [ -z $host ]; then
        echo $USAGE
        exit
    fi
}

# this function verifies
    # file_name which the user wants to sync actually exists (if it doesn't, exit)
    # output file exists (if it doesn't, make one)
function verify_args
{
    if [ ! -f $file_name ]; then
        echo $FILEERROR
        exit
    elif [ ! -f $output_file ]; then
        echo $OUTPUTFILEERROR
    fi
}

#this function prints each argument for debugging purposes
function print_args
{
    arg_array=($trial_name $file_name $output_name $host)
    echo "args: "
    for i in ${arg_array[@]}; do
        echo "\t$i"
    done
}


##########################################################################################
# MAIN
##########################################################################################

# parse command line for arguments and verify that each is non empty
parse_args

# ensure that files which arguments point to exist
verify_args

# print args to verify
print_args

exit




