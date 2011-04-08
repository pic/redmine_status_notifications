require 'redmine'

require 'status_notifications'

ActiveRecord::Base.observers << StatusObserver
config.to_prepare do
  unless config.cache_classes
    StatusObserver.instance.reload_observer
  end
end

Redmine::Plugin.register :redmine_status_notifications do
  name 'Redmine Status Notifications plugin'
  description 'This plugin send extra notifications on status update'
  version '0.0.1'
  url 'http://github.com/pic/redmine_status_notifications'
  author 'Nicola Piccinini'
  author_url 'mailto:piccinini@gmail.com'
end
