class RequestContext
  def initialize(app)
    @app = app
  end

  def call(request_environment)
    request = ActionDispatch::Request.new(request_environment)
    Current.request_id = request.request_id
    @app.call(request_environment)
  ensure
    Current.reset
  end
end
