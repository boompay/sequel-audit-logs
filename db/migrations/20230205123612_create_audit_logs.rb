# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :audit_logs do
      primary_key :id, type: :Bignum
      String      :auditable_type, null: false
      Bignum      :auditable_id, null: false
      String      :event, null: false
      jsonb       :changes
      Integer     :version
      String      :actor_type
      Bignum      :actor_id
      jsonb       :additional_data
      Time        :created_at

      index %i[auditable_type auditable_id]
      index %i[actor_type actor_id]
    end
  end
end
