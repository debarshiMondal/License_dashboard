#!/bin/ksh
##############################################################
##  ***************************************************************************
##  Script: chk_user_with_workday_term_mstr_V1.sh 
##  Description: 
##   This script is used to verify the all SFDC system users with the WORKDAY.
## 
##  Author: Jitender Saini
##
##  Usages: Before execting this process please make sure that the SFDC_ID is maintained
##  in the SFDC_SYS_BAS_TERM.txt file.
##
##  *********************** Modification History ******************************
##
##  Date     By            Description
##  -------- ------------- ----------------------------------------------------
##     Jitender Saini Initial release
##
##  ***************************************************************************
###########################################
export M_TO=jsaini@cadence.com,raos@cadence.com
###########################################
DATE=`date +%b-%d`
DATE_Y=`date +%b-%d-%Y`
export DATE DATE_Y
###########################################
export IMP_ALE_CNT=4
export WORKDAY_UTIL_HOME_BIN=/oracle/SN3/admin/dbautil/bin
export SFDC_SYSTEMS=${WORKDAY_UTIL_HOME_BIN}/SFDC_SYS_BAS_TERM.txt
export SFDC_USERS_HOME_DIR=/oracle/SN3/sfdc_users_check
####################################################
export WORKDAY_UTIL_HOME=/oracle/SN3/admin/dbautil
export PATH=$PATH:/oracle/SN3/admin/dbautil/bin
export WORKDAY_UTIL_HOME_LOG=/oracle/SN3/admin/dbautil/log
####################################################
export WORKDAY_TERM_FILE=term.stripped
export WORKDAY_TERM_HOME_DIR=${WORKDAY_UTIL_HOME}/term_file
export WORKDAY_TERM_ARCH_DIR=${WORKDAY_TERM_HOME_DIR}/ARCH_TERM_FILE
export GEN_WORKDAY_TERM_USERS_LIST=${WORKDAY_TERM_HOME_DIR}/workday_term_user_date_${DATE}.txt
export SFDC_TERM_USERS=/tmp/SFDC_term_users_$SFDC_ID_${DATE}.txt
export GEN_WORKDAY_TERM_USER=/tmp/workday_term_users_${DATE}.txt
export GEN_WORKDAY_TERM_DATE=/tmp/workday_term_date_${DATE}.txt
export GEN_WORKDAY_TERM_1=/tmp/workday_term_1_${DATE}.txt
export TERM_USR_VER_RUNNING_FILE=`hostname`_ver_dia_active_usrs'_sfdc.running'
export USR_VER_RUNNING='/tmp/'${TERM_USR_VER_RUNNING_FILE}
####################################################
rm -f /tmp/workday_term*.txt
################## FTP ##################################
export FTP_FROM_SERV=mosstp.cadence.com
export FTP_FROM_SERV_PASSWD=Xul8Jek
export FTP_FROM_SERV_USER=sapfeed
export FTP_FROM_REMOTE_DIR=/usr3/netadmin/workday
export FTP_TO_LOCAL_DIR=${WORKDAY_TERM_HOME_DIR}
export FTP_LOG=${WORKDAY_UTIL_HOME_LOG}/workday_term_ftp_log_${DATE}.log
export START_DATE=`date`
#############################################################################
if [ ! -f $USR_VER_RUNNING ]
then
   touch $USR_VER_RUNNING
else
   ls -alt $USR_VER_RUNNING
