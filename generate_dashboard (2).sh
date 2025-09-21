#!/bin/bash
### Use this on 1st line to echo all cmds to stderr:     #!/bin/bash -x
##  ***************************************************************************
##  File:   generate_dashboard.sh
##  Author: Jitender Saini
##
##  Usage: generate_dashboard.sh
##  ===========================================================================
##  Example: generate_dashboard.sh
##
##  Description:
##  The purpose of this script is refresh the Salesforce License dashboard  .
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
DATE=`/bin/date "+%y%m%d"`
##############################################################
TOTAL_SALESFORCE_LIGHTNING_SELA=1555
TOTAL_SERVICE_LICENCE_SELA=1000
##############################################################
DATE=`/bin/date "+%y%m%d"`
for FILE in `cat objects.txt`
do
OBJ_NAME=`echo $FILE | cut -d'.' -f1`
TYPE_1=`echo $FILE | cut -d'.' -f2`
cat /dev/null > capture_time.txt
echo OBJ_NAME=$OBJ_NAME
/usr/bin/time -a -o capture_time.txt -p ant -f build_export.xml -Dpropertyfile="prod_build.properties" -Dobject="$OBJ_NAME" -Ddump="full" export
echo =========================================================================
done
DATE=`/bin/date "+%y%m%d"`
for FILE in `cat objects_2.txt`
do
OBJ_NAME=`echo $FILE | cut -d'.' -f1`
TYPE_1=`echo $FILE | cut -d'.' -f2`
cat /dev/null > capture_time.txt
echo OBJ_NAME=$OBJ_NAME
/usr/bin/time -a -o capture_time.txt -p ant -f build_export_2.xml -Dpropertyfile="prod_build_2.properties" -Dobject="$OBJ_NAME" -Ddump="full" export
echo =========================================================================
done
##############################################################
cat /dev/null > status_in_ORG.txt
echo "NAME|TOTALLICENSES|USEDLICENSES|REMAINING" > status_in_ORG.txt
if [ -d  exportDirprod ]
then
cat exportDirprod/userlicense.full.csv |grep -v TOTALLICENSES > exportDirprod/userlicense.full.csv_1 
cat exportDirprod/userlicense.full.csv_1 | while read LINE
do
export LIC_NAME=`echo $LINE | sed 's/"//g'| cut -f1 -d","`
export TOTAL_LIC=`echo $LINE | sed 's/"//g'| cut -f2 -d","`
export USED_LIC=`echo $LINE | sed 's/"//g'| cut -f3 -d","`
export REMAINING_LIC=`expr $TOTAL_LIC - $USED_LIC` 
#echo LIC_NAME=$LIC_NAME
#echo TOTAL_LIC=$TOTAL_LIC
#echo USED_LIC=$USED_LIC
#echo REMAINING_LIC=$REMAINING_LIC
echo "---------------------------------------"
echo "${LIC_NAME}|$TOTAL_LIC|$USED_LIC|$REMAINING_LIC" > "${LIC_NAME}"
cat "${LIC_NAME}" >> status_in_ORG.txt
echo "---------------------------------------"
done
fi
echo "---------------------------------------"
#cat status_in_ORG.txt | sed -i 's/Salesforce Platform/Salesforce_Platform/g' | sed -i 's/Force.com - App Subscription/Force.com/g'
sed -i 's/Salesforce/Salesforce_Sales_Service/g' status_in_ORG.txt 
sed -i 's/Salesforce_Sales_Service Platform/Salesforce_Platform/g' status_in_ORG.txt 
sed -i 's/Force.com - App Subscription/Force.com/g' status_in_ORG.txt
cat status_in_ORG.txt
echo "---------------------------------------"
TOTAL_SALESFORCE_LICENSE=`cat status_in_ORG.txt | grep Salesforce_Sales_Service | cut -f2 -d"|"`
TOTAL_SALESFORCE_LICENSE_CONSUMED=`cat status_in_ORG.txt | grep Salesforce_Sales_Service | cut -f3 -d"|"`
TOTAL_SALESFORCE_LICENSE_REMAINING=`cat status_in_ORG.txt | grep Salesforce_Sales_Service | cut -f4 -d"|"`
export TOTAL_SALESFORCE_LICENSE_CONSUMED=$TOTAL_SALESFORCE_LICENSE_CONSUMED
rm exportDirprod/userlicense.full.csv_1
if [ -d  exportDirprod ]
then
SALESFORCE_LIGHTNING_USED=`cat exportDirprod/user.full.csv |tail -1| sed 's/"//g'`
SALESFORCE_LIGHTNING_REMAINING=`expr $TOTAL_SALESFORCE_LIGHTNING_SELA - $SALESFORCE_LIGHTNING_USED`
echo TOTAL_SALESFORCE_LIGHTNING_SELA=$TOTAL_SALESFORCE_LIGHTNING_SELA
echo SALESFORCE_LIGHTNING_USED=$SALESFORCE_LIGHTNING_USED
echo SALESFORCE_LIGHTNING_REMAINING=$SALESFORCE_LIGHTNING_REMAINING
echo "---------------------------------------"
fi
if [ -d  exportDirprod_2 ]
then
SERVICE_LICENCE_USED=`cat exportDirprod_2/user.full.csv |tail -1| sed 's/"//g'`
echo TOTAL_SERVICE_LICENCE_SELA=$TOTAL_SERVICE_LICENCE_SELA
echo SERVICE_LICENCE_USED=$SERVICE_LICENCE_USED
export SERVICE_LICENCE_REMAINING=`expr $TOTAL_SERVICE_LICENCE_SELA - $SERVICE_LICENCE_USED`
fi
echo "---------------------------------------"
export TOTAL_SALES_LICENCE_SELA=`expr $TOTAL_SALESFORCE_LICENSE - $TOTAL_SALESFORCE_LIGHTNING_SELA - $TOTAL_SERVICE_LICENCE_SELA`
export SALES_LICENCE_USED=`expr $TOTAL_SALESFORCE_LICENSE_CONSUMED - $SALESFORCE_LIGHTNING_USED - $SERVICE_LICENCE_USED`
SALES_LICENCE_REMAINING=`expr $TOTAL_SALES_LICENCE_SELA - $SALES_LICENCE_USED`
echo SALES_LICENCE_USED=$SALES_LICENCE_USED
echo TOTAL_SALES_LICENCE_SELA=$TOTAL_SALES_LICENCE_SELA
echo SALES_LICENCE_REMAINING=$SALES_LICENCE_REMAINING
echo "---------------------------------------"
echo 
TOTAL_SFDC_PLATFORM_LICENSE=`cat status_in_ORG.txt | grep Salesforce_Platform | cut -f2 -d"|"`
TOTAL_SFDC_PLATFORM_CONSUMED=`cat status_in_ORG.txt | grep Salesforce_Platform | cut -f3 -d"|"`
TOTAL_SFDC_PLATFORM_REMAINING=`cat status_in_ORG.txt | grep Salesforce_Platform | cut -f4 -d"|"`
echo TOTAL_SFDC_PLATFORM_CONSUMED=$TOTAL_SFDC_PLATFORM_CONSUMED
FORCE_COM_LICENSE=`cat status_in_ORG.txt | grep Force.com | cut -f2 -d"|"`
FORCE_COM_CONSUMED=`cat status_in_ORG.txt | grep Force.com | cut -f3 -d"|"`
FORCE_COM_REMAINING=`cat status_in_ORG.txt | grep Force.com | cut -f4 -d"|"`
FORCE_COM_LOGICALLY_REMAINING=`expr $FORCE_COM_REMAINING - $TOTAL_SFDC_PLATFORM_CONSUMED`
echo FORCE_COM_LOGICALLY_REMAINING=$FORCE_COM_LOGICALLY_REMAINING
COMM_LICENSE=`cat status_in_ORG.txt | grep "Customer Community" | cut -f2 -d"|"`
COMM_CONSUMED=`cat status_in_ORG.txt | grep "Customer Community" | cut -f3 -d"|"`
COMM_REMAINING=`cat status_in_ORG.txt | grep "Customer Community" | cut -f4 -d"|"`
#echo  FORCE.COM_LOGICALLY_REMAINING=$FORCE.COM_LOGICALLY_REMAINING
export DATE=`date`
######
HTMLLog=/data/public/sfdc_dashboard/index.html
echo "<HTML>" > $HTMLLog
        echo "<BODY>" >> $HTMLLog
        echo "<table width=100%>" >> $HTMLLog
           echo "<TABLE WIDTH="630" cellpadding="0">" >> $HTMLLog 
            echo "<tr valign="bottom">" >> $HTMLLog
           echo "</td>" >> $HTMLLog
            echo "</tr>" >> $HTMLLog
           echo "</TABLE>" >> $HTMLLog
          echo "<td width=700 style="background:#E5E5E5">" >> $HTMLLog
                        echo "<b>" >> $HTMLLog
                        #echo "<span style="color:blue;font-weight:bold ; font-size:x-large" > SALESFORCE LICENSE DASHBOARD </span>" >> $HTMLLog
                        echo "<H3><tr text-align=center;><td text-align=center; bgcolor="Tomato"> SALESFORCE LICENSE DASHBOARD </td></tr></H3>" >> $HTMLLog
                         echo "</b>" >> $HTMLLog
                      echo "</td>" >> $HTMLLog
