#!/bin/bash

read -p "Please enter username (and press ENTER): " username

read -s -p "Please enter password (and press ENTER): " password
 
read -p "Please enter instance (e.g. na1) for the loginURL (and press ENTER): " instance

read -p "Please enter logdate (e.g. Yesterday, Last_Week, Last_n_Days:5) (and press ENTER): " day


access_token=`curl https://${instance}.salesforce.com/services/oauth2/token -d "grant_type=password" -d "client_id=3MVG99OxTyEMCQ3hSjz15qIUWtJCt6fADLrtDeTQA9Lb.liLd5pGQXzLy9qjrph.UIv2UkJWtwt3TnxQ4KhuD" -d "client_secret=2447913710583473942" -d "username=${username}" -d "password=${password}" -H "X-PrettyPrint:1" | jq -r '.access_token'`

elfs=`curl https://${instance}.salesforce.com/services/data/v29.0/query?q=Select+Id+,+EventType+,+LogDate+From+EventLogFile+Where+LogDate+=+${day} -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1"`

ids=( $(echo ${elfs} | jq -r ".records[].Id") )
eventTypes=( $(echo ${elfs} | jq -r ".records[].EventType") )
logDates=( $(echo ${elfs} | jq -r ".records[].LogDate" | sed 's/'T.*'//' ) )

for i in "${!ids[@]}"; do
 
    mkdir "${logDates[$i]}"

    curl "https://${instance}.salesforce.com/services/data/v29.0/sobjects/EventLogFile/${ids[$i]}/LogFile" -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1" -o "${logDates[$i]}/${eventTypes[$i]}-${logDates[$i]}.csv"
done