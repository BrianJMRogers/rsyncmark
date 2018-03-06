# USAGE: This function randomly generates file sets (old and new) where the "new"
# 			 version and the "old" version share similarities such that the "new" file
# 			 set fully includes the "old" version but has additions to each file

# constants
file_sizer="../../file_sizer/file_sizer"
is_greater_func="../../is_greater/is_greater"

# functions
#### PURPOSE: to create two sets of files with a diff. The "new" file set will
####					be 2x the size of the diff and the "old" will be size x
#### ARGUMENTS: $1 the name of the file sets youd like to create
####						$2 the size of the larger file set (in MB)
####						$3 the size of the smaller file set (in MB)
#### RETURN VALUE: NONE
function create_file_named
{
	# variables
	file_name=$1
	large_file_size=$2
	small_file_size=$3
	num_files=100
	num_dirs=30
	old_extension="_old"
	int_i=0
	dir_size=
	is_greater_result=
	line_increase_amount=10

	# create and move into files directory
	mkdir "files2"
	cd "files2"

	echo creating file named [$file_name] with large size [$large_file_size] and small size [$small_file_size]

	# create dirs
	mkdir $file_name
	mkdir $file_name$old_extension

	# move into new dir
	cd $file_name

	# create file set
	files $num_files $num

	# this loop should go until the small_file_size threshold has been met
	echo generating smaller version of $file_name
	while [ $int_i -lt 1 ];
	do
		files -"$line_increase_amount"c
		cd ../
		dir_size=$($file_sizer $file_name)
		dir_size=$(echo $dir_size | awk '{print $4}')
		is_greater_result=$($is_greater_func $dir_size $small_file_size)
		if [ "$is_greater_result" == "true" ]; then
			int_i=$[int_i+1]
		else
			cd $file_name
		fi
	done

	cp -a $file_name/ $file_name$old_extension

	echo done generating small version of $file_name... generating rest

	cd $file_name

	# reset int_i for next loop
	int_i=0

	while [ $int_i -lt 1 ];
	do
		files -"$line_increase_amount"c
		cd ../
		dir_size=$($file_sizer $file_name)
		dir_size=$(echo $dir_size | awk '{print $4}')
		is_greater_result=$($is_greater_func $dir_size $large_file_size)
		if [ "$is_greater_result" == "true" ]; then
			int_i=$[int_i+1]
		else
			cd $file_name
		fi
	done

	echo finished generating $file_name

}


larger_size=$1
smaller_size=$2

#create_file_named "tiny" 2 1
#create_file_named "small" 4 2
#create_file_named "medium" 8 4
#create_file_named "large" 16 8
create_file_named "extra_large" 32 16
