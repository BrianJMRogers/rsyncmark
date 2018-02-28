#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <string>
#include <stdio.h>
#include <dirent.h>

int read_dir(std::string path, double *size_bytes);

int main(int argc, const char *argv[])
{
	// variables
	FILE 						*fp = NULL;
	double 					*size_bytes = NULL;
	double 					size_megabytes = 0;
	std::string			path = "";

	// did they pass in a file name?
	if (argc != 2)
	{
		fprintf(stderr, "[!] need to include file name\n");
		fflush(stderr);
	}

	if ((size_bytes = (double *)calloc(1, sizeof(double))) == NULL)
	{
		fprintf(stderr, "[!] unable to allocate memory for size_bytes\n");
		fflush(stderr);
	}

	path = std::string(argv[1]);

	read_dir(path, size_bytes);


	// convert bytes to MB
	size_megabytes = *size_bytes/1000000;

	// print bytes
	fprintf(stdout, "size of [%s]: %.2f\n", argv[1], size_megabytes);

	return 0;
}

int read_dir(std::string path, double *total_bytes)
{
	DIR 	*directory = opendir(path.c_str());
	int 	retval = 1;
  // test and see if opendir sucessfully opened directory
  if (directory == NULL)
  {
		fprintf(stderr, "[!] read_dir: Unable to open directory with path: %s\terrno: %s\n", path.c_str(), strerror(errno));
    fflush(stderr);
    retval = -1;
	}

  //else we were able to open the directory so lets look inside
  if (directory != NULL)
  {

    // declare variables
    struct dirent       *file = NULL;
    int                 isDirectory = 0;

    // while there are files in directory...
    while((file = readdir(directory)) != NULL)
    {
      // if file is "." or ".." we want to ignore it
      if ((strcmp(file->d_name, ".")) == 0 || (strcmp(file->d_name, "..")) == 0 || (strcmp(file->d_name, ".DS_Storee")) == 0)
      {
        // ignore and do nothing
      }

      // else we write the file's info to the output vector
      else {
				FILE 						*fp = NULL;
				int							file_size = 0;
				int 						isDirectory = 0;

				//fprintf(stdout, "examining: [%s]\n", (path+"/"+std::string(file->d_name)).c_str());
				
				// get file pointer
				if ((fp = fopen((path+"/"+std::string(file->d_name)).c_str(), "r")) == NULL)
				{
					fprintf(stderr, "[!] Error opening file [%s] with errno [%d]-[%s]\n", path.c_str(), errno, strerror(errno));
					fflush(stderr);
				}

				// fseek to the end of the file
				if (fseek(fp, 0L, SEEK_END) == -1)
				{
					fprintf(stderr, "[!] fseek error. errno [%d]-[%s]\n", errno, strerror(errno));
					fflush(stderr);
				}

				// get the number of bytes
				if ((file_size = ftell(fp)) == -1)
				{
					fprintf(stderr, "[!] ftell error. errno [%d]-[%s]\n", errno, strerror(errno));
					fflush(stderr);
				}

				if(file->d_type == DT_DIR)
				{
          isDirectory = 1;
        }

				else {
					*total_bytes += file_size;
					//fprintf(stdout, "total bytes so far: [%d] after [%s]\n", total_bytes, (path+"/"+std::string(file->d_name)).c_str());
				
					//fprintf(stdout, "size: [%d]. file: [%s]\n", file_size, (path+"/"+std::string(file->d_name)).c_str());
				}
	
				
				fseek(fp, 0L, SEEK_SET);

        // if file is directory and depth > 0 and it's not a symbolic link, walk that directory
        if (isDirectory && file->d_type != DT_LNK)
        {
          read_dir(path+"/"+std::string(file->d_name), total_bytes);
        }
      }
    }
		closedir(directory);
	}
	return retval;
}


