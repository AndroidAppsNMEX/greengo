String viewdescription = '''
'''

buildPipelineView('GreenGo - BigQuery - PoC') {
    description(viewdescription)
    selectedJob('auto-xarly-greengo-bq-start')
    displayedBuilds(5)
    triggerOnlyLatestJob(false) // Use this method if you want to show the pipeline definition header in the pipeline view.
    alwaysAllowManualTrigger(true) // Use this method if you want to be able to execute a successful pipeline step again.
    startsWithParameters(false)
    showPipelineDefinitionHeader(false)
    showPipelineParametersInHeaders(true)
    showPipelineParameters(true)
    refreshFrequency(30)
    //customCssUrl(String customCssUrl)
    consoleOutputLinkStyle(OutputStyle.Lightbox)
  }