echo "<H3><tr><td bgcolor="SeaShell"> $DATE </td></tr></H3>" >> $HTMLLog
echo "<H3><tr><td bgcolor="SeaShell">License Status In Salesforce ORG </td></tr></H3>" >> $HTMLLog
echo "<tr><td><table style="width:60%" border="2"><tr><th bgcolor="Cyan">NAME</th><th bgcolor="Cyan">TOTALLICENSES</th><th bgcolor="Cyan">USEDLICENSES</th><th bgcolor="Cyan">REMAINING</th></tr>" >> $HTMLLog
echo "<tr><th style="text-align:left">Salesforce Platform</th><th style="text-align:right">${TOTAL_SFDC_PLATFORM_LICENSE}</th><th style="text-align:right">${TOTAL_SFDC_PLATFORM_CONSUMED}</th><th style="text-align:right">${TOTAL_SFDC_PLATFORM_REMAINING}</th></tr>" >> $HTMLLog
echo "<tr><th style="text-align:left">Force.com</th><th style="text-align:right">${FORCE_COM_LICENSE}</th><th style="text-align:right">${FORCE_COM_CONSUMED}</th><th style="text-align:right">${FORCE_COM_REMAINING}</th></tr>" >> $HTMLLog
echo "<tr><th style="text-align:left">Customer Community</th><th style="text-align:right">${COMM_LICENSE}</th><th style="text-align:right">${COMM_CONSUMED}</th><th style="text-align:right">${COMM_REMAINING}</th></tr>" >> $HTMLLog
echo "<tr><th style="text-align:left">Salesforce</th><th style="text-align:right">${TOTAL_SALESFORCE_LICENSE}</th><th style="text-align:right">${TOTAL_SALESFORCE_LICENSE_CONSUMED}</th><th style="text-align:right">${TOTAL_SALESFORCE_LICENSE_REMAINING}</th></tr>" >> $HTMLLog
echo "</table></td></tr>" >> $HTMLLog
                echo "<H3><tr><td bgcolor="SeaShell">License Utilization</td></tr></H3>" >> $HTMLLog