echo "The Process is already running".
mailx -s "The Process $0 is already running on `hostname` Err_01. Please check and run the process again." jsaini@cadence.com < /dev/null
find /tmp -name ${USR_VER_RUNNING} -mtime +1 -exec rm {} \;  2> /dev/null
#exit 1
fi
################################################################################
echo "   " > $FTP_LOG 2>&1
echo Copying $WORKDAY_TERM_FILE from `hostname` to $FTP_FROM_SERV. >> $FTP_LOG 2>&1
ftp -inv $FTP_FROM_SERV<<EOF >> $FTP_LOG 2>&1
user $FTP_FROM_SERV_USER $FTP_FROM_SERV_PASSWD 
lcd $FTP_TO_LOCAL_DIR
cd $FTP_FROM_REMOTE_DIR 
ascii
prompt
get $WORKDAY_TERM_FILE 
close
bye
EOF
echo                                              >> $FTP_LOG 2>&1  
echo   "========================================" >> $FTP_LOG 2>&1
#############################################################################
export END_DATE=`date` 
export MESS_FILE=/tmp/workday_term_ftp_work_term_get.msg
echo The ftp is over from `hostname`  to $FTP_FROM_SERV. Please check the log file. > $MESS_FILE 2>&1
echo =======================================================================>> $MESS_FILE 2>&1 
echo "     "  >> $MESS_FILE 2>&1
cat $FTP_LOG >> $MESS_FILE 2>&1
echo "     "  >> $MESS_FILE 2>&1
echo The ftp started at $START_DATE and completed at $END_DATE >> $MESS_FILE 2>&1
echo =======================================================================>> $MESS_FILE 2>&1 
mailx -s "FTP status from `hostname` to $FTP_FROM_SERV" jsaini@cadence.com < $MESS_FILE
##
################################################################################
sleep 5
#Generate the workday TERM users list.
if [ -f ${WORKDAY_TERM_HOME_DIR}/term.stripped ]
then
echo " " > /dev/null 2>&1
cat ${WORKDAY_TERM_HOME_DIR}/term.stripped | cut -f14 -d"	"  > ${GEN_WORKDAY_TERM_USER} 2>&1
cat ${WORKDAY_TERM_HOME_DIR}/term.stripped | cut -f21 -d"	"  > ${GEN_WORKDAY_TERM_DATE} 2>&1
cat ${WORKDAY_TERM_HOME_DIR}/term.stripped | cut -f9 -d"	"  > ${GEN_WORKDAY_TERM_1} 2>&1
paste -d ":" ${GEN_WORKDAY_TERM_USER} ${GEN_WORKDAY_TERM_DATE} ${GEN_WORKDAY_TERM_1} > ${GEN_WORKDAY_TERM_USERS_LIST} 2>&1
else
echo ${WORKDAY_TERM_HOME_DIR}/term.stripped File doesnt exists.
mailx -s "Today Workday TermFile ${WORKDAY_TERM_HOME_DIR}/term.stripped not exists.  Please check and run the process again." jsaini@cadence.com < /dev/null
rm $USR_VER_RUNNING
exit 1
fi



########

Chk_Term_User_In_Sfdc ()
{
###########################################
###############################################################################################
echo
echo
echo User Name:Term Date:Term Stat > $SFDC_TERM_USERS 2>&1
for line in `cat  $GEN_WORKDAY_TERM_USERS_LIST | grep -v "^#" | grep -v "^*" | grep -v "^$" | awk '{print $1}'| sed 's/ //g' | sed 's/ //g'`
do
   export  TERM_USER=`echo $line | cut -f1 -d":"`
   export  TERM_DATE=`echo $line | cut -f2 -d":"`
   export  TERM_STAT=`echo $line | cut -f3 -d":"`
############################33
#echo  TERM_USER_1=$TERM_USER
#echo  TERM_DATE_1=$TERM_DATE
#echo  TERM_STAT_1=$TERM_STAT
############################33
if [ $TERM_STAT = "T" ] ; then
if egrep -w -i "$TERM_USER" $SFDC_USERS_LIST >> /dev/null 2>&1
then
#   echo $TERM_USER exists. 
if [ $TERM_USER = basu ];
then
echo
else
   echo $TERM_USER:$TERM_DATE:$TERM_STAT >> $SFDC_TERM_USERS 2>&1
fi
else
echo > /dev/null 2>&1
#echo $TERM_USER not exists in $SFDC_ACTIVE_USERS file.
#echo $TERM_USER >> comp_users_not_exists_in_target.txt 2>&1 
fi
else 
echo "$TERM_USER is Not a terminated user."
fi
done

}
######################################1#########################################
for LINE in `cat $SFDC_SYSTEMS | awk '{print $1}' | grep -v "^#"`
do
   export SFDC_ID=`echo $LINE | cut -f1 -d":"`
   export MAIL_TO_1=`echo $LINE | cut -f4 -d":"`
   export EMAIL_TICKET_ALERT=`echo $LINE | cut -f5 -d":"`
   export SFDC_ID=$SFDC_ID
   export MAIL_TO=$MAIL_TO_1
###################################################################################
cat /dev/null >  $SFDC_TERM_USERS 2>&1
export SFDC_USERS_LIST=$SFDC_USERS_HOME_DIR/active_users_in_$SFDC_ID.txt
if [ -f $SFDC_USERS_LIST ]
   then
echo "Processing SFDC user verification for Active users for $SFDC_ID system........................"
Chk_Term_User_In_Sfdc
sleep 1
#mv $SFDC_USERS_LIST $SFDC_USERS_HOME_DIR/arch
   else
