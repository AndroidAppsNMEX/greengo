
import utilities.JobDslTemplates

def job_definition = job('auto-xarly-greengo-bq-start') {
     triggers {

        cron('0 5 * * 1')
    }
}
JobDslTemplates.xarlyDefaultSettings(job_definition, jobtype = "ETL", shouldRetry = 'RETRY UNSTABLE')
JobDslTemplates.xarlyRunDate(job_definition,'''def today = new Date()
def day_of_week =  today.format("u")
def last_sun = today - day_of_week.toInteger() -28
last_sun.format("yyyy-MM-dd")''','RUN_SUNDAY')
