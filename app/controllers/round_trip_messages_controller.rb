class RoundTripMessagesController < ApplicationController
  def create
    message = RoundTripMessage.new(round_trip_message_params)

    if message.valid?
      redirect_to root_path, notice: "Rails received “#{message.message}” through Inertia."
    else
      redirect_to root_path, inertia: { errors: message.errors }
    end
  end

  private

  def round_trip_message_params
    params.expect(round_trip_message: [ :message ])
  end
end
