# frozen_string_literal: true

require_relative '../audit_logs'

module Sequel
  module Plugins
    # Given a Post model with these fields:
    #   [:id, :category_id, :title, :body, :author_id, :created_at, :updated_at]
    #
    #
    # All fields
    #   plugin :audit_logs
    #     #=> [:category_id, :title, :body, :author_id]  # NB! excluding @default_ignore_attrs
    #     #=> [:id, :created_at, :updated_at]
    #
    # Single field
    #   plugin :audit_logs, only: :title
    #   plugin :audit_logs, only: %i[title]
    #     #=> [:title]
    #     #+> [:id, :category_id, :body, :author_id, :created_at, :updated_at] # ignored fields
    #
    # Multiple fields
    #   plugin :audit_logs, only: %i[title body]
    #     #=> [:title, :body] # tracked fields
    #     #=> [:id, :category_id, :author_id, :created_at, :updated_at] # ignored fields
    #
    #
    # All fields except certain fields
    #   plugin :audit_logs, except: :title
    #   plugin :audit_logs, except: %i[title]
    #     #=> [:id, :category_id, :author_id, :created_at, :updated_at] # tracked fields
    #     #=> [:title] # ignored fields

    module AuditLogs
      def self.configure(model, options = {})
        model.instance_eval do
          # add support for :dirty attributes tracking & JSON serializing of data
          plugin :dirty
          plugin :json_serializer
          plugin :polymorphic

          @audit_logs_only_columns     = [*options.fetch(:only, [])]
          @audit_logs_excluded_columns = [*options.fetch(:except, []), *Sequel::AuditLogs.ignore_columns].uniq

          one_to_many(
            :audit_logs,
            class: 'Sequel::AuditLogs::AuditLog',
            as: 'auditable',
            order: Sequel.asc(:version)
          )
        end
      end

      module ClassMethods
        attr_reader :audit_logs_only_columns
        attr_reader :audit_logs_excluded_columns

        Plugins.inherited_instance_variables(
          self,
          :@audit_logs_only_columns => nil,
          :@audit_logs_excluded_columns => [],
        )

        def auditable_columns
          if audit_logs_only_columns&.any?
            columns & audit_logs_only_columns
          else
            columns - audit_logs_excluded_columns
          end
        end
      end

      module InstanceMethods
        def last_audited_by
          audit_logs_dataset.last&.actor
        end

        def last_audited_at
          audit_logs_dataset.last&.created_at
        end

        private

        # extract audited values only
        def audit_logs_values(event)
          vals = case event
                 when :create
                   values
                 when :update
                   (column_changes.empty? ? previous_changes : column_changes)
                 when :destroy
                   values
                 end

          vals.slice(*self.class.auditable_columns)
        end

        def commit_audit_log(event)
          changes = audit_logs_values(event)

          add_audit_log(event:, changes:) unless changes.blank?
        end

        def after_create
          super
          commit_audit_log :create
        end

        def after_update
          super
          commit_audit_log :update
        end

        def after_destroy
          super
          commit_audit_log :destroy
        end
      end
    end
  end
end
