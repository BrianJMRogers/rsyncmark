
/usr/bin/expect <<EOF
    spawn ./a.out
    expect {
        "Are you sure you want to continue connecting (yes/no)"
        {
            send "1\r"
            exp_continue

        }
        "*assword:"
        {
            send "password\r"
        }
    }
        expect eof
EOF

