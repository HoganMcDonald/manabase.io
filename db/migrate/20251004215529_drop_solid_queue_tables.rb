# frozen_string_literal: true

class DropSolidQueueTables < ActiveRecord::Migration[8.0]
  def up
    # Drop all Solid Queue tables
    drop_table :solid_queue_recurring_executions, if_exists: true
    drop_table :solid_queue_scheduled_executions, if_exists: true
    drop_table :solid_queue_ready_executions, if_exists: true
    drop_table :solid_queue_claimed_executions, if_exists: true
    drop_table :solid_queue_failed_executions, if_exists: true
    drop_table :solid_queue_blocked_executions, if_exists: true
    drop_table :solid_queue_processes, if_exists: true
    drop_table :solid_queue_jobs, if_exists: true
    drop_table :solid_queue_recurring_tasks, if_exists: true
    drop_table :solid_queue_semaphores, if_exists: true
    drop_table :solid_queue_pauses, if_exists: true
  end

  def down
    # This is irreversible - if you need to rollback, you'll need to
    # re-create the Solid Queue tables from the original migration
    raise ActiveRecord::IrreversibleMigration
  end
end
