module SimpleApi
class SinatraApp < Sinatra::Base
  use ActiveRecord::ConnectionAdapters::ConnectionManagement

  helpers Sinatra::JSON   
  
  # ---------------------------------------------------------------------
  # Sinatra configuration

  # The json library of the sinatra-contrib gem has a bug that
  # dumps `nil` as the string "nil".
  # However, this is wrong, and the correct string in javascript should be "null".
  # Replace sinatra-contrib's default encoder simply with the method `to_json`
  #
  set :json_encoder, RestCore::Json
  
  # Standard Sinatra configurations
  configure :development, :test do 
    enable :logging
    enable :dump_errors
    disable :show_exceptions  # Sends back exceptions as HTML
  end

  # --------------------------------------------------------------------
  # Rails-Sinatra interaction

  # Setup the logger to be the same as Rails
  def logger 
    Rails.logger
  end

  # Need to use Rails' params because ActiveRecord requires "strong parameters"
  def params
    @params ||= ActionController::Parameters.new(super)
  end

  # Helper that returns the current request's url corresponding to it's
  # Rails ApplicationController counterpart.
  def current_request_url
    request.url
  end

  # --------------------------------------------------------------------
  # Canned responses

  # Use when we have nothing to send back but we want to reply with valid JSON
  # (just in case client is stupid enough to try to parse it). The actual value
  # returned is *irrelevant*, it should just parse reasonably into JSON.
  # We copy what Facebook does and send 'true'.
  #
  def json_ok
    json(true)
  end

  # --------------------------------------------------------------------
  # Current utilities
  
  protected
  # ------------------------------------------------------------------------
  # Common path fragments

  REGEXP_USERS_WITH_ID = %r{(/users/(?<user_id>\d+|me))}

  # ------------------------------------------------------------------------
  # Error handling

  error RT::Errors::UnauthorizedError do
    body error_json(env['sinatra.error'])
    status 401
  end
  error RT::Errors::ForbiddenError do
    body error_json(env['sinatra.error'])
    status 403
  end
  error RT::Errors::ObjectNotFoundError, ActiveRecord::RecordNotFound do
    body error_json(env['sinatra.error'])
    status 404
  end
  error RT::Errors::InvalidRequestParameters do
    body error_json(env['sinatra.error'])
    status 400
  end
  
  # Default error handler, catches all errors
  error do
    error = env['sinatra.error']
    logger.error "Exception #{error.inspect}:\n#{error.backtrace.join("\n")}"
    error_json(error)
  end

  def error_json err_or_message, params={}
    jsonable = if err_or_message.is_a? Exception
                 { name: err_or_message.class.name, message: err_or_message.message }
               else
                 { message: err_or_message }
               end
    json(error: jsonable.merge(params))
  end

end
end
