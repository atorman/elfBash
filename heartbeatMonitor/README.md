#DIY Salesforce Heartbeat Monitor with Real-Time SMS Notifications

##Introduction

Recently, while on a customer on-site, I was asked a simple question - how do we do real-time monitoring of salesforce? These were system administrators and operations people used to monitoring the uptime of their data center. Of course they expected real-time monitoring and automated alerts.

There are many ways to monitor salesforce. And when there isn't standard functionality to monitor, there is always a custom solution. 

About a week ago, I started running into some issues with a new service that I was building. I was inspired by a [sparkfun blog article](https://www.sparkfun.com/news/1527) I read about an open API based on [Phant](http://phant.io/) that allows you to post arbitrary custom values for real-time monitoring. I decided to build my own real-time monitoring system based on a simple heartbeat design that would notify me when my heartbeat skipped a beat. And when it didn't skip a beat, I just wanted to log the success and chart the trend over time for discussion with our engineers.

I had some basic requirements for the first iteration of my monitoring service:

* it had to be automated
* it had to perform the simplest query to determine availability 
* the query mechanism needed to be secure and hosted outside of salesforce
* the charting and notification systems had to be as simple as possible, preferably no passwords or fees for using it in the first iteration. As long as I could obfuscate sensitive data, it could even be publicly exposed data.

My first prototype was done in about half an hour. 

* I created a bash shell script that I hosted on a Linux box under my desk. This was the secure part hosted outside of salesforce.
* I created a CRON job on my Linux box set to run the shell script every minute. This would consume 1440 API calls a day as a result but I thought I could fine tune the frequency of the script later to suit my needs. Increasing the real time nature increases cost of API calls and vice versa, I can decrease cost by loosening my requirements. This was the automated part of the solution.
* The shell script data flow was simple: log in using OAuth and curl, query to get a count of an sObject, and parse the result. If the result has a number, consider it a success, otherwise consider it a failure and log the error.
* I used a free data publishing service from data.sparkfun.com. Originally created for publicly accessible IoT (Internet of Things) apps like weather device data, it made it trivial to expose the data I needed in a simple Rest API. In the next iteration, I would use keen.io which has more functionality and freemium options but involved more design than necessary wiring up my first iteration. You can check out my live [heartbeat monitor](http://bit.ly/rtheartbeat).
* I created a google charting API report to visualize the data. This was the visualization part of the solution and entirely based on a [phant.io blog posting](http://phant.io/graphing/google/2014/07/07/graphing-data/).
* I used a freemium SMS service called SendHub to handle the notifications. I originally used Twilio but needed a simpler, freemium option for the first iteration.

![alt tag] (https://raw.githubusercontent.com/atorman/heartbeatMonitor/master/DIYArchitecture.png)

Every minute, the CRON job would wake the bash shell script. The script would log into salesforce using the rest API, query a count of my new sobject, and if successful it would log a row to sparkfun which I viewed on their public page. If it failed, I would log another row to sparkfun with the error message. I then sent a SMS notification of the failure to my cell phone. To view a trend of successes and failures over time (which was useful to see what happened when I was away from my phone or asleep), I used my Google charting report.

This DIY project highlights a simple case of real-time monitoring built very quickly and open to enhancements. 

##Installation

1. download the zip of this repo
2. change the <changeme> in the beginning of the heartbeat.sh file
3. copy the heartbeat.sh file into the `/bin` directory of your linux box (this isn't a hard requirement, but it saves you having to use the `./` syntax to execute the bash)
4. edit your CRONTAB file 
`sudo CRONTAB -e`
and add the following line (change user home directory to store the log results which you'll want to clean out from time to time)
```
* * * * * /bin/bash /bin/Heartbeat.sh >> /home/<changeme>/Desktop/HeartbeatLog.log 2>&1
```
5. copy the heartbeat.html file onto your desktop or in a hosted web server

##Setup and Configuration

1. Sign up for a [sparkfun endpoint](https://data.sparkfun.com/streams/make)
2. Sign up for [sendhub](https://www.sendhub.com/signup/)
3. Change the <changeme> in the beginning of the heartbeat.sh file (you will need to sign up for sendhub and configure a salesforce [connected app](https://help.salesforce.com/HTViewHelpDoc?id=connected_app_create.htm&language=en_US)):
```
username=${username:-<changeme>} #username: e.g. user@company.com
password=${password:-<changeme>} #password e.g. password
instance=${instance:-<changeme>} #pod instance - production/sandbox/other
clientid=${clientid:-<changeme>} #salesforce connected app client id
clientsecret=${clientsecret:-<changeme>} #salesforce connected app client secret
version=${version:-<changeme>} #salesforce API version: e.g. 31.0
sobject=${sobject:-<changeme>} #salesforce sobject to query: e.g. LoginEvent
sparkfunid=${sparkfunid:-<changeme>} #sparkfun public key id
sparkfunkey=${sparkfunkey:-<changeme>} #sparkfun private key id
sendhubid=${sendhubid:-<changeme>} #sendhub contactid [required]
sendhubkey=${sendhubkey:-<changeme>} #sendhub API key
sendhubuser=${sendhubuser:-<changeme>} #sendhub username i.e. phone number
```
4. Put the heartbeat.sh into test mode:
```
testMode=${testMode:-true} #use to test 
```
5. Test heartbeat.sh locally using the terminal
```
cd /bin
chmod +x heartbeat.sh
heartbeat.sh
```
6. You may need to change around the queries to try different failure scenarios out. But the result should log to sparkfun.com

##Alternative Configuration for using keen.io and twillio.com instead of sparkfun.com and sendhub.com

Keen.io and Twilio.com have more options and security than sparkfun and sendhub. I purposefully only added them in during a second iteration of the solution. While I like them a great deal, they also added a bit more complexity to the script in terms of what had to be configured and how I had to construct the JSON.

1. Add the following configurations to heartbeat to try twilio.com and keen.io instead:
```
twilioid=${twilioid:-<changeme>} #twilio id: e.g. BC60bc8cda88713a766470fbac7b5abd4b
twilioTo=${twilioTo:-<changeme>} #twilio to sms phone number: e.g. 9253801101
twilioFrom=${twillioFrom:-<changeme>} #twilio from sms phone number: e.g. 19253819221
twiliotoken=${twiliotoken:-<changeme>} #twilio authorization token: e.g. CC60bc2eda58703e766470fdac7e5abd8b:42f9823d3g0532dc99b47x159859bdk8
keenproject=${keenproject:-<changeme>} #keen.io project id: e.g. 63ed34a4e87596182f030301
keencollection=${keencollection:-<changeme>} #keen.io collection: e.g. heartbeatProduction
keenkey=${keenkey:-<changeme>} #keen.io write API key: e.g. 26232f8eac452ece71a20b5d0658fe5925a2d80fba2370e53fb1dc8ed2d50c9117e4fc815e54e69bde345102db40801cbeb62a3f8179053863a3fe443f302519fb58440f0c41183bbbeac983b6b7fc2aacdcf12c51db6451568d87a0f2acc5ffdf61529ad8eba7e62e7f023d2c258d64
```
2. Add the following lines throughout the shell script where you want to send information to keen.io and twilio.com
```
#Insert success data into keen.io
curl -X POST "https://api.keen.io/3.0/projects/${keenproject}/events/${keencollection}?api_key=${keenkey}" -H "Content-Type: application/json" -d '{"count":'${newCount}',"errMsg":"null","success":1}'
#Insert error data into keen.io
curl -X POST "https://api.keen.io/3.0/projects/${keenproject}/events/${keencollection}?api_key=${keenkey}" -H "Content-Type: application/json" -d '{"count":"null","errMsg": "gack","success":0}'
#SMS error notification using Twilio - http://www.twilio.com/sms/api
curl -X POST "https://api.twilio.com/2010-04-01/Accounts/${twilioid}/Messages.json" \
--data-urlencode "To=${twilioTo}"  \
--data-urlencode "From=+${twilioFrom}"  \
--data-urlencode "Body=${sobjec} Query Failure: ${errMsg}" \
-u ${twiliotoken}
#Insert error data into keen.io
curl -X POST "https://api.keen.io/3.0/projects/${keenproject}/events/${keencollection}?api_key=${keenkey}" -H "Content-Type: application/json" -d '{"count":"null","errMsg":"accessTokenFailure","success":0}'
```

##Future Enhancements
I wrote this as a bash shell script knowing that my first audience for this solution are system administrators who know bash. 

In another iteration, I would build this using python for more OS independence and leverage a library such as [python-crontab](https://pypi.python.org/pypi/python-crontab) to handle the automation.

I would also host this service as well as the heartbeat.html on Heroku or AWS to reduce the need for on-premise hardware such as a linux box.