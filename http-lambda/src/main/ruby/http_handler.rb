$lambdaLogger.log "LOAD_PATH: #{$LOAD_PATH}"
$LOAD_PATH << 'uri:classloader:/'

$lambdaLogger.log "lambda inputs #{$lambdaInputMap}"

require 'api_gateway_invoker'

ApiGatewayInvoker.new.audit
