#!/bin/bash
# Bash script to download EventLogFiles and load them into Wave
# Pre-requisite: download - http://stedolan.github.io/jq/ to parse JSON
# Pre-requisite: download datasetutil - http://bit.ly/datasetutil

 #/**
 #* Copyright (c) 2012, Salesforce.com, Inc.  All rights reserved.
 #* 
 #* Redistribution and use in source and binary forms, with or without
 #* modification, are permitted provided that the following conditions are
 #* met:
 #* 
 #*   * Redistributions of source code must retain the above copyright
 #*     notice, this list of conditions and the following disclaimer.
 #* 
 #*   * Redistributions in binary form must reproduce the above copyright
 #*     notice, this list of conditions and the following disclaimer in
 #*     the documentation and/or other materials provided with the
 #*     distribution.
 #* 
 #*   * Neither the name of Salesforce.com nor the names of its
 #*     contributors may be used to endorse or promote products derived
 #*     from this software without specific prior written permission.
 #* 
 #* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 #* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 #* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 #* A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 #* HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 #* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 #* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 #* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 #* THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 #* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 #* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 #*/

#prompt the user to enter their username for the target (Wave) org
read -p "Please enter the Wave target org username (and press ENTER): " tUsername

#prompt the user to enter their password for the target (Wave) org
read -s -p "Please enter the Wave target org password (and press ENTER): " tPassword

#prompt the user to enter their username for the source (Event Monitoring) org
read -p "Please enter username for Event Monitoring source org (and press ENTER): " username

#prompt the user to enter their password for the source (Event Monitoring) org
read -s -p "Please enter password for Event Monitoring source org (and press ENTER): " password

#prompt the user to enter their clientid
read -p "Please enter Salesforce connected app client id (and press ENTER): " client_id

#prompt the user to enter their clientsecret
read -s -p "Please enter Salesforce connected app client secret (and press ENTER): " client_secret

#prompt the user to enter their instance end-point for the source (Event Monitoring) org
echo 
read -p "Please enter the My Domain (e.g. <MYDOMAIN>.lightning.force.com (just the first part in <> §) for the for Event Monitoring source org loginURL (and press ENTER): " instance

#prompt the user to enter the date for the logs they want to download for the source (Event Monitoring) org
read -p "Please enter logdate (e.g. Yesterday, Last_Week, Last_n_Days:5) (and press ENTER): " day

#prompt the user to enter the eventType they want to download for the source (Event Monitoring) org
printf 'What EventType do you want to download?\n'
printf '1. All 48 event types (Default)\n'
printf '2. ApexCallout\n'
printf '3. ApexExecution\n'
printf '4. ApexREST\n'
printf '5. ApexSoap\n'
printf '6. ApexTrigger\n'
printf '7. ApexUnexpectedException\n'
printf '8. API\n'
printf '9. API Total Usage\n'
printf '10. AsynchronousReportRun\n'
printf '11. Aura Request\n'
printf '12. Bulk API 2.0\n'
printf '13. BulkApi\n'
printf '14. ChangeSetOperation\n'
printf '15. ConcurrentLongRunningApexLimit\n'
printf '16. Console\n'
printf '17. ContentDistribution\n'
printf '18. ContentDocumentLink\n'
printf '19. ContentTransfer\n'
printf '20. ContinuationCalloutSummary\n'
printf '21. CORS Violation\n'
printf '22. Dashboard\n'
printf '23. DocumentAttachmentDownoads\n'
printf '24. ExternalCrossOrgCallout\n'
printf '25. ExternalCustomApexCallout\n'
printf '26. ExternalODataCallout\n'
printf '27. Flow Execution\n'
printf '28. InsecureExternalAssets\n'
printf '29. KnowledgeArticleView\n'
printf '30. LightningError\n'
printf '31. LightningInteraction\n'
printf '32. LightningPageView\n'
printf '33. LightningPerformance\n'
printf '34. LoginAs\n'
printf '35. Login\n'
printf '36. Logout\n'
printf '37. MetadataApiOperation\n'
printf '38. MultiblockReport\n'
printf '39. Named Credential\n'
printf '40. One Commerce\n'
printf '41. PackageInstall\n'
printf '42. PlatformEncryption\n'
printf '43. QueuedExecution\n'
printf '44. Report\n'
printf '45. ReportExport\n'
printf '46. RestApi\n'
printf '47. Sandbox\n'
printf '48. SearchClick\n'
printf '49. Search\n'
printf '50. Sites\n'
printf '51. TimeBasedWorkflow\n'
printf '52. TransactionSecurity\n'
printf '53. URI\n'
printf '54. VisualforceRequest\n'
printf '55. WaveChange\n'
printf '56. WaveDownload\n'
printf '57. WaveInteraction\n'
printf '58. WavePerformance\n'

read eventMenu

