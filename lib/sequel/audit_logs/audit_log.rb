# frozen_string_literal: true

module Sequel
  module AuditLogs
    class AuditLog < Sequel::Model(:audit_logs)
      plugin :list, field: :version, scope: %i[auditable_type auditable_id]
      plugin :timestamps
      plugin :polymorphic

      many_to_one :auditable, polymorphic: true
      many_to_one :actor,     polymorphic: true

      def before_validation
        self.actor ||= Sequel::AuditLogs.current_actor

        super
      end
    end
  end
end