echo "<tr><td><table style="width:60%" border="2"><tr><th bgcolor="Orange">NAME</th><th bgcolor="Orange">TOTALLICENSES</th><th bgcolor="Orange">USEDLICENSES</th><th bgcolor="Orange">REMAINING</th></tr>" >> $HTMLLog
echo "<tr><th style="text-align:left">Salesforce Lightning</th><th style="text-align:right">${TOTAL_SALESFORCE_LIGHTNING_SELA}</th><th style="text-align:right">${SALESFORCE_LIGHTNING_USED}</th><th style="text-align:right">${SALESFORCE_LIGHTNING_REMAINING}</th></tr>" >> $HTMLLog
echo "<tr><th style="text-align:left">Salesforce Service</th><th style="text-align:right">${TOTAL_SERVICE_LICENCE_SELA}</th><th style="text-align:right">${SERVICE_LICENCE_USED}</th><th style="text-align:right">${SERVICE_LICENCE_REMAINING}</th></tr>" >> $HTMLLog
if [ $SALES_LICENCE_REMAINING -le 0 ]; then
echo "<tr><th bgcolor="Yellow" style="text-align:left">Salesforce Sales</th><th style="text-align:right">${TOTAL_SALES_LICENCE_SELA}</th><th style="text-align:right">${SALES_LICENCE_USED}</th><th bgcolor="Yellow" style="text-align:right">${SALES_LICENCE_REMAINING}</th></tr>" >> $HTMLLog
else
echo "<tr><th style="text-align:left">Salesforce Sales</th><th style="text-align:right">${TOTAL_SALES_LICENCE_SELA}</th><th style="text-align:right">${SALES_LICENCE_USED}</th><th style="text-align:right">${SALES_LICENCE_REMAINING}</th></tr>" >> $HTMLLog
fi
echo "<tr><th style="text-align:left">REMAINING Force.com (REMAINING Force.com in ORG (${FORCE_COM_REMAINING}) - Salesforce Platform USEDLICENSES (${TOTAL_SFDC_PLATFORM_CONSUMED})) </th><th style="text-align:right">${FORCE_COM_LICENSE}</th><th style="text-align:right">${FORCE_COM_CONSUMED}</th><th style="text-align:right">${FORCE_COM_LOGICALLY_REMAINING}</th></tr>" >> $HTMLLog
echo "</table></td></tr>" >> $HTMLLog
##########################################################################################
                echo "<H3><tr><td bgcolor="SeaShell">Managed Package License Status</td></tr></H3>" >> $HTMLLog