case $eventMenu in
     1)
          eventType=${eventType:-All}
          ;;
     2)
          eventType=${eventType:-ApexCallout}
          ;;
     3)
          eventType=${eventType:-ApexExecution}
          ;; 
     4) 
          eventType=${eventType:-ApexRestApi} ###
          ;;     
     5)
          eventType=${eventType:-ApexSoap}
          ;; 
     6)
          eventType=${eventType:-ApexTrigger}
          ;;      
     7)
          eventType=${eventType:-ApexUnexpectedException}
          ;; 
     8)
          eventType=${eventType:-API}
          ;; 
     9)
          eventType=${eventType:-ApiTotalUsage} ####
          ;; 
     10)
          eventType=${eventType:-AsynchronousReportRun}
          ;; 
     11)
          eventType=${eventType:-AuraRequest} ###
          ;; 
     12)
          eventType=${eventType:-BulkApi2} ###
          ;; 
     13)
          eventType=${eventType:-BulkApi}
          ;; 
     14)
          eventType=${eventType:-ChangeSetOperation}
          ;; 
     15)
          eventType=${eventType:-ConcurrentLongRunningApexLimit}
          ;; 
     16)
          eventType=${eventType:-Console}
          ;; 
     17)
          eventType=${eventType:-ContentDistribution}
          ;; 
     18)
          eventType=${eventType:-ContentDocumentLink}
          ;; 
     19)
          eventType=${eventType:-ContentTransfer}
          ;; 
     20)
          eventType=${eventType:-ContinuationCalloutSummary}
          ;; 
     21)
          eventType=${eventType:-CVR} ###
          ;; 
     22)
          eventType=${eventType:-Dashboard}
          ;; 
     23)
          eventType=${eventType:-DocumentAttachmentDownoads}
          ;; 
     24)
          eventType=${eventType:-ExternalCrossOrgCallout}
          ;; 
     25)
          eventType=${eventType:-ExternalCustomApexCallout}
          ;; 
     26)
          eventType=${eventType:-ExternalODataCallout}
          ;; 
     27)
          eventType=${eventType:-FlowExecution} ###
          ;; 
     28)
          eventType=${eventType:-InsecureExternalAssets}
          ;; 
     29)
          eventType=${eventType:-KnowledgeArticleView}
          ;; 
     30)
          eventType=${eventType:-LightningError}
          ;; 
     31)
          eventType=${eventType:-LightningInteraction}
          ;; 
     32)
          eventType=${eventType:-LightningPageView}
          ;; 
     33)
          eventType=${eventType:-LightningPerformance}
          ;; 
     34)
          eventType=${eventType:-LoginAs}
          ;; 
     35)
          eventType=${eventType:-Login}
          ;; 
     36)
          eventType=${eventType:-Logout}
          ;; 
     37)
          eventType=${eventType:-MetadataApiOperation}
          ;; 
     38)
          eventType=${eventType:-MultiblockReport}
          ;; 
     39)
          eventType=${eventType:-NamedCredential} ###
          ;; 
     40)
          eventType=${eventType:-OneCommerceUsage} ###
          ;; 
     41)
          eventType=${eventType:-PackageInstall}
          ;; 
     42)
          eventType=${eventType:-PlatformEncryption}
          ;; 
     43)
          eventType=${eventType:-QueuedExecution}
          ;; 
     44)
          eventType=${eventType:-Report}
          ;; 
     45)
          eventType=${eventType:-ReportExport}
          ;; 
     46)
          eventType=${eventType:-RestApi}
          ;; 
     47)
          eventType=${eventType:-Sandbox}
          ;; 
     48)
          eventType=${eventType:-SearchClick}
          ;; 
     49)
          eventType=${eventType:-Search}
          ;; 
     50)
          eventType=${eventType:-Sites}
          ;; 
     51)
          eventType=${eventType:-TimeBasedWorkflow}
          ;; 
     52)
          eventType=${eventType:-TransactionSecurity}
          ;; 
     53)
          eventType=${eventType:-URI}
          ;; 
     54)
          eventType=${eventType:-VisualforceRequest}
          ;; 
     55)
          eventType=${eventType:-WaveChange}
          ;; 
     56)
          eventType=${eventType:-WaveDownload}####
          ;; 
     57)
          eventType=${eventType:-WaveInteraction}
          ;; 
     58)
          eventType=${eventType:-WavePerformance}
          ;; 
     *)
          eventType=${eventType:-All}
          ;;
esac


#debug tool ---- uncomment to use the following defaults
 tUsername="admin@hpeapps.ey.demo"
 tPassword='Welcome1'
 username='admin@hpeapps.ey.demo'
 password='Welcome1'
 client_id='3MVG9p1Q1BCe9GmCHgejeShXeTTjEpI1hxvsiHvy3ymusgx4v7GA7dNuO5J.bsKfCCFarfAx5MBhJU0fJgtKI'
 client_secret='372EFFBD131F20EE4EEE3E88C5B72DE3410FC481DB06B3C19C32003AA1A6F6CE'
 instance='hpeappsdemo'
 day='Last_Week'
 eventType=${eventType:-All}
# end debug section-----