echo " "
echo "$SFDC_USERS_LIST doesn't not exists on `hostname`."
mailx -s  "$SFDC_USERS_LIST doesn't not exists to verify users for $SFDC_ID on `hostname`." jsaini@cadence.com < /dev/null
fi
###########################################
cd /tmp
export REC_CNT=`cat SFDC_term_users_$SFDC_ID_${DATE}.txt | wc -l`
if  [ -f $SFDC_TERM_USERS ] && [ $REC_CNT != 0 ] ; then
###########################################
export MAIL_MGS=/tmp/Chk_Active_User_In_Term_Users_BAS_$SFDC_ID.msg
export MAIL_MGS_1=/tmp/Chk_Active_User_In_Term_Users_1_BAS_$SFDC_ID.msg
export MAIL_MGS_F=/tmp/Chk_Active_User_In_Term_Users_F_BAS_$SFDC_ID.msg
###########################################
echo "Hi Team, " > $MAIL_MGS 2>&1
echo "            " >> $MAIL_MGS 2>&1
echo "The following Users are identified in the $SFDC_ID system which are terminated from Workday. " >> $MAIL_MGS 2>&1
echo "Please inform Interface Team to inactivate these users in Salesforce." >> $MAIL_MGS 2>&1
echo "                                                                                 " >> $MAIL_MGS 2>&1
echo "                                                                                 " >> $MAIL_MGS 2>&1

###########################################
echo "                                                                                                          " > $MAIL_MGS_1 2>&1
echo "                                                                                                          " >> $MAIL_MGS_1 2>&1
echo "                                                                                                           " >> $MAIL_MGS_1 2>&1
echo "                                                                                                          " >> $MAIL_MGS_1 2>&1
echo "                                                                                                          " >> $MAIL_MGS_1 2>&1
echo "Thanks & Regards,                                                                                         " >> $MAIL_MGS_1 2>&1
echo "                                                                                                          " >> $MAIL_MGS_1 2>&1
echo "SFDC Admin Team.                                                                                           " >> $MAIL_MGS_1 2>&1
echo
echo =======================================================
echo The below users should be inactivated in the $SFDC_ID System.
echo
cat $SFDC_TERM_USERS
echo
echo =======================================================
echo
###########################################
cat $MAIL_MGS > $MAIL_MGS_F 2>&1
cat $SFDC_TERM_USERS >> $MAIL_MGS_F 2>&1
cat $MAIL_MGS_1 >> $MAIL_MGS_F 2>&1
###########################################
### eTicket #######################
export MAIL_REMEDY_PROD=bmcrf_eticket@u-228k59ko31ixh7b2psgzrrrasca76q2brarkw1sdezrqeyrlme.7a-curpua0.cs44.apex.sandbox.salesforce.com
export MAIL_REMEDY_PROD=e-ticket@cadence.com
export REMEDY_ETKT_SUB=/tmp/REMEDY_ETKT_SUB_$SFDC_ID.txt
cat /dev/null > $REMEDY_ETKT_SUB
#####################################################################################
echo "#e_ticket" > $REMEDY_ETKT_SUB 2>&1 
echo "#####################################################" >> $REMEDY_ETKT_SUB 2>&1
echo "#AR-Message-Begin Do Not Delete This Line" >> $REMEDY_ETKT_SUB 2>&1
echo "Schema: IT Help Desk" >> $REMEDY_ETKT_SUB 2>&1
echo "Server: hdprod.Cadence.COM" >> $REMEDY_ETKT_SUB 2>&1
echo "Format: Short" >> $REMEDY_ETKT_SUB 2>&1
echo "Phone!536870912!: 88-543-4053" >> $REMEDY_ETKT_SUB 2>&1
echo "Customer Name!536870928!: jsaini" >> $REMEDY_ETKT_SUB 2>&1
echo "Location!536870939!: NOIDA" >> $REMEDY_ETKT_SUB 2>&1
echo "Status!7!: 0" >> $REMEDY_ETKT_SUB 2>&1
echo "###############Input Fields##########################">> $REMEDY_ETKT_SUB 2>&1
echo "Customer Login!536870936!: jsaini" >> $REMEDY_ETKT_SUB 2>&1
echo "Issue!8!: Problem SFDC Application" >> $REMEDY_ETKT_SUB 2>&1
echo "Description!536870930!: Please Lock and Delete the WorkDay Terminated Users in the $SFDC_ID System." >> $REMEDY_ETKT_SUB 2>&1
echo "	" >> $REMEDY_ETKT_SUB 2>&1
echo "Hi Team," >> $REMEDY_ETKT_SUB 2>&1
echo "	" >> $REMEDY_ETKT_SUB 2>&1
echo "The following Users are identified in the $SFDC_ID system which are terminated from Workday." >> $REMEDY_ETKT_SUB 2>&1
if  [ -f $SFDC_TERM_USERS ] && [ $REC_CNT -ge $IMP_ALE_CNT ] ; then
echo "!!!!!!!!!! Today ${REC_CNT} users are identified in the $SFDC_ID system as termintaed Users from WokDay.!!!!!!!!!!" >> $REMEDY_ETKT_SUB 2>&1
echo "!!!!!!!!!! Please cross verify before locking the users. !!!!!!!!!!">> $REMEDY_ETKT_SUB 2>&1
echo "	" >> $REMEDY_ETKT_SUB 2>&1
fi
echo "	" >> $REMEDY_ETKT_SUB 2>&1
echo "	" >> $REMEDY_ETKT_SUB 2>&1
cat $SFDC_TERM_USERS >> $REMEDY_ETKT_SUB 2>&1
echo "	" >> $REMEDY_ETKT_SUB 2>&1
echo "	" >> $REMEDY_ETKT_SUB 2>&1
echo "Note:-" >> $REMEDY_ETKT_SUB 2>&1
echo "	" >> $REMEDY_ETKT_SUB 2>&1
echo "1. Take approval before changing the SFDC Production System Users." >> $REMEDY_ETKT_SUB 2>&1
echo "2. Make sure that no background jobs scheduled by the above users before locking the users." >> $REMEDY_ETKT_SUB 2>&1
echo "3. Always Lock the users with the End Date." >> $REMEDY_ETKT_SUB 2>&1
echo "4. Once Locked These users should be deleted from SFDC system within 15 days from their termination date." >> $REMEDY_ETKT_SUB 2>&1
echo "	" >> $REMEDY_ETKT_SUB 2>&1
echo "	" >> $REMEDY_ETKT_SUB 2>&1
echo "Thanks & Regards," >> $REMEDY_ETKT_SUB 2>&1
echo "	" >> $REMEDY_ETKT_SUB 2>&1
echo "AutoGenerated Request from SFDC BASIS Team........" >> $REMEDY_ETKT_SUB 2>&1
echo "#####################################################" >> $REMEDY_ETKT_SUB 2>&1
echo "#AR-Message-End Do Not Delete This Line" >> $REMEDY_ETKT_SUB 2>&1
echo "#####################################################" >> $REMEDY_ETKT_SUB 2>&1
### eTicket End #######################
#####################################################################################
cat $REMEDY_ETKT_SUB
if [ $EMAIL_TICKET_ALERT = "E" ] ; then
   mailx -s "Please inactivate WorkDay Terminated Users in the $SFDC_ID System.  !!!!!!" $MAIL_TO_1 < $MAIL_MGS_F
