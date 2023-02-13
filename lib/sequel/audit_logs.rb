require 'sequel/audit_logs/version'
require 'sequel/audit_logs/audit_log'

module Sequel
  module AuditLogs
    @enabled = true
    @ignore_columns = %i[
      id pk ref password password_hash lock_version created_at updated_at
      created_on updated_on
    ]

    class << self
      attr_accessor :current_actor, :enabled, :ignore_columns, :additional_data
    end
  end
end
