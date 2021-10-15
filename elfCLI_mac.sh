#!/bin/bash
# Bash script to download EventLogFiles

# Pre-requisite: download jq - http://stedolan.github.io/jq/ to parse JSON - brew install jq
# Pre-requisite: download force CLI - https://force-cli.heroku.com/

#login through OAuth flow to CLI
force login

#set username using force whoami
username=`force whoami | grep Username | sed 's/^Username: //'`
#echo ${username}

#set AccessToken from force accounts
#echo more ~/.force/accounts/${username}
access_token=`more ~/.force/accounts/${username} | jq -r '.AccessToken'`
#echo ${access_token}

#set InstanceURL from force accounts
instance_url=`more ~/.force/accounts/${username} | jq -r '.InstanceUrl'`
#echo ${instance_url}

#prompt the user to enter what date they want to get the logs for or just press enter to take the default of 'Yesterday'
read -p "Please enter logdate (e.g. Yesterday, Last_Week, Last_n_Days:5) (and press ENTER): " day
day=${day:-Yesterday}
#echo ${day}

#set elfs to the result of ELF query
elfs=`curl ${instance_url}/services/data/v48.0/query?q=Select+Id+,+EventType+,+LogDate+From+EventLogFile+Where+LogDate+=+${day} -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1"`

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
    #echo "curl \"${instance_url}/services/data/v29.0/sobjects/EventLogFile/${ids[$i]}/LogFile\" -H \"Authorization: Bearer ${access_token}\" -H \"X-PrettyPrint:1\" -o \"${eventTypes[$i]}-${logDates[$i]}.csv\""

    #download files into the logDate directory
    curl --compressed "${instance_url}/services/data/v48.0/sobjects/EventLogFile/${ids[$i]}/LogFile" -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1" -o "${logDates[$i]}/${eventTypes[$i]}-${logDates[$i]}.csv"
done