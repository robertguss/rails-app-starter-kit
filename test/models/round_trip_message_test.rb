require "test_helper"

class RoundTripMessageTest < ActiveSupport::TestCase
  test "requires a message" do
    message = RoundTripMessage.new(message: "")

    assert_not message.valid?
    assert_includes message.errors[:message], "can't be blank"
  end

  test "limits the message length" do
    message = RoundTripMessage.new(message: "x" * 121)

    assert_not message.valid?
    assert_includes message.errors[:message], "is too long (maximum is 120 characters)"
  end
end
