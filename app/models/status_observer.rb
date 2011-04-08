class StatusObserver <  ActiveRecord::Observer
  observe :journal

  def after_create(journal)
    if journal.new_status.present?
      # changed status
      status_recipients = StatusNotifications.instance.recipients(journal.new_status.name)
      unless status_recipients.empty?
        # I have status recipients so send notifications in any case,
        would_send_notifications = false
        if Setting.notified_events.include?('issue_updated') ||
           (Setting.notified_events.include?('issue_note_added') && journal.notes.present?) ||
           (Setting.notified_events.include?('issue_status_updated') && journal.new_status.present?) ||
           (Setting.notified_events.include?('issue_priority_updated') && journal.new_value_for('priority_id').present?)
          would_send_notifications = true
        end
        if would_send_notifications
          standard_recipients = (journal.journalized.recipients + journal.journalized.watcher_recipients).uniq
          status_recipients -= standard_recipients
        end

        StatusMailer.deliver_status_issue_edit(journal, status_recipients) unless status_recipients.empty?
      end 
    end
  end

  def reload_observer
    observed_classes.each do |klass|
      klass.name.constantize.add_observer(self)
    end
  end
end

