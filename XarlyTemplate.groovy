package utilities
import java.net.InetAddress

/* This file contains the definitions of the templates used in the rest of job DSL configuration:
    JobDslTemplates.coreRunDate: sets the parameter RUN_DATE to @today, @yesterday or the date the string is set to
    xarlyAuthToken
    xarlyParameter: single choice parameter
    xarlyTextParameter: single text parameter
    xarlyStringParameter: single text parameter
    xarlyDynamicTextParameter: scripted dynamic text parameter
    xarlyLogRotator: policy for logs
    xarlyAbortIfStuck: timeout policy
    xarlyEnableTimestamps: xarly timestamps to the Console Output
    xarlyEmailNotifications: send e-mail to given xarlyresses
    xarlyRetry: retry policy (retry limit and inactive time between retries)
    xarlyTriggeredJob: name and properties for downstream jobs
    xarlyDownstreamJob: Triggers a downstream once it success with the provided properties.
    xarlySVNUpdate: update the code with the source code in SVN.
    xarlyPreBuildCleanup: cleaning up the space before the build
    xarlyThrottleConcurrentBuilds: limit the number of concurrent builds
    xarlyJobDescription: description of the job
    xarlyZabbixAlarms: configure Zabbix alarms
    xarlyHipChatNotifierJobProperty: configure HipChat notifications
    xarlyTimeOut: configure timeouts for Elastic and Absolute timeout strategies
    xarlyExecRemoteSSH: Execute ssh commands on a remote machine
    xarlyIfEnvironment: if environment is not the "env"
    xarlyIsEnvironment: boolean for environment is not the "env", returns false
    xarlyDisableDevOnly: if environment is dev, disables the job
    xarlyDisableIncognitoProdOnly: if environment is incognito-prod, disables the job
    xarlyEnableProdOnly: if environment is not prod, disables the job
    xarlyEnvironment: returns environment based on the ENV variable of Jenkins
    xarlyDefaultSettings: xarlying default settings for a job, depending on specified config
*/

class JobDslTemplates {
    // -=   xarlyParameter  =-
    // Adds a single input choice parameter to the job
    // It needs the following parameters:
    // * job: Job object to be modified
    // * parameterName: Name of the input choice parameter
    // * parameterOptions: List of options to choose. Format like: ['TRUE', 'FALSE']
    // * parameterDescription (optional): Description of the parameter. Null by default.






    static void xarlyRunDate(def job, String whichDay, String paramName = 'RUN_DATE') {
        job.with {
          configure { project ->
              def properties = project / 'properties'
              def parameters = properties / 'hudson.model.ParametersDefinitionProperty'
              def parameterDefinations = parameters / 'parameterDefinitions'
              parameterDefinations << 'com.seitenbau.jenkins.plugins.dynamicparameter.StringParameterDefinition' {
                  name(paramName)
                  description('Run date for the script. Typically is yestarday.')
                  String run_date
                  if (whichDay == 'yesterday') {
                    run_date = '''def today = new Date()
def yesterday = today - 1
println yesterday.format("yyyy-MM-dd")
yesterday.format("yyyy-MM-dd")'''
                  }
                  else if (whichDay == 'today') {
                    run_date = '''def today = new Date()
println today.format("yyyy-MM-dd")
today.format("yyyy-MM-dd")'''
                  }
                  else if (whichDay == 'previousMonth') {
                    run_date = '''d = new GregorianCalendar()
d.setTime(new Date())
d.add(Calendar.MONTH,-1)
d.getTime().format("yyyy-MM-dd")'''
                  }
                  else if (whichDay == 'firstMonth') {
                    run_date = '''Calendar c = Calendar.getInstance();   // this takes current date
                    c.set(Calendar.DAY_OF_MONTH, 1);
                    c.getTime().format("yyyy-MM-dd")'''
                  }
                  else {
                    run_date = whichDay
                  }

                  __script run_date.stripIndent().trim()
                  __remote(false)
                  '__localBaseDirectory'(serialization: 'custom') << 'hudson.FilePath' {
                      'default' {
                          remote('/var/lib/jenkins/dynamic_parameter/classpath')
                      }
                      delegate.boolean(true)
                  }
                  __classPath()
              }
          }
        }
    }



