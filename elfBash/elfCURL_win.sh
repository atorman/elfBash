#!/bin/bash
# Bash script to download EventLogFiles
# Pre-requisite: download - http://stedolan.github.io/jq/ to parse JSON

#prompt the user to enter their instance end-point 
echo 
read -p "Please enter instance (e.g. emea) for the loginURL (and press ENTER): " instance

#uncomment next line to set default for testing purposes - default currently set to na1
instance=${instance:-na1}

#prompt the user to enter the date for the logs they want to download
read -p "Please enter logdate (e.g. Yesterday, Last_Week, Last_n_Days:5) (and press ENTER): " day

#uncomment next line to set default for testing purposes - default currently set to last 4 days
day=${day:-Last_n_Days:4}

#uncomment next line if you want to check your username, instance, or password input
echo "instance ${instance} and day ${day}"

#set elfs to the result of ELF query
elfs=`curl https://${instance}.salesforce.com/services/data/v29.0/query?q=Select+Id+,+EventType+,+LogDate+From+EventLogFile+Where+LogDate+=+${day} -H 'Authorization: Bearer {AccessToken}' -H "X-PrettyPrint:1"`

#uncomment next line if you want to see the result of elfs
#echo ${elfs}

#uncomment next line if you want to see the array of Ids from the ELF query
#echo ${elfs} | ./jq -r ".records[].Id"

#set the three variables to the array of Ids, EventTypes, and LogDates which will be used when downloading the files into your directory
ids=( $(echo ${elfs} | ./jq -r ".records[].Id" | sed 's/[ \t]*$//') )
eventTypes=( $(echo ${elfs} | ./jq -r ".records[].EventType" | sed 's/[ \t]*$//') )
logDates=( $(echo ${elfs} | ./jq -r ".records[].LogDate" | sed 's/'T.*'//' | sed 's/[ \t]*$//') )

#loop through the array of results and download each file with the following naming convention: EventType-LogDate.csv
for i in "${!ids[@]}"; do
    
    #uncomment the next three lines if you want to see the array of Ids, EventTypes, and LogDates
    echo "${i}: ${ids[$i]}"
    echo "${i}: ${eventTypes[$i]}"
    echo "${i}: ${logDates[$i]}"

    #make directory to store the files by date
    mkdir "${logDates[$i]}"

    #download files into the logDate directory
    curl "https://na1.salesforce.com/services/data/v29.0/sobjects/EventLogFile/${ids[$i]}/LogFile" -H 'Authorization: Bearer {AccessToken}' -H "X-PrettyPrint:1" -o "${logDates[$i]}/${eventTypes[$i]}.csv"
done 