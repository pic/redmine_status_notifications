require_dependency 'mailer'

class Mailer

  def issue_edit(journal, status_recipients = [], only_status_recipients = false)
    issue = journal.journalized.reload
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id,
                    'Issue-Author' => issue.author.login
    redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
    message_id journal
    references issue
    @author = journal.user
    rcpts = if only_status_recipients
      status_recipients
    else
      issue.recipients + status_recipients
    end
    recipients rcpts.uniq
    # Watchers in cc
    cc(issue.watcher_recipients - @recipients)
    s = "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] "
    s << "(#{issue.status.name}) " if journal.new_value_for('status_id')
    s << issue.subject
    subject s
    body :issue => issue,
         :journal => journal,
         :issue_url => url_for(:controller => 'issues', :action => 'show', :id => issue)

    render_multipart('issue_edit', body)
  end


end

