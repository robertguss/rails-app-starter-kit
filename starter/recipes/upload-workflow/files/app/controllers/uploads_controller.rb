# frozen_string_literal: true

class UploadsController < ApplicationController
  MAXIMUM_BYTES = 10.megabytes
  CONTENT_TYPES = %w[application/pdf image/gif image/jpeg image/png image/webp text/plain].freeze

  def create
    uploaded_file = params.require(:file)
    return head :content_too_large if uploaded_file.size > MAXIMUM_BYTES

    Current.user.uploads.attach(uploaded_file)
    attachment = Current.user.uploads.attachments.order(:id).last
    detected_type = attachment.blob.open do |file|
      Marcel::MimeType.for(file, name: attachment.filename.to_s)
    end
    unless CONTENT_TYPES.include?(detected_type)
      attachment.purge
      return render json: { error: "unsupported file type" }, status: :unprocessable_content
    end

    attachment.blob.update!(content_type: detected_type, identified: true)
    AuditEvent.record!(actor: Current.user, action: "upload.created", subject: attachment)
    render json: { id: attachment.id, filename: attachment.filename.to_s, content_type: detected_type }, status: :created
  end

  def show
    attachment = current_attachment
    send_data attachment.download,
      filename: attachment.filename.to_s,
      type: attachment.content_type,
      disposition: :attachment
  end

  def destroy
    attachment = current_attachment
    AuditEvent.record!(actor: Current.user, action: "upload.deleted", subject: attachment)
    attachment.purge
    head :no_content
  end

  private
    def current_attachment
      Current.user.uploads.attachments.includes(:blob).find(params[:id])
    end
end
