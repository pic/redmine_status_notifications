require_dependency 'journal_observer'

class JournalObserver
  def after_create(journal)
    would_send_notifications = false
    if Setting.notified_events.include?('issue_updated') ||
        (Setting.notified_events.include?('issue_note_added') && journal.notes.present?) ||
        (Setting.notified_events.include?('issue_status_updated') && journal.new_status.present?) ||
        (Setting.notified_events.include?('issue_priority_updated') && journal.new_value_for('priority_id').present?)
      would_send_notifications = true
    end
    
    status_recipients = []
    only_status_recipients = false
    if journal.new_status.present?
      # changed status
      status_recipients = StatusNotifications.instance.recipients(journal.new_status.name)
      unless status_recipients.empty?
        # I have status recipients so send notifications in any case,
        # but only to them if I wouldn't have sent notifications otherwise 
        only_status_recipients = !would_send_notifications
        would_send_notifications = true
      end 
    end

    if would_send_notifications
      Mailer.deliver_issue_edit(journal, status_recipients, only_status_recipients)
    end

  end
end

