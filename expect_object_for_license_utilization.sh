#!/usr/bin/expect
# Author: jsaini
 set rserver [lindex $argv 0]
 set user [lindex $argv 1]
 set passwd [lindex $argv 2]
 set ldir [lindex $argv 3]
 set rdir [lindex $argv 4]
 spawn /usr/bin/sftp $user@$rserver
 expect "password:"
 send $passwd\n
 expect "sftp> "
 send "lcd $ldir \n"
 expect "sftp> "
 send "cd $rdir \n"
 expect "sftp> "
 send "mput *.csv \n"
 expect "sftp> "
 sleep 10
 send "ls -l \n"
 expect "sftp> "
 send "exit\n"
 expect eof
