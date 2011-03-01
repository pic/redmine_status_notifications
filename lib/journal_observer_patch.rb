require_dependency 'journal_observer'

class JournalObserver
  def after_create(journal)
    only_status_recipients = false
    status_recipients = if journal.new_status.present?
      only_status_recipients = !Setting.notified_events.include?('issue_status_updated')
      StatusNotifications.instance.recipients(journal.new_status.name)
    else
      []
    end

    if Setting.notified_events.include?('issue_updated') ||
        (Setting.notified_events.include?('issue_note_added') && journal.notes.present?) ||
        (!status_recipients.empty? or (Setting.notified_events.include?('issue_status_updated') && journal.new_status.present?)) ||
        (Setting.notified_events.include?('issue_priority_updated') && journal.new_value_for('priority_id').present?)
      Mailer.deliver_issue_edit(journal, status_recipients, only_status_recipients)
    end
  end
end

