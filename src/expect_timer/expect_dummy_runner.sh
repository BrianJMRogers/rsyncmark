this_file_name="expect_dummy_runner.sh"
dummy_script_name="expect_dummy.sh"
dummy_program_name="dummy_program"

function plz_work
{
    for (( i=1; i<=30; i++ ))
    do
        /usr/bin/expect <<EOF
            spawn ./a.out
            expect {
                "Are you sure you want to continue conneting (yes/no)"
                {
                    send "yes\r"
                    exp_continue
                }
                "*assword:"
                {
                    send "password\r"
                }
            }
        expect eof
EOF
    done
}

if [ ! -f $dummy_script_name ]; then
    echo "[!] $this_file_name is unable to find $dummy_script_name... Unable to time expect script"
    exit
fi

if [ ! -f $dummy_program_name.c ]; then
    echo "[!] $this_file_name is unable to find $dummy_program_name.c... Unable to time expect script"
    exit
fi

gcc $dummy_program_name.c

if [ ! -f $dummy_program_name ]; then
    echo "[!] $this_program_name is unable to find then $dummy_program_name executable... Unable to time expect script"
fi

{ time -p plz_work 1>dump.txt ; } 2>time.txt

#real=$(cat time.txt | grep real | awk '{print $2}')
cat time.txt

rm time.txt
rm dump.txt