echo "<tr><td><table style="width:60%" border="2"><tr><th bgcolor="Violet">NAMESPACEPREFIX</th><th bgcolor="Violet">PACKAGE NAME</th><th bgcolor="Violet">ALLOWEDLICENSES</th><th bgcolor="Violet">USEDLICENSES</th><th bgcolor="Violet">REMAINING</th><th bgcolor="Violet">EXPIRATIONDATE</th>" >> $HTMLLog
cat /dev/null > managed_package_ORG.txt
echo "NAME|TOTALLICENSES|USEDLICENSES|REMAINING" > managed_package_ORG.txt
if [ -d  exportDirprod ]
then
cat exportDirprod/PackageLicense.full.csv |grep -v NAMESPACEPREFIX > exportDirprod/PackageLicense.full.csv_1 
cat exportDirprod/PackageLicense.full.csv_1 | while read LINE
do
export LIC_NAME=`echo $LINE | sed 's/"//g'| cut -f1 -d","`
export TOTAL_LIC=`echo $LINE | sed 's/"//g'| cut -f2 -d","`
export USED_LIC=`echo $LINE | sed 's/"//g'| cut -f3 -d","`
export REMAINING_LIC=`expr $TOTAL_LIC - $USED_LIC` 
export EXPIRATIONDATE=`echo $LINE | sed 's/"//g'| cut -f4 -d","`
echo TOTAL_LIC=$TOTAL_LIC
echo USED_LIC=$USED_LIC
echo REMAINING_LIC=$REMAINING_LIC
export EXPDT=`echo $EXPIRATIONDATE | cut -f1 -d"T"`
echo EXPDT=$EXPDT
if [ ${LIC_NAME} = Apttus ];
then
LIC_NAME_1="Conga Contract Lifecycle Management"
echo "${LIC_NAME}|${LIC_NAME_1}|$TOTAL_LIC|$USED_LIC|$REMAINING_LIC|$EXPDT" > "${LIC_NAME}"
if [ $REMAINING_LIC -le 1 ]; then
echo "<tr><th bgcolor="Yellow" style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th bgcolor="Yellow" style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
else
echo "<tr><th style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
fi
echo LIC_NAME=$LIC_NAME
elif [ ${LIC_NAME} = Apttus_CPQAdmin ];
then
LIC_NAME_1="Conga CPQ Setup"
echo "${LIC_NAME}|${LIC_NAME_1}|$TOTAL_LIC|$USED_LIC|$REMAINING_LIC|$EXPDT" > "${LIC_NAME}"
if [ $REMAINING_LIC -le 1 ]; then
echo "<tr><th bgcolor="Yellow" style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th bgcolor="Yellow" style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
else
echo "<tr><th style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
fi
echo LIC_NAME=$LIC_NAME
elif [ ${LIC_NAME} = APXTConga4 ];
then
LIC_NAME_1="Conga Composer"
echo "${LIC_NAME}|${LIC_NAME_1}|$TOTAL_LIC|$USED_LIC|$REMAINING_LIC|$EXPDT" > "${LIC_NAME}"
if [ $REMAINING_LIC -le 1 ]; then
echo "<tr><th bgcolor="Yellow" style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th bgcolor="Yellow" style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
else
echo "<tr><th style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
fi
echo LIC_NAME=$LIC_NAME
elif [ ${LIC_NAME} = Apttus_XAAdmin ];
then
LIC_NAME_1="Conga X-Author Enterprise Admin"
echo "${LIC_NAME}|${LIC_NAME_1}|$TOTAL_LIC|$USED_LIC|$REMAINING_LIC|$EXPDT" > "${LIC_NAME}"
if [ $REMAINING_LIC -le 1 ]; then
echo "<tr><th bgcolor="Yellow" style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th bgcolor="Yellow" style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
else
echo "<tr><th style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
fi
echo LIC_NAME=$LIC_NAME
elif [ ${LIC_NAME} = Apttus_Approval ];
then
LIC_NAME_1="Conga Approvals"
echo "${LIC_NAME}|${LIC_NAME_1}|$TOTAL_LIC|$USED_LIC|$REMAINING_LIC|$EXPDT" > "${LIC_NAME}"
if [ $REMAINING_LIC -le 1 ]; then
echo "<tr><th bgcolor="Yellow" style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th bgcolor="Yellow" style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
else
echo "<tr><th style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
fi
echo LIC_NAME=$LIC_NAME
elif [ ${LIC_NAME} = Apttus_Proposal ];
then
LIC_NAME_1="Conga Quote Management"
echo "${LIC_NAME}|${LIC_NAME_1}|$TOTAL_LIC|$USED_LIC|$REMAINING_LIC|$EXPDT" > "${LIC_NAME}"
if [ $REMAINING_LIC -le 1 ]; then
echo "<tr><th bgcolor="Yellow" style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th bgcolor="Yellow" style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
else
echo "<tr><th style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
fi
echo LIC_NAME=$LIC_NAME
elif [ ${LIC_NAME} = SVMXC ];
then
LIC_NAME_1="ServiceMax"
echo "${LIC_NAME}|${LIC_NAME_1}|$TOTAL_LIC|$USED_LIC|$REMAINING_LIC|$EXPDT" > "${LIC_NAME}"
if [ $REMAINING_LIC -le 1 ]; then
echo "<tr><th bgcolor="Yellow" style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th bgcolor="Yellow" style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
else
echo "<tr><th style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
fi
echo LIC_NAME=$LIC_NAME
elif [ ${LIC_NAME} = Apttus_Config2 ];
then
LIC_NAME_1="Conga Configuration & Pricing"
echo "${LIC_NAME}|${LIC_NAME_1}|$TOTAL_LIC|$USED_LIC|$REMAINING_LIC|$EXPDT" > "${LIC_NAME}"
if [ $REMAINING_LIC -le 1 ]; then
echo "<tr><th bgcolor="Yellow" style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th bgcolor="Yellow" style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
else
echo "<tr><th style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
fi
echo LIC_NAME=$LIC_NAME
elif [ ${LIC_NAME} = Apttus_DocGen ];
then
LIC_NAME_1="Conga Custom Docgen API"
echo "${LIC_NAME}|${LIC_NAME_1}|$TOTAL_LIC|$USED_LIC|$REMAINING_LIC|$EXPDT" > "${LIC_NAME}"
if [ $REMAINING_LIC -le 1 ]; then
echo "<tr><th bgcolor="Yellow" style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th bgcolor="Yellow" style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
else
echo "<tr><th style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
fi
echo LIC_NAME=$LIC_NAME
elif [ ${LIC_NAME} = Apttus_XApps ];
then
LIC_NAME_1="Conga X-Author Enterprise"
echo "${LIC_NAME}|${LIC_NAME_1}|$TOTAL_LIC|$USED_LIC|$REMAINING_LIC|$EXPDT" > "${LIC_NAME}"
if [ $REMAINING_LIC -le 1 ]; then
echo "<tr><th bgcolor="Yellow" style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th bgcolor="Yellow" style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
else
echo "<tr><th style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
fi
echo LIC_NAME=$LIC_NAME
elif [ ${LIC_NAME} = Apttus_XAppsDS ];
then
LIC_NAME_1="Conga X-Author Designer For Excel"
echo "${LIC_NAME}|${LIC_NAME_1}|$TOTAL_LIC|$USED_LIC|$REMAINING_LIC|$EXPDT" > "${LIC_NAME}"
if [ $REMAINING_LIC -le 1 ]; then
echo "<tr><th bgcolor="Yellow" style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th bgcolor="Yellow" style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
else
echo "<tr><th style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
fi
echo LIC_NAME=$LIC_NAME
elif [ ${LIC_NAME} = Apttus_XADocGen ];
then
LIC_NAME_1="Conga X-Author Enterprise Document Generation"
echo "${LIC_NAME}|${LIC_NAME_1}|$TOTAL_LIC|$USED_LIC|$REMAINING_LIC|$EXPDT" > "${LIC_NAME}"
if [ $REMAINING_LIC -le 1 ]; then
echo "<tr><th bgcolor="Yellow" style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th bgcolor="Yellow" style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
else
echo "<tr><th style="text-align:left">$LIC_NAME</th><th style="text-align:right">${LIC_NAME_1}</th><th style="text-align:right">${TOTAL_LIC}</th><th style="text-align:right">${USED_LIC}</th><th style="text-align:right">${REMAINING_LIC}</th><th style="text-align:right">${EXPDT}</th>" >> $HTMLLog
fi
echo LIC_NAME=$LIC_NAME
else
echo
#echo "${LIC_NAME}|$TOTAL_LIC|$USED_LIC|$REMAINING_LIC|$EXPDT" > "${LIC_NAME}"
#echo LIC_NAME=$LIC_NAME
fi
cat "${LIC_NAME}" >> managed_package_ORG.txt
echo "---------------------------------------"
done
fi
cat  managed_package_ORG.txt
echo "</table></td></tr>" >> $HTMLLog
echo "</HTML></BODY>" >> $HTMLLog
####################################################
DATE1=`/bin/date "+%m%d%y"`
if [ ! -f /data/public/sfdc_dashboard/${DATE1}.html ];
then
cp /data/public/sfdc_dashboard/index.html /data/public/sfdc_dashboard/${DATE1}.html
fi
####################################################