echo ${eventType}


#set access_token for OAuth flow 
#change client_id and client_secret to your own connected app - bit.ly/sfdcConnApp

response=`curl https://login.salesforce.com/services/oauth2/token -d "grant_type=password" -d "client_id=${client_id}" -d "client_secret=${client_secret}" -d "username=${username}" -d "password=${password}" -H "X-PrettyPrint:1"`
#echo ${response}

access_token=`echo ${response} | jq -r '.access_token'`
#echo ${access_token}

instance_url=`echo ${response} | jq -r '.instance_url'`
#echo ${instance_url}

#uncomment next line if you want to check your access token
#echo "Access token: ${access_token}"

if [ $eventType == All ]; then

    #set elfs to the result of ELF query *without* EventType in query
    elfs=`curl ${instance_url}/services/data/v48.0/query?q=Select+Id+,+EventType+,+LogDate+From+EventLogFile+Where+LogDate+=+${day} -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1"`

else
    #set elfs to the result of ELF query *with* EventType in query
    elfs=`curl ${instance_url}/services/data/v48.0/query?q=Select+Id+,+EventType+,+LogDate+From+EventLogFile+Where+LogDate+=+${day}+AND+EventType+=+\'${eventType}\' -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1"`
  
fi


#echo $elfs

#set the three variables to the array of Ids, EventTypes, and LogDates which will be used when downloading the files into your local directory
ids=( $(echo ${elfs} | jq -r ".records[].Id") )
eventTypes=( $(echo ${elfs} | jq -r ".records[].EventType" ) )
logDates=( $(echo ${elfs} | jq -r ".records[].LogDate" | sed 's/'T.*'//' ) )




#echo Ids: ${ids}
#echo "eventTypes: ${eventTypes}"
#echo "logDates: ${logDates}"

#loop through the array of results and download each file with the following naming convention: EventType.csv
for i in "${!ids[@]}"; do
    
    #make directory to store the files by date and separate out raw data from 
    #converted timezone data
    mkdir "${eventTypes[$i]}-raw"
    mkdir "${eventTypes[$i]}"
 

    #download files into the ${eventTypes[$i]}-raw directory
    curl --compressed "${instance_url}/services/data/v48.0/sobjects/EventLogFile/${ids[$i]}/LogFile" -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1" -o "${eventTypes[$i]}-raw/${eventTypes[$i]}-${logDates[$i]}.csv" 

    #convert files into the ${eventTypes[$i]} directory for Salesforce Analytics
    awk -F ','  '{ if(NR==1) printf("%s\n",$0); else{ for(i=1;i<=NF;i++) { if(i>1&& i<=NF) printf("%s",","); if(i == 2) printf "\"%s-%s-%sT%s:%s:%sZ\"", substr($2,2,4),substr($2,6,2),substr($2,8,2),substr($2,10,2),substr($2,12,2),substr($2,14,2); else printf ("%s",$i);  if(i==NF) printf("\n")}}}' "${eventTypes[$i]}-raw/${eventTypes[$i]}-${logDates[$i]}.csv" > "${eventTypes[$i]}/${eventTypes[$i]}-${logDates[$i]}.csv"

done

#variable to count the number of unique event types
uEventTypes=( $(echo ${elfs} | jq -r ".records[].EventType" | uniq) )

#merge data into single CSV file
for j in "${uEventTypes[@]}"
do
    output_file="$j.csv"
    count=0

    for f in `ls $j/*.csv`
    do
        echo "still merging [$f]"
            
            echo "merging file: $f to $output_file."
            if [ $count -eq 0 ]; then

                    awk -F ',' '{print $0}' $f 1>$output_file
            else
                    awk -F ',' 'FNR>1 {print $0}' $f 1>>$output_file
            fi
            count=`expr $count + 1`
            echo "number of input files: $count merged to output file: $output_file"
    done
done

#load CSV files to datasets in Wave
for i in `ls *.csv`; do
    #variables to specify file and dataset name
    eventFile=`echo $i`
    eventName=`echo $i | sed 's/\.csv//g'`
    
    #comment next line to test before uploading to Wave
    java -jar datasetutils-48.1.0.jar --action load --u ${tUsername} --p ${tPassword} --inputFile ${eventFile} --dataset ${eventName}
done

#prompt user to clean up data and directories
read -p "Do you want to delete data directories and files? (Y/N)" del 

if [ $del == Y ] || [ $del == y ] || [ $del == Yes ] || [ $del == yes ]; then
    #clean up data directories
    for i in "${!uEventTypes[@]}"; do
        rm -r "${uEventTypes[$i]}-raw"
        rm -r "${uEventTypes[$i]}"
        rm "${uEventTypes[$i]}.csv"
    done
    rm -r "archive"
    #leave data and directories for audit reasons
    echo "The files were removed."
elif [ $del == N ] || [ $del == n ] || [ $del == No ] || [ $del == no ]; then
    echo "The files will remain."
fi

echo "The script finished successfully."
