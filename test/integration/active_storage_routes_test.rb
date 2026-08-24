# frozen_string_literal: true

require "test_helper"

class ActiveStorageRoutesTest < ActionDispatch::IntegrationTest
  test "the application catch-all does not intercept signed blob routes" do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("export contents"),
      filename: "export.txt",
      content_type: "text/plain"
    )

    get rails_blob_path(blob, disposition: "attachment")

    assert_response :redirect
    assert response.location.start_with?("http://www.example.com#{ActiveStorage.routes_prefix}/disk/")
  end
end
