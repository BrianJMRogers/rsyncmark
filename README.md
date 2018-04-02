## ACQUISITION
There are two ways of acquiring rsyncmark. selecting the ```clone or download button``` on this page and then clicking ```Download ZIP```. This will download rsyncmark as a zip file into your default downloads directory. From here, unzip the file and you're ready to go. Alternatively, you can clone the directory from your terminal window. Simply run the command ```git clone git@github.com:BrianJMRogers/rsyncmark.git``` and the rsyncmark directory will be cloned to your computer. Once you have the directory, you're almost ready to use rsyncmark. 

## DEPENDENCIES

Expect is an essential part of rsyncmark. It is used to respond to the password prompts presented by rsync and ssh. Installing Expect is fairly easy, simply run ```sudo yum install``` expect or ```sudo apt-get install expect``` at the command line. The Expect homepage can be found at http://expect.sourceforge.net/ where you can find alternative means of downloading the program as well as other information about the package.

## CONFIGURATION

Before running rsyncmark you’ll need to edit the ```rsyncmark.conf``` file. There are 6 possible things to edit in this file, 2 of which are necessary for you to address while 4 of which are added for your convenience. The following 2 items are those which you will necessarily need to configure:

1. ```destination_password_prompt```: refers to the exact wording of the password prompt you see when you attempt to ssh into the destination machine. This may look like ```Password:``` or ```password for user@domain:```. Whatever it is, add it here.

2. ```destination_shell_prompt```: refers to the shell prompt you see once you have ssh’d into the destination machine. Often times this is a ```$``` or a ```#``` character followed by a space (the space is very important). Whatever it is, add it here.

The following 4 items are those which you may choose to configure if you wish:

1. ```ssh_args```: here you can pass in any arguments to the ssh command used by rsyncmark to ```ssh``` into the destination machine.

2. ```rsync_args```: here you can pass in any arguments to ```rsync``` which you’d like to benchmark to use as it runs and records each trial.

3. ```num_warm_ups```: refers to the number of unmeasured warm up runs which are performed by rsyncmark before the trial runs.

4. ```num_trial_runs```: refers to the number of trial runs you would like performed on each file set.

## EXECUTION

Once configured, executing rsyncmark is simple. To execute rsyncmark you’ll need to pass in 3 arguments in any order. Those arguments are for output file, destination, and trial name. Output file, passed in after the -o parameter, refers to the name of the output file rsyncmark will record output to. If a file by the given name does not exist, rsyncmark creates one. If it does exist, rsyncmark will write it’s data to the end of the file. Destination refers to the user and IP address on the destination machine with which rsyncmark will exchange files. The destination is passed in after the -h parameter and typically looks like user@<IP address>. The final parameter is the trial name parameter which is passed in after the -n parameter. This value of this argument is used in the output file so that various trials can be listed in the same output file. An example rsyncmark command might look like:

```./rsyncmark main.sh -o output.csv -h user@1.2.3.4 -n macOS```

## GENERATING YOUR OWN FILES

The random files generator, *files*, is not a dependency to rsyncmark in general but IS a dependency if you would like to generate your own data files using the utility provided by rsyncmark. If you do plan on generating your own files using, you’ll need to visit https://github.com/thomd/random-files-generator. Once here, follow the installation instructions.

At this point, you should be able to use the *files* command at the command line and you’re ready to generate your own files.
Rsyncmark comes with a prewritten file generating utility. You can find it in the ```rsyncmark/src/utils/file generator/``` directory. The utility file, called create ```directories.sh```, is a shell script. Before running the script, you should make sure it is executable by typing the command ```chmod +x create directories.sh``` while inside the ```rsyncmark/src/utils/file generator/``` directory. After this, you can run the command ```./create files.sh``` to run the script. Note that this script, as written, could take over 6 hours to fully execute.

If you would like to create files that are of different sizes than rsyncmark’s default files, you’ll need to edit the source code of ```create files.sh```. Open the file in a text editor and scroll to the bottom of the file. You’ll see the lines:


```
create file named "tiny" 2 1

create file named "small" 4 2

create file named "medium" 8 4

create file named "large" 16 8
```

The two numbers to the right of each end quote refer to the sizes (in MB) of the files produced by that line. The first number indicates the size of the “new” version and the second number indicates the size of the “old” version. The “new” version must be twice the size of the “old” version. You can change these numbers to suit your needs.

After the files have been produced, move the “old” files into ```rsyncmark/files/rsyncmark/staging/``` and delete the “old” endings from each file name. Move the “new” files into ```rsyncmark/files/new/```. You’ll need to make sure that there exist directories called “tiny”, “small”, “medium”, and “large” within both ```rsyncmark/files/rsyncmark/staging/``` and ```rsyncmark/files/rsyncmark/staging```.

## USING YOUR OWN FILES

You can use your own files instead of the files provided by rsync with the only param- eters being that there exist directories called “tiny”, “small”, “medium”, and “large”
31 within both ```rsyncmark/files/new/``` and ```rsyncmark/files/rsyncmark/staging```. Note that the “new” files should go inside the ```rsyncmark/files/new/``` and the “old” versions should go inside the ```rsyncmark/files/rsyncmark/staging/``` directory.
