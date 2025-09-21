#!/bin/ksh
#!/bin/bash
### Use this on 1st line to echo all cmds to stderr:     #!/bin/bash -x
##  ***************************************************************************
##  File:   sfdc_users_comp_with_workday.sh
##  Author: Jitender Saini
##
##  Usage: sfdc_users_comp_with_workday.sh
##  ===========================================================================
##  Example: sfdc_users_comp_with_workday.sh
##
##  Description:
##  The purpose of this script is to generate SFDC active users list. 
##  ===========================================================================
##  Perform analyze  of tables.
##
##
##  *********************** Modification History ******************************
##
##  Date     By           Description
##  -------- ------------ -----------------------------------------------------
##
##  ***************************************************************************
#
#
###################################
MAIL_TO=jsaini
EMAIL_ALERT=/tmp/Review_Profile_Assigned.csv
MAIL_MGS=/tmp/Review_Profile_Assigned.msg
DATE=`/bin/date "+%y%m%d"`
#export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.131-11.b12.el7.x86_64
#export PATH=$JAVA_HOME/bin:$PATH
which java
java -version
#source /software/codedev/.bashrc
echo "ORG Name|OBJ_NAME                   |Row Exported|Time Taken Seconds" > email_alert.email 
echo "START TIME `date` " > email_alert.email
echo " " >> email_alert.email
OBJ_NAME=user
echo ===============================
echo OBJ_NAME=$OBJ_NAME
echo ===============================
echo "                     Object backup for $ORG_NAME ORG.......  " >> email_alert.email

/usr/bin/time -a -o capture_time.txt -p ant -f build_export.xml -Dpropertyfile="prod_build.properties" -Dobject="$OBJ_NAME" -Ddump="full" export
echo =========================================================================
##############################################################
SFDC_ACTIVE_USRS_FILE=active_users_in_SFDC.txt
if [ -d  exportDirprod ]
then
cat exportDirprod/user.full.csv |  sed 's/"//g' | sed 's/@cadence.com//g' > /tmp/active_users_in_SFDC.txt 
fi
export FTP_TO=sapsmsn3
export FTP_TO_USER=orasn3
export FTP_TO_PASSWD=cadence1
export FTP_TO_DIR=/oracle/SN3/sfdc_users_check
#====================================================================================
export FTP_LOG=/tmp/ftp_export_obj_PROD_user.log
cat /dev/null > $FTP_LOG
export FTP_FROM_DIR=/tmp
export START_DATE=`date`
cd $FTP_FROM_DIR
echo "   " >> $FTP_LOG 2>&1
ftp -inv $FTP_TO<<EOF >> $FTP_LOG 2>&1
user $FTP_TO_USER $FTP_TO_PASSWD
cd $FTP_TO_DIR
prompt
put $SFDC_ACTIVE_USRS_FILE
close
bye
EOF
echo                                              >> $FTP_LOG 2>&1
echo   "========================================" >> $FTP_LOG 2>&1
