#!/usr/bin/bash
### Use this on 1st line to echo all cmds to stderr:     #!/bin/bash -x
##  ***************************************************************************
##  File:   gen_lightning_users_report.sh
##  Author: Jitender Saini
##
##  Usage: gen_lightning_users_report.sh
##  ===========================================================================
##  Example: gen_lightning_users_report.sh
##
##  Description:
##  The purpose of this script is to generate alert if more than 199 custom objects is assigne to Lightning user. 
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
MAIL_TO=jsaini@cadence.com
MAIL_TO=jsaini@cadence.com,raos@cadence.com,arpitak@cadence.com
export ORACLE_SID=sfmon
. /usr/local/.ora_profile
export username=sfprod21
export pass=sfprod21
export LIGHTNING_HOME=/usr/orasys/work/jsaini/LIGHTNING_2021
#
#################################################
sqlplus -s $username/$pass <<EOF
@$LIGHTNING_HOME/create_view_21/LIGHTNING_OBJ_PERMISSIONS.sql
EOF
sqlplus -s $username/$pass <<EOF
set markup csv on delimiter | quote on
spool $LIGHTNING_HOME/reports/lightning__users_custom_obj_count.csv
select ID,USERNAME,name, EMAIL,PROFILEID,count(*) as "No of Custom Objects Assigned" from VIEW_LIGHTNING_OBJ_PERMISSIONS group by ID,USERNAME,name, EMAIL,PROFILEID order by "No of Custom Objects Assigned" desc
/
spool off
EOF
MAIL_MGS=/tmp/lightning__users_custom_obj_count.txt
cat /dev/null > $MAIL_MGS
date > $MAIL_MGS 2>&1
echo " " >> $MAIL_MGS 2>&1
echo "Hi Team, " >> $MAIL_MGS 2>&1
echo "            " >> $MAIL_MGS 2>&1
echo "      Please find attaced the no of custom objects assigned to All lighting profiles users report." >> $MAIL_MGS 2>&1
echo "                                                                                 " >> $MAIL_MGS 2>&1
echo "---------------------------------------------------------------------------------" >> $MAIL_MGS 2>&1
#if [ -f $LIGHTNING_HOME/reports/lightning__users_custom_obj_count.csv ]
#then
sqlplus -s $username/$pass <<EOF > /tmp/lightning__users_custom_obj_count.count
set serverout off;
set feedback off;
set head off ;
select max(count(*)) from VIEW_LIGHTNING_OBJ_PERMISSIONS group by ID,USERNAME,name, EMAIL,PROFILEID
/
EOF
echo
#fi 
#export MAX_OBJ=`cat /tmp/lightning__users_custom_obj_count.count`
export MAX_OBJ=`cat /tmp/lightning__users_custom_obj_count.count |  grep "\S" | sed "s/ //g"| sed "s/\t\t*/ /g" | sed "s/^ //g" | sed "s/ $//g"`
echo MAX_OBJ=$MAX_OBJ
echo "Maximum ${MAX_OBJ} Custom object assigned to Lightning User.                       " >> $MAIL_MGS 2>&1
echo "                                                                                                          " >> $MAIL_MGS 2>&1
head -10 $LIGHTNING_HOME/reports/lightning__users_custom_obj_count.csv >> $MAIL_MGS 2>&1
echo "---------------------------------------------------------------------------------" >> $MAIL_MGS 2>&1
echo "                                                                                 " >> $MAIL_MGS 2>&1
echo "                                                                                                          " >> $MAIL_MGS 2>&1
echo "                                                                                                          " >> $MAIL_MGS 2>&1
echo "                                                                                                          " >> $MAIL_MGS 2>&1
echo "Thanks & Regards,                                                                                         " >> $MAIL_MGS 2>&1
echo "                                                                                                          " >> $MAIL_MGS 2>&1
echo "SFDC Config Team.                                                                                           " >> $MAIL_MGS 2>&1
echo "This is Auto Generated Email.                                                                                           " >> $MAIL_MGS 2>&1
cd $LIGHTNING_HOME/reports
if [ $MAX_OBJ -gt 199 ]
then
echo MAX_OBJ=$MAX_OBJ
mailx -a lightning__users_custom_obj_count.csv -s "[Breached: Maximum ${MAX_OBJ} Custom object assigned to Lightning User.]" -r breached@Lightninguser.com $MAIL_TO < $MAIL_MGS
else
MAIL_TO=jsaini@cadence.com
mailx -a lightning__users_custom_obj_count.csv -s "[Report: Maximum ${MAX_OBJ} Custom object assigned to Lightning User.]" -r report@Lightninguser.com $MAIL_TO < $MAIL_MGS
echo "No Alert"
fi 
