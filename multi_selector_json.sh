#!/bin/bash

source 'add auth.cfg file here'

# add token here
authToken=$gitauthtoken
repoName=$1
repoRelease=$2
repoNameTrim=`echo $repoName | cut -d':' -f2 | cut -d'/' -f2 | sed 's/.git//g'`
repoOwner=`echo $repoName | cut -d':' -f2 | cut -d'/' -f1`
logDir='add log directory here'

payload='query RepoFiles{
repository(owner: \"'$repoOwner'\", name: \"'$repoNameTrim'\") {
 object(expression: \"'$repoRelease':\") {
   ... on Tree {
     entries {
       name
       type
       object {
         ... on Blob {
           byteSize
           }

            ... on Tree {
              entries {
                name
                type
                object {
                  ... on Blob {
                    byteSize
                    }
                  
                     ... on Tree {
                       entries {
                         name
                         type
                         object {
                           ... on Blob {
                             byteSize
                        }      
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}'


payloadFrmt="$(echo $payload)"


logretention=20
loglist=$(ls -l $logDir/multiselect_json_create/logs/ | grep .log | awk '{print $9}' | wc -l)

if [ ! -d $logDir/multiselect_json_create/logs ]; then
  mkdir $logDir/multiselect_json_create/logs
fi

if [ $loglist -gt $logretention ]
then

 delcount=`expr $loglist - $logretention`
 find $logDir/multiselect_json_create/logs/ -type f -printf '%T+ %p\n' | sort | head -n $delcount | awk '{print $2}' | sed 's/[^\]*logs[^\]//' | xargs -I {} rm $logDir/multiselect_json_create/logs/{}

fi


curl \
-s -H "Authorization: bearer $authToken" \
-X POST -d "{ \"query\": \"$payloadFrmt\"}" https://api.github.com/graphql \
| jq -r -e '.data.repository.object.entries[].object.entries|.[]?|.object.entries|.[]?|.name'

exitStatus=$?

if [ $exitStatus -ne 0 ] 
then
 
 timestamp=$(date +"%FT%H%M%S")

 curl -s -I \
 -H "Authorization: bearer $authToken" \
 https://api.github.factset.com/graphql > $logDir/multiselect_json_create/logs/cURLheader_$timestamp.log

else

 exit 0

fi

