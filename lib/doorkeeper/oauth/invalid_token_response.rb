# frozen_string_literal: true

module Doorkeeper
  module OAuth
    class InvalidTokenResponse < ErrorResponse
      attr_reader :reason

      def self.from_access_token(access_token, attributes = {})
        reason = if access_token.try(:revoked?)
                   :revoked
                 elsif access_token.try(:expired?)
                   :expired
                 else
                   :unknown
                 end

        new(attributes.merge(reason: reason))
      end

      def initialize(attributes = {})
        super(attributes.merge(name: :invalid_token, state: :unauthorized))
        @reason = attributes[:reason] || :unknown
      end

      def description
        scope = { scope: %i[doorkeeper errors messages invalid_token] }
        @description ||= I18n.translate @reason, scope
      end

      protected

      def exception_class
        errors_mapping.fetch(reason)
      end

      private

      def errors_mapping
        {
          expired: Doorkeeper::Errors::TokenExpired,
          revoked: Doorkeeper::Errors::TokenRevoked,
          unknown: Doorkeeper::Errors::TokenUnknown
        }
      end
    end
  end
end
