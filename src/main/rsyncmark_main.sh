source ./rsyncmark.sh
##########################################################################################
# MAIN
##########################################################################################
#verify_files_to_transfer

parse_args

verify_args

#verify_overwrite_is_okay

#print_args # uncomment when needed

get_host_password

stage_files

#warm_up large
#run large
#warm_up medium
#run medium
#warm_up small

run_trials

# clean up files locally and in client
#clean

# remind the user where their ouput is
# echo "[*] You can find this trial's statistics in the output file $output_name"

exit

