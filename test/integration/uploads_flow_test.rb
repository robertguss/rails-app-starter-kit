require "test_helper"

class UploadsFlowTest < ActionDispatch::IntegrationTest
  setup do
    [ AuditEvent, PasswordRecovery, Invitation, Session, Identity, AccessGrant, User ].each(&:delete_all)
    @owner = create_user("owner@example.test", role: :owner)
    post login_path, params: { email_address: @owner.email_address, password: "long-password" }
  end

  test "upload download ownership and deletion use the configured storage service" do
    file = fixture_file_upload("example.txt", "text/plain")
    post uploads_path, params: { file: }

    assert_response :created
    attachment_id = response.parsed_body.fetch("id")
    assert_equal "text/plain", response.parsed_body.fetch("content_type")

    get upload_path(attachment_id)
    assert_response :success
    assert_equal "Rails starter upload fixture.\n", response.body
    assert_match "attachment", response.headers.fetch("content-disposition")

    member = create_user("member@example.test")
    other_browser = open_session
    other_browser.post login_path, params: { email_address: member.email_address, password: "long-password" }
    other_browser.get upload_path(attachment_id)
    assert_equal 404, other_browser.response.status

    blob_id = ActiveStorage::Attachment.find(attachment_id).blob_id
    delete upload_path(attachment_id)
    assert_response :no_content
    assert_not ActiveStorage::Attachment.exists?(attachment_id)
    assert_not ActiveStorage::Blob.exists?(blob_id)
  end

  private
    def create_user(email, role: :member)
      user = User.create!(email_address: email, name: "Test", password: "long-password", role:)
      AccessGrant.create!(normalized_email: email, granted_by: @owner || user, granted_at: Time.current, claimed_by: user, claimed_at: Time.current)
      user
    end
end
