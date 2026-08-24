require "test_helper"

class FoundationFlowTest < ActionDispatch::IntegrationTest
  test "renders the foundation through Inertia" do
    get root_path

    assert_response :success
    assert_inertia_response
    assert_inertia_component "home/show"
    assert_inertia_props versions: {
      rails: Rails.version,
      ruby: RUBY_VERSION,
      inertia: InertiaRails::VERSION
    }
  end

  test "returns Rails validation errors through an Inertia redirect" do
    post round_trip_messages_path, params: { round_trip_message: { message: "" } }

    assert_redirected_to root_path
    follow_redirect!
    assert_inertia_component "home/show"
    assert_equal [ "can't be blank" ], inertia.props.dig(:errors, :message)
  end

  test "returns a success flash after a valid Inertia form submission" do
    post round_trip_messages_path, params: { round_trip_message: { message: "Hello foundation" } }

    assert_redirected_to root_path
    follow_redirect!
    assert_inertia_component "home/show"
    assert_inertia_props flash: { notice: "Rails received “Hello foundation” through Inertia." }
  end

  test "navigates to representative states" do
    get "/states/empty"

    assert_response :success
    assert_inertia_component "states/empty"

    get "/states/loading"

    assert_response :success
    assert_inertia_component "states/loading"
  end

  test "renders unknown paths as Inertia 404 pages" do
    get "/not-a-real-page"

    assert_response :not_found
    assert_inertia_component "errors/not_found"
  end

  test "renders application failures as Inertia 500 pages" do
    post "/500"

    assert_response :internal_server_error
    assert_inertia_component "errors/internal_server_error"
  end

  test "reports application and PostgreSQL health" do
    get "/health"

    assert_response :success
    assert_inertia_component "health/show"
    assert_inertia_props status: "ok", checks: { application: "ok", database: "ok" }

    get rails_health_check_path
    assert_response :success

    get "/ready"
    assert_response :success
    assert_equal({ "status" => "ready", "checks" => { "database" => "ready" } }, response.parsed_body)
  end

  test "assigns and returns a request correlation identifier" do
    get root_path, headers: { "X-Request-ID" => "request-123" }

    assert_response :success
    assert_equal "request-123", response.headers["X-Request-ID"]
  end
end
