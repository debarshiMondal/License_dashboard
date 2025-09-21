#!/bin/ksh
#
#!/bin/bash
### Use this on 1st line to echo all cmds to stderr:     #!/bin/bash -x
##  ***************************************************************************
##  File:   review_profile_upgrade_report.sh
##  Author: Jitender Saini
##
##  Usage: review_profile_upgrade_report.sh
##  ===========================================================================
##  Example: review_profile_upgrade_report.sh
##
##  Description:
##  The purpose of this script is to geneate report for the profile assigned/upgraded for user. 
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
###################################
MAIL_TO=jsaini
MAIL_TO=jsaini,arpitak,raos
EMAIL_ALERT=/tmp/Review_Profile_Assigned.csv
MAIL_MGS=/tmp/Review_Profile_Assigned.msg
DATE=`/bin/date "+%y%m%d"`
for FILE in `cat objects.txt`
do
OBJ_NAME=`echo $FILE | cut -d'.' -f1`
TYPE_1=`echo $FILE | cut -d'.' -f2`
cat /dev/null > capture_time.txt
echo OBJ_NAME=$OBJ_NAME
/usr/bin/time -a -o capture_time.txt -p ant -f build_export.xml -Dpropertyfile="prod_build.properties" -Dobject="$OBJ_NAME" -Ddump="full" export
echo =========================================================================
if [ -d  exportDirprod ]
then
head -1 exportDirprod/SetupAuditTrail.full.csv > $EMAIL_ALERT
cat exportDirprod/SetupAuditTrail.full.csv | grep "Changed profile for user" | grep -v "to Cadence General User Force.com" | grep -v "to Force.com - App Subscription User" | grep -v "to 4_4 - Apttus Lightning" | grep -v "to Cadence General User Lightning" | grep -v "to 4_4 - Apttus Platform Profile" | grep -v "to 4_4 - Legal_Apttus" >> $EMAIL_ALERT
cat exportDirprod/SetupAuditTrail.full.csv | grep "Changed profile for user" | grep -v "to Cadence General User Force.com" | grep -v "to Force.com - App Subscription User" | grep -v "to 4_4 - Apttus Lightning" | grep -v "to Cadence General User Lightning" | grep -v "to 4_4 - Apttus Platform Profile" | grep -v "to 4_4 - Legal_Apttus" > /tmp/export_obj_PROD.usr 
fi
done
echo "Hi Team, " > $MAIL_MGS 2>&1
echo "            " >> $MAIL_MGS 2>&1
echo "The following profile assignment reported in Salesforce Production. " >> $MAIL_MGS 2>&1
echo "Please make sure that ONLY necessary profile is assigned to User." >> $MAIL_MGS 2>&1
echo "                                                                                 " >> $MAIL_MGS 2>&1
echo "---------------------------------------------------------------------------------" >> $MAIL_MGS 2>&1
cat $EMAIL_ALERT >> $MAIL_MGS 2>&1
echo "---------------------------------------------------------------------------------" >> $MAIL_MGS 2>&1
echo "                                                                                 " >> $MAIL_MGS 2>&1
echo "                                                                                                          " >> $MAIL_MGS 2>&1
echo "                                                                                                          " >> $MAIL_MGS 2>&1
echo "                                                                                                          " >> $MAIL_MGS 2>&1
echo "Thanks & Regards,                                                                                         " >> $MAIL_MGS 2>&1
echo "                                                                                                          " >> $MAIL_MGS 2>&1
echo "SFDC Config Team.                                                                                           " >> $MAIL_MGS 2>&1
#echo "This is Auto Generated Email.                                                                                           " >> $MAIL_MGS 2>&1
cat $MAIL_MGS
if [ -s /tmp/export_obj_PROD.usr ]
then
cd /tmp
mailx -a Review_Profile_Assigned.csv -s "[Review Profile Assigned in SFDC Prod]"  $MAIL_TO < $MAIL_MGS
else
echo "No Alert"
fi
cd 