elif [ $EMAIL_TICKET_ALERT = "T" ] ; then
   mailx -s "Please Lock and Delete the WorkDay Terminated Users in the $SFDC_ID System." $MAIL_REMEDY_PROD < $REMEDY_ETKT_SUB
elif [ $EMAIL_TICKET_ALERT = "ET" ] ; then
   mailx -s "Please Lock and Delete the WorkDay Terminated Users in the $SFDC_ID System.  !!!!!!" $MAIL_TO_1 < $MAIL_MGS_F
   mailx -s "Please Lock and Delete the WorkDay Terminated Users in the $SFDC_ID System." $MAIL_REMEDY_PROD < $REMEDY_ETKT_SUB
fi
else
echo -----------------------------------------------------------------------
echo "All users available in the $SFDC_ID systems are active users in workday."
echo -----------------------------------------------------------------------
fi
done
##################################################################################
echo Listing previous day files at local server :`hostname`
if [ -f ${WORKDAY_TERM_HOME_DIR}/term.stripped ] ; then
   ls -l ${WORKDAY_TERM_HOME_DIR}/term.stripped
   ls -l ${WORKDAY_TERM_HOME_DIR}/workday_term_user_date*
   echo "Move Previous day files in arch directory"
   echo
   echo
mv ${WORKDAY_TERM_HOME_DIR}/term.stripped ${WORKDAY_TERM_ARCH_DIR}/term.stripped_${DATE_Y}
mv ${WORKDAY_TERM_HOME_DIR}/workday_term_user_date* ${WORKDAY_TERM_ARCH_DIR}
fi
if [ -f $SFDC_USERS_LIST ]
   then
mv $SFDC_USERS_LIST $SFDC_USERS_HOME_DIR/arch
fi

##################################################################################
sleep 2
rm $USR_VER_RUNNING