    static void xarlyAuthToken(def job, String token) {
        job.with {
            configure { project ->
                (project / 'authToken').setValue(token)
            }
        }
    }

    static void xarlyChoiceParameter(def job, String parameterName, List<String> parameterOptions, String parameterDescription = '') {
        job.with {
            parameters {
                choiceParam(parameterName, parameterOptions, parameterDescription)
            }
        }
    }
    // -=   xarlyTextParameter  =-
    // Adds a single input text parameter to the job
    // It needs the following parameters:
    // * job: Job object to be modified
    // * parameterDefault: Default value of the input text parameter
    // * parameterDescription (optional): Description of the parameter. Null by default.
    static void xarlyTextParameter(def job, String parameterName, String parameterDefault, String parameterDescription = '') {
        job.with {
            parameters {
                textParam(parameterName, parameterDefault, parameterDescription)
            }
        }
    }

    //stringParam(String parameterName, String defaultValue = null, String description = null)
    static void xarlyStringParameter(def job, String parameterName, String parameterDefault, String parameterDescription = '') {
        job.with {
            parameters {
                stringParam(parameterName, parameterDefault, parameterDescription)
            }
        }
    }


    // BUG 1 Unable to use the function xarlyDynamicTextParameter, hence reused the code directly on the template. TODO.
    // -=   xarlyDynamicTextParameter  =-
    // Adds an scripted dynamic text parameter to the job
    // It needs the following parameters:
    // * job: Job object to be modified
    // * parameterScript: Script to calculate the dynamic parameter
    // * parameterDescription (optional): Description of the parameter. Null by default.
    static void xarlyDynamicTextParameter(def job, String parameterName, String parameterScript, String parameterDescription = '') {
        job.with {

            configure { project ->
                def parameters = properties / 'hudson.model.ParametersDefinitionProperty' / 'parameterDefinitions'
                parameters << 'com.seitenbau.jenkins.plugins.dynamicparameter.StringParameterDefinition'(plugin: 'dynamicparameter@0.2.0') {
                    name(parameterName)
                    description(parameterDescription)
                    __script parameterScript.stripIndent().trim()
                    __remote(false)
                    '__localBaseDirectory'(serialization: 'custom') << 'hudson.FilePath' {
                        'default' {
                            remote('/var/lib/jenkins/dynamic_parameter/classpath')
                        }
                        delegate.boolean(true)
                    }
                    __classPath()
                }

            }
        }
    }

    // -=   xarlyLogRotator  =-
    // Sets on a given job the default policy for jobs logs
    static void xarlyLogRotator(def job, int buildsToKeep) {
        job.with {
            logRotator(-1, buildsToKeep, -1, -1)
        }
    }

    // -=   xarlyAbortIfStuck  =-
    // Sets on a given job the timeout policy.
    static void xarlyAbortIfStuck(def job, int timeoutMinutes) {
        xarlyTimeOut(job, 'Absolute',timeoutMinutes)
    }

    // -=   xarlyTimeOut  =-
    // Sets on a given job the timeout policy. Strategy can be defined as Absolute or Elastic
    static void xarlyTimeOut(def job, String strategy, int minutesDefault, int numberOfBuilds, int percentage) {
        if(strategy != 'Elastic') {
            throw new Exception("Expecting (def job, Elastic, int minutesDefault, int numberOfBuilds, int percentage)")
        }


            xarlyTimeOut(job, 'Absolute', minutesDefault)
    }

    static void xarlyTimeOut(def job, String strategy, int timeoutMinutes) {
        if(strategy != 'Absolute') {
            throw new Exception("Expecting (def job, Absolute, int timeoutMinutes)")
        }
        job.with {
            wrappers {
                // Abort the build if it's stuck
                timeout {
                    absolute(timeoutMinutes)
                    failBuild()
                }
            }
        }
    }

