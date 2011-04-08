require File.join(File.dirname(__FILE__), '..', 'test_helper')
require 'mocha'

class StatusObserverTest < ActiveSupport::TestCase

  fixtures :issues, :users, :issue_statuses

  def setup
    StatusNotifications.instance.map.merge!(
      'Resolved' => ['rhill']
    )
    @is = issues(:issues_002)
  end

  test 'set and retrieve cc custom value' do
  end 

  test 'it delivers emails' do
    StatusMailer.expects(:deliver_status_issue_edit)
    # without notes, journal skips saving
    @is.init_journal(User.find_by_login('admin'), 'notes')
    @is.status  = IssueStatus.find_by_name('Resolved')
    @is.save
  end

  test 'it does not deliver email if already sent by standard notification' do
    Watcher.create(:watchable => @is, :user => User.find_by_login('rhill'))
    StatusMailer.expects(:deliver_status_issue_edit).never
    # without notes, journal skips saving
    @is.init_journal(User.find_by_login('admin'), 'notes')
    @is.status  = IssueStatus.find_by_name('Resolved')
    @is.save
  end

end
