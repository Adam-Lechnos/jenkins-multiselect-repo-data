#!/bin/bash

# add token here
authToken=
repoName=$1
repoRelease=$2
repoNameTrim=`echo $repoName | cut -d':' -f2 | cut -d'/' -f2 | sed 's/.git//g'`
repoOwner=`echo $repoName | cut -d':' -f2 | cut -d'/' -f1`

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
loglist=$(ls -l /var/lib/jenkins/git/cloud-market-data/jenkins_tools/multiselect_json_create/logs/ | grep .log | awk '{print $9}' | wc -l)

if [ ! -d /var/lib/jenkins/git/cloud-market-data/jenkins_tools/multiselect_json_create/logs ]; then
  mkdir /var/lib/jenkins/git/cloud-market-data/jenkins_tools/multiselect_json_create/logs
fi

if [ $loglist -gt $logretention ]
then

 delcount=`expr $loglist - $logretention`
 find /var/lib/jenkins/git/cloud-market-data/jenkins_tools/multiselect_json_create/logs/ -type f -printf '%T+ %p\n' | sort | head -n $delcount | awk '{print $2}' | sed 's/[^\]*logs[^\]//' | xargs -I {} rm /var/lib/jenkins/git/cloud-market-data/jenkins_tools/multiselect_json_create/logs/{}

fi


curl \
-s -H "Authorization: bearer $authToken" \
-X POST -d "{ \"query\": \"$payloadFrmt\"}" https://api.github.factset.com/graphql \
| jq -r -e '.data.repository.object.entries[].object.entries|.[]?|.object.entries|.[]?|.name'

exitStatus=$?

if [ $exitStatus -ne 0 ] 
then
 
 timestamp=$(date +"%FT%H%M%S")

 curl -s -I \
 -H "Authorization: bearer $authToken" \
 https://api.github.factset.com/graphql > /var/lib/jenkins/git/cloud-market-data/jenkins_tools/multiselect_json_create/logs/cURLheader_$timestamp.log

else

 exit 0

fi