    // -=   xarlyEnableTimestamps    =-
    // Add timestamps to the Console Output
    static void xarlyEnableTimestamps(def job){
        job.with {
            wrappers {
                timestamps()
            }

        }
    }

    // -=   xarlyEmailNotifications    =-
    // Sends an e-mail to given xarlyress including for unstable builds.
    static void xarlyEmailNotifications(def job,String email){
        job.with{
            publishers {
                //mailer(String recipients, Boolean dontNotifyEveryUnstableBuild = false, Boolean sendToIndividuals = false)
                mailer(email, false, false)
            }
        }
    }

    // -=   xarlyRetry    =-
    //  Set ups the retry policy, you can configure the retry limit and the delay between them
    static void xarlyRetry(def job, int delaySeconds, int retries, boolean runMatrix = false, boolean ifUnstable = false){
        job.with{
          /*  publishers {
                retryBuild {
                    retryLimit(retries)
                    fixedDelay(delaySeconds)
                    //rerunMatrixPart(runMatrix)
                    //rerunMatrixPart()
                }
            }*/
            configure { project ->
                def properties = project / 'publishers'
             //   def parameters = properties / 'hudson.model.ParametersDefinitionProperty'
             //   def parameterDefinations = parameters / 'publishers'
                properties << 'com.chikli.hudson.plugin.naginator.NaginatorPublisher' {
                    regexpForRerun()
                    rerunIfUnstable(ifUnstable)     // Rerun build for unstable builds as well as failures
                    rerunMatrixPart(runMatrix)      // Rerun build only for failed parts on the matrix
                    checkRegexp(false)
                    'delay'(class: 'com.chikli.hudson.plugin.naginator.FixedDelay')  {
                        delay(delaySeconds)
                    }
                    maxSchedule(retries)
                }
            }
        }
    }


    // -=   xarlyTriggeredJob    =-
    // Triggers a job with the provided properties.
    // * job: Job object to be modified
    // * triggeredjob: Name of the triggered job
    // * triggeredjobprops: Properties to be sent as parameters to the triggered job. Example: [MODULE: 'hive-bootstrap']
    // As we have a single use case for this feature, we have just hardcoded the "block until triggered projects finish their builds"
    static void xarlyTriggeredJob(def job, String triggeredjob, Map<String, String> triggeredjobprops) {
        job.with{
            steps {
                downstreamParameterized {
                    trigger(triggeredjob) {
                        block {
                            buildStepFailure('FAILURE')
                            failure('FAILURE')
                            unstable('UNSTABLE')
                        }
                        parameters {
                            predefinedProps(triggeredjobprops)
                        }
                    }
                }
            }
        }
    }

    // -=   xarlyTriggeredJob    =-
    // Triggers a job propagating the current parameters.
    // * job: Job object to be modified
    // * triggeredjob: Name of the triggered job
    static void xarlyTriggeredJob(def job, String triggeredjob, String parentStatus = 'SUCCESS') {
        job.with{
            steps {
                downstreamParameterized {
                    trigger(triggeredjob) {
                        parameters {
                            currentBuild()
                        }
                    }
                }
            }
        }
    }


    // -=   xarlyDownstreamJob    =-
    // Triggers a downstream once it success with the provided properties.
    // * job: Job object to be modified
    // * triggeredjob: Name of the triggered job
    // * triggeredjobprops: Properties to be sent as parameters to the triggered job. Example: [MODULE: 'hive-bootstrap']
    static void xarlyDownstreamJob(def job, String triggeredjob, Map<String, String> triggeredjobprops) {
        job.with{
            publishers {
                downstreamParameterized {
                    trigger(triggeredjob) {
                        condition('SUCCESS')
                        parameters {
                            predefinedProps(triggeredjobprops)
                        }
                    }
                }
            }
        }
    }

