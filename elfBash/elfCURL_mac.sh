#!/bin/bash
# Bash script to download EventLogFiles
# Pre-requisite: download - http://stedolan.github.io/jq/ to parse JSON

#prompt the user to enter their username or uncomment #username line for testing purposes
read -p "Please enter username (and press ENTER): " username

#uncomment next line to set default for testing purposes
#username=${username:-a@at.com}

#prompt the user to enter their password 
read -s -p "Please enter password (and press ENTER): " password

#uncomment next line to set default for testing purposes
#password=${password:-test1234}

#prompt the user to enter their instance end-point 
echo 
read -p "Please enter instance (e.g. na1) for the loginURL (and press ENTER): " instance

#uncomment next line to set default for testing purposes
#instance=${instance:-na1}

#prompt the user to enter the date for the logs they want to download
read -p "Please enter logdate (e.g. Yesterday, Last_Week, Last_n_Days:5) (and press ENTER): " day

#uncomment next line to set default for testing purposes
#day=${day:-Yesterday}

#uncomment next line if you want to check your username, instance, or password input
#echo "Username ${username} and instance ${instance} and day ${day}" #and password ${password} "

#set access_token for OAuth flow 
#change client_id and client_secret to your own connected app
access_token=`curl https://${instance}.salesforce.com/services/oauth2/token -d "grant_type=password" -d "client_id=3MVG99OxTyEMCQ3hSjz15qIUWtJCt6fADLrtDeTQA9Lb.liLd5pGQXzLy9qjrph.UIv2UkJWtwt3TnxQ4KhuD" -d "client_secret=2447913710583473942" -d "username=${username}" -d "password=${password}" -H "X-PrettyPrint:1" | jq -r '.access_token'`

#uncomment next line if you want to check your access token
#echo "Access token: ${access_token}"

#uncomment next line if you want to see the curl command to query ELF
#echo "curl https://${instance}.salesforce.com/services/data/v29.0/query?q=Select+Id+From+EventLogFile+Where+LogDate+=+${day} -H 'Authorization: Bearer ${access_token}' -H \"X-PrettyPrint:1\""

#set elfs to the result of ELF query
elfs=`curl https://${instance}.salesforce.com/services/data/v29.0/query?q=Select+Id+,+EventType+,+LogDate+From+EventLogFile+Where+LogDate+=+${day} -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1"`

#uncomment next line if you want to see the result of elfs
#echo ${elfs}

#uncomment next line if you want to see the array of Ids from the ELF query
#echo ${elfs} | jq -r ".records[].Id"

#set the three variables to the array of Ids, EventTypes, and LogDates which will be used when downloading the files into your directory
ids=( $(echo ${elfs} | jq -r ".records[].Id") )
eventTypes=( $(echo ${elfs} | jq -r ".records[].EventType") )
logDates=( $(echo ${elfs} | jq -r ".records[].LogDate" | sed 's/'T.*'//' ) )

#loop through the array of results and download each file with the following naming convention: EventType-LogDate.csv
for i in "${!ids[@]}"; do
    
    #uncomment the next three lines if you want to see the array of Ids, EventTypes, and LogDates
    #echo "${i}: ${ids[$i]}"
    #echo "${i}: ${eventTypes[$i]}"
    #echo "${i}: ${logDates[$i]}"

    #make directory to store the files by date
    mkdir "${logDates[$i]}"

    #uncomment the next line to see the curl command to download log files
    #echo "curl \"https://${instance}.salesforce.com/services/data/v29.0/sobjects/EventLogFile/${ids[$i]}/LogFile\" -H \"Authorization: Bearer ${access_token}\" -H \"X-PrettyPrint:1\" -o \"${eventTypes[$i]}-${logDates[$i]}.csv\""

    #download files into the logDate directory
    curl "https://${instance}.salesforce.com/services/data/v29.0/sobjects/EventLogFile/${ids[$i]}/LogFile" -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1" -o "${logDates[$i]}/${eventTypes[$i]}-${logDates[$i]}.csv"
done