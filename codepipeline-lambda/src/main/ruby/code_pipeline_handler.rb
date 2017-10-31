$lambdaLogger.log "LOAD_PATH: #{$LOAD_PATH}"
$LOAD_PATH << 'uri:classloader:/'

$lambdaLogger.log "lambda inputs #{$lambdaInputMap}"

require 'code_pipeline_invoker'

CodePipelineInvoker.new.audit

'Complete.'
