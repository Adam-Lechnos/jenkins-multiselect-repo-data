# jenkins-multiselect-repo-data
Pull latest list files from a designated directory within a repo as a checklist within Jenkins as part of a dynamic dropdown list.

#### Intended Audience
* Devops

#### Pre-requisites
* GitHub repos containing a dedicated directroy for parsing into a list
* GitHub Access Token
* Variable substitution which provides a repo name and release tag using [semantic versioning](https://semver.org/)

#### Usage
* Edit the script to include an `auth.cfg` for referencing a GitHub token assigned to the `gitauthtoken` variable. 
* The 'auth.cfg' file should be part of the `.gitignore` config.
* Edit the `logDir` varialbe to include the persistent directory structure in which data parsing against supplied repos should occur
  * i.e., `logDir=/foo/bar/`
* Execute the script as part of the Jenkins Multiselect function:
  * Supply two positional arguments to the script, *repository name* as the full git ssh address, and the *repository release tag*
  * i.e., `multi_selector_json.sh git@github.com:Adam-Lechnos/Binary-Init-Client.git v.0.0.1`

#### Example
* Parse list of files from the FooBar repo's directory release v1.1.2
  * `multi_selector_json.sh git@github.com:Adam-Lechnos/FooBart.git v0.0.1`

#### Active Choices Reactive Parameter
```
def proc = "/bin/bash /var/lib/jenkins/multiselect_json_create/multi_selector_json.sh ${git_repo_url} ${git_release}".execute()
proc.waitFor()
def output = proc.in.text
def exitcode = proc.exitValue()
def error = proc.err.text
return output.tokenize()
```
