# frozen_string_literal: true

# Provider-neutral failures classify retry and reconciliation behavior. Adapter
# implementations beneath this namespace are loaded independently by Zeitwerk.

module Integrations
  class Error < StandardError; end
  class TransientError < Error; end
  class PermanentError < Error; end

  class ConfigurationError < PermanentError; end
  class AuthenticationError < PermanentError; end
  class AuthorizationError < PermanentError; end
  class ProtocolError < PermanentError; end
  class InvalidResponse < ProtocolError; end
  class ValidationError < PermanentError; end
  class ProviderError < PermanentError; end
  class Conflict < PermanentError; end
  class NotFound < PermanentError; end
  class PermanentRequestError < ProviderError; end

  class TransportError < TransientError; end
  class Timeout < TransportError; end
  class Unavailable < TransportError; end

  class RateLimited < TransientError
    attr_reader :retry_after

    def initialize(message = "provider rate limit reached", retry_after: nil)
      @retry_after = retry_after
      super(message)
    end
  end

  # A mutation may have reached the provider. Reconcile state before retrying.
  class AmbiguousWrite < Error; end
end
