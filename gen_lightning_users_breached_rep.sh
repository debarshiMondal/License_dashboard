#!/usr/bin/bash
### Use this on 1st line to echo all cmds to stderr:     #!/bin/bash -x
##  ***************************************************************************
##  File:   gen_lightning_users_breached_rep.sh
##  Author: Jitender Saini
##
##  Usage: gen_lightning_users_breached_rep.sh
##  ===========================================================================
##  Example: gen_lightning_users_breached_rep.sh
##
##  Description:
##  The purpose of this script is to generate alert if Non Lightning Access is granted to Lightning Profile users. 
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
###
MAIL_TO=jsaini@cadence.com
MAIL_TO=jsaini@cadence.com,raos@cadence.com,arpitak@cadence.com
export ORACLE_SID=sfmon
. /usr/local/.ora_profile
export username=sfprod21
export pass=sfprod21
export LIGHTNING_HOME=/usr/orasys/work/jsaini/LIGHTNING_2021
#
(cd /usr/orasys/work/jsaini/LIGHTNING_2021 && bash users/load_users_data.sh)
(cd /usr/orasys/work/jsaini/LIGHTNING_2021 && bash ObjectPermissions/load_ObjectPermissions_data.sh)
(cd /usr/orasys/work/jsaini/LIGHTNING_2021 && bash PermissionSetAssignment/load_PermissionSetAssignment_data.sh)
(cd /usr/orasys/work/jsaini/LIGHTNING_2021 && bash PermissionSet/load_PermissionSet_data.sh)
(cd /usr/orasys/work/jsaini/LIGHTNING_2021 && bash UserLicenses/load_USERLICENSE_data.sh)
(cd /usr/orasys/work/jsaini/LIGHTNING_2021 && bash Profiles/load_Profiles_data.sh)
#################################################
sqlplus -s $username/$pass <<EOF
@$LIGHTNING_HOME/create_view_21/VIEW_USERPROFILES_1.sql
@$LIGHTNING_HOME/create_view_21/VIEW_USEROBJECTS_2.sql
@$LIGHTNING_HOME/create_view_21/VIEW_USERPERMISSION_3.sql
@$LIGHTNING_HOME/create_view_21/VIEW_USERPERMISSIONLIG_4.sql
@$LIGHTNING_HOME/create_view_21/VIEW_USEROBJECTPERMISSIONSUMMARYLIG_5.sql
@$LIGHTNING_HOME/create_view_21/LIGHTNINGLICENSECOMPLIENCE_6.sql
@$LIGHTNING_HOME/create_view_21/VIEW_PROFILEACCESS.sql
@$LIGHTNING_HOME/create_view_21/VIEW_PROFILE_OBJECTPERMISSIONS.sql
@$LIGHTNING_HOME/create_view_21/VIEW_USEROBJECTPERMISSIONSUMMARY_ALL_55.sql
EOF
sqlplus -s $username/$pass <<EOF
set markup csv on delimiter | quote on
spool $LIGHTNING_HOME/reports/review_lightning_access.csv
select * from LIGHTNINGLICENSECOMPLIENCE;
spool off
EOF
MAIL_MGS=/tmp/export_master_all_msg.txt
cat /dev/null > $MAIL_MGS
date > $MAIL_MGS 2>&1
echo " " >> $MAIL_MGS 2>&1
echo "Hi Team, " >> $MAIL_MGS 2>&1
echo "            " >> $MAIL_MGS 2>&1
echo "      Non Lightning Access granted to Lightning Profile User. " >> $MAIL_MGS 2>&1
echo "      Please check and remove Permission set granting Non Lightning Access." >> $MAIL_MGS 2>&1
echo "                                                                                 " >> $MAIL_MGS 2>&1
echo "---------------------------------------------------------------------------------" >> $MAIL_MGS 2>&1
if [ -f $LIGHTNING_HOME/reports/review_lightning_access.csv ]
then
grep BREACHED $LIGHTNING_HOME/reports/review_lightning_access.csv > /tmp/export_master_all.breach
grep BREACHED $LIGHTNING_HOME/reports/review_lightning_access.csv >> $MAIL_MGS 2>&1
fi 
echo "---------------------------------------------------------------------------------" >> $MAIL_MGS 2>&1
echo "                                                                                 " >> $MAIL_MGS 2>&1
echo "                                                                                                          " >> $MAIL_MGS 2>&1
echo "                                                                                                          " >> $MAIL_MGS 2>&1
echo "                                                                                                          " >> $MAIL_MGS 2>&1
echo "Thanks & Regards,                                                                                         " >> $MAIL_MGS 2>&1
echo "                                                                                                          " >> $MAIL_MGS 2>&1
echo "SFDC Config Team.                                                                                           " >> $MAIL_MGS 2>&1
echo "This is Auto Generated Email.                                                                                           " >> $MAIL_MGS 2>&1
if [ -f /tmp/export_master_all.breach ]
then
W_CONT=`cat /tmp/export_master_all.breach| wc -l`
if [ $W_CONT -gt 1 ]
then
echo W_CONT=$W_CONT
#mailx -s "[Breached: Non Lightning Access granted to Lightning Profile User]"  $MAIL_TO < $MAIL_MGS
mailx -s "[Breached: Non Lightning Access granted to Lightning Profile User]" -r breached@Lightninguser.com $MAIL_TO < $MAIL_MGS
else
MAIL_TO=jsaini@cadence.com
mailx -s "[Report: Non Lightning Access granted to Lightning Profile User]" -r report@Lightninguser.com $MAIL_TO < $MAIL_MGS
echo "No Alert"
fi 
fi 
