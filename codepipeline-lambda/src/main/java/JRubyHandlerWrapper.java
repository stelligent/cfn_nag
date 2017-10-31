import java.util.Map;

import org.jruby.Ruby;
import org.jruby.embed.PathType;
import org.jruby.embed.ScriptingContainer;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class JRubyHandlerWrapper implements RequestHandler<Map<String, Object>, Object> {

  static {
    Ruby.newInstance();
  }

  @Override
  public Object handleRequest(Map<String, Object> lambdaInputMap, Context lambdaContext) {

    ScriptingContainer jrubyScriptingContainer = new ScriptingContainer();
    jrubyScriptingContainer.put("$lambdaInputMap", lambdaInputMap);
    jrubyScriptingContainer.put("$lambdaLogger", lambdaContext.getLogger());
    jrubyScriptingContainer.put("$lambdaContext", lambdaContext);

    // uploaded zip is extracted to /var/task directory
    jrubyScriptingContainer.setCurrentDirectory("/var/task");

    return jrubyScriptingContainer.runScriptlet(PathType.CLASSPATH,
                                                rubyFileName);
  }

  private static final String rubyFileName = "code_pipeline_handler.rb";
}