    // -=   xarlyDownstreamJob    =-
    // Triggers a downstream once it success, propagating the current parameters.
    // * job: Job object to be modified
    // * triggeredjob: Name of the triggered job

    static void xarlyDownstreamJob(def job, String triggeredjob, String parentStatus = 'SUCCESS', boolean istriggerWithNoParameters = false) {
        job.with{
            publishers {
                downstreamParameterized {
                    trigger(triggeredjob) {
                        condition(parentStatus)
                        if (istriggerWithNoParameters) {
                          triggerWithNoParameters(istriggerWithNoParameters)
                        }
                        else {
                          parameters {
                              currentBuild()
                          }
                       }
                    }
                }
            }
        }
    }
    // -= xarlyPreBuildCleanup =-
    // Cleaning up the space before the build
    static void xarlyPreBuildCleanup (def job){
        job.with{
            wrappers {
                // Delete workspace before build starts
                preBuildCleanup()
            }
        }
    }

    // -= xarlyThrottleConcurrentBuilds =-
    // Limits the number of concurrent builds
    static void xarlyThrottleConcurrentBuilds (def job, int num=1){
        job.with{
            throttleConcurrentBuilds {
                maxPerNode(num)
            }
        }
    }

    // -= xarlyJobDescription =-
    // Adds a description to the job.
    static void xarlyJobDescription (def job, String jobDescription='Not provided'){
        String text=''' The purpose of this job is ''' + jobDescription +

        job.with{
            description text.stripIndent().trim()
        }
    }



    // -= xarlyExecRemoteSSH =-
    // Execute some ssh commands on a remote machine
    static void xarlyExecRemoteSSH (def job, String machine, String command){

            job.with {
                steps {
                    publishOverSsh {
                        server(machine) {
                            transferSet {
                                sourceFiles('')
                                makeEmptyDirs(false)
                                patternSeparator('[, ]+')
                                execCommand(command)

                            }
                        }
                    }
                }
            }
    }


    // -= xarlyDefaultSettings =-
    // xarlying default xarlytings for a job. Available configurations are the following:
    // "Standard":
    //    * Create the parameters BUILD_DOWNSTREAM_PROJECTS and DEPLOY_PRODUCTION
    //    * Adding timeouts to the job
    //    * Enabling the timestamped log
    //    * Setting up retry intervals
    //    * Setting up e-mail notifications
    //    * xarlying log purge policy

    static void xarlyDefaultSettings(def job, def jobtype, def nodelabel, String shouldRetry = 'RETRY', boolean zabbixAlarm = false, int retrytime = 600, int retryattempts = 2, String notificationAddress = '$DWH_ALERTS_EMAIL', boolean hipChatNotifier = false, String hipChatChannel = 'Team/ DA xarly Products - Internal', boolean hipChatNotifierProd = false) {


        xarlyEnableTimestamps(job)
        xarlyEmailNotifications(job, notificationAddress)
        xarlyLogRotator(job, 15)
        xarlyPreBuildCleanup(job)


        job.with {
            label(nodelabel)
        }


        if (shouldRetry == 'RETRY UNSTABLE') { // We should move all the retry blocks here
               JobDslTemplates.xarlyRetry(job, retrytime,retryattempts, false,true)
        }


        if (jobtype=='ETL') {


            xarlyAbortIfStuck(job,150)


            if (shouldRetry == 'RETRY') {
                xarlyRetry(job, retrytime, retryattempts, true)
            }
            //BUG 1 Unable to use the function xarlyDynamicTextParameter, hence hardcoded below. TODO.
            JobDslTemplates.xarlyRunDate(job, 'yesterday')
            job.with {
                throttleConcurrentBuilds {
                    maxTotal(1)
                    maxPerNode(0)
                }
            }
        }
        xarlyChoiceParameter(job,'BUILD_DOWNSTREAM_PROJECTS', ['TRUE', 'FALSE'],'This flags determines if we will be running downstream.')
    }
}
