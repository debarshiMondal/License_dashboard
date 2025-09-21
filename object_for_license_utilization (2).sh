#!/bin/ksh
#
#!/bin/bash
### Use this on 1st line to echo all cmds to stderr:     #!/bin/bash -x
##  ***************************************************************************
##  File:   object_for_license_utilization.sh
##  Author: Jitender Saini
##
##  Usage: object_for_license_utilization.sh
##  ===========================================================================
##  Example: object_for_license_utilization.sh
##
##  Description:
##  The purpose of this script is to export objects for lightning and force.com license. 
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
###################################
MAIL_TO=jsaini@cadence.com
ORG_NAME=PROD
BUILD_PROP=prod_build.properties
BKUP_DIR=/backup/export_ORA_LIGHTNING
###################################
DATE=`/bin/date "+%m%d%y"`
EXP_DIR=`cat $BUILD_PROP | grep exportDir | cut -f2 -d"="`
echo "ORG Name|OBJ_NAME                   |Row Exported|Time Taken Seconds" > email_alert.email 
echo "-----------------------------------------------------------------" >> email_alert.email
echo "EXPORT START TIME `date` " > email_alert.email
echo "-----------------------------------------------------------------" >> email_alert.email
echo " " >> email_alert.email
echo "                     Object backup for Lightning License Review: $ORG_NAME ORG.......  " >> email_alert.email
echo "       " >> email_alert.email
#echo EXP_DIR=$EXP_DIR >> email_alert.email
#echo BUILD_PROP=$BUILD_PROP >> email_alert.email
#if [ ! -f ${BKUP_DIR}/export.flag ]
#then
#echo
#exit 1
#fi
echo BKUP_DIR=$BKUP_DIR >> email_alert.email
echo "================================================================="
#cat email_alert.email
for FILE in `cat objects.txt`
do
echo "-----------------------------------------------------------------" >> email_alert.email
OBJ_NAME=`echo $FILE | cut -d'.' -f1`
TYPE_1=`echo $FILE | cut -d'.' -f2`
#echo "===================================" >> email_alert.email
echo ">>>> Exporting $OBJ_NAME Object <<<< " >> email_alert.email
echo "===================================" >> email_alert.email
if [ -f ${BKUP_DIR}/${OBJ_NAME}.full_${DATE}.log ]
then
rm ${BKUP_DIR}/${OBJ_NAME}.full_${DATE}.log >> email_alert.email
fi
###
if [ -f  $EXP_DIR/${OBJ_NAME}.full.csv ]
then
rm $EXP_DIR/${OBJ_NAME}.full.csv
fi
cat /dev/null > capture_time.txt
#echo "/usr/bin/time -a -o capture_time.txt -p ant -f build_export.xml -Dpropertyfile="$BUILD_PROP" -Dobject="$OBJ_NAME" -Ddump="full" export" >> email_alert.email
#echo "Start Time:- `/bin/date`"  >> email_alert.email
echo "                        " >> email_alert.email
#/usr/bin/time -a -o capture_time.txt -p ant -f build_export.xml -Dpropertyfile="$BUILD_PROP" -Dobject="$OBJ_NAME" -Ddump="full" export
/usr/bin/time -a -o capture_time.txt -p ant -f build_export.xml -Dpropertyfile="$BUILD_PROP" -Dobject="$OBJ_NAME" -Ddump="full" export > ${BKUP_DIR}/${OBJ_NAME}.full_${DATE}.log
if [ -f ${BKUP_DIR}/${OBJ_NAME}.full_${DATE}.log ]
then
tail -5 ${BKUP_DIR}/${OBJ_NAME}.full_${DATE}.log > email_alert.email.tmp
if grep -i failed email_alert.email.tmp > /dev/null 2>&1
then
cat email_alert.email.tmp |sed 's/BUILD SUCCESSFUL/EXPORT FAILED WITH ERROR!!!!!!!/g' >> email_alert.email
elif grep -i doneError email_alert.email.tmp > /dev/null 2>&1
then
cat email_alert.email.tmp |sed 's/BUILD SUCCESSFUL/EXPORT FAILED WITH ERROR!!!!!!!/g' >> email_alert.email
else
cat email_alert.email.tmp | sed 's/BUILD SUCCESSFUL/EXPORT COMPLETED SUCCESSFULLY/g' >> email_alert.email
fi
fi
#####
if [ -f  $EXP_DIR/${OBJ_NAME}.full.csv ]
then
#zip -r  ${BKUP_DIR}/${OBJ_NAME}.full.csv.zip $EXP_DIR/${OBJ_NAME}.full.csv
#echo `ls -l ${BKUP_DIR}/${OBJ_NAME}.full.csv.zip` >> email_alert.email
#rm $EXP_DIR/${OBJ_NAME}.full.csv
if [ ${OBJ_NAME} = user ]
then
mv $EXP_DIR/${OBJ_NAME}.full.csv ${BKUP_DIR}/${OBJ_NAME}s.csv
OBJ_NAME=users
elif [ ${OBJ_NAME} = Profile ]
then
mv $EXP_DIR/${OBJ_NAME}.full.csv ${BKUP_DIR}/${OBJ_NAME}s.csv
OBJ_NAME=Profiles
elif [ ${OBJ_NAME} = UserLicense ]
then
mv $EXP_DIR/${OBJ_NAME}.full.csv ${BKUP_DIR}/${OBJ_NAME}s.csv
OBJ_NAME=UserLicenses
else
mv $EXP_DIR/${OBJ_NAME}.full.csv ${BKUP_DIR}/${OBJ_NAME}.csv
fi
echo `ls -l ${BKUP_DIR}/${OBJ_NAME}.csv` >> email_alert.email
fi
#echo "End Time:- `/bin/date`"  >> email_alert.email
done
cp email_alert.email ${BKUP_DIR}/email_alert.email_${DATE}
#clear
echo "-----------------------------------------------------------------" >> email_alert.email
echo "EXPORT END TIME `date` " >> email_alert.email
echo "-----------------------------------------------------------------" >> email_alert.email
if grep -i "EXPORT FAILED WITH ERROR" email_alert.email > /dev/null 2>&1
then
mail -s "export FAILED: Object backup for Lightning License Review : $ORG_NAME ORG." $MAIL_TO < email_alert.email
else
mail -s "export SUCCESSFUL: Object backup for Lightning License Review : $ORG_NAME ORG." $MAIL_TO < email_alert.email
fi
cat email_alert.email
#############################
export BKUP_DIR=/backup/export_ORA_LIGHTNING
export RSERVER=wcoratstdbl02
export USER=oracle
export PASSWORD=Bab@160tul
export RDIR=/usr/orasys/work/jsaini/LIGHTNING_2021
./expect_object_for_license_utilization.sh $RSERVER $USER $PASSWORD $BKUP_DIR $RDIR
#############################
if [ -d ${BKUP_DIR} ]
then
rm $BKUP_DIR/ARCH/*
mv $BKUP_DIR/* $BKUP_DIR/ARCH
fi
