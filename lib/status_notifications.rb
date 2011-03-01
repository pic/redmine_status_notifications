require 'singleton'

class StatusNotifications
  include Singleton

  def initialize
    @map = {}
  end
  attr_reader :map

  def recipients(name)
    if map[name]
      map[name].collect do |l|
        User.find_by_login(l)
      end.compact.map(&:mail)
    else
      []
    end
  end
end

=begin in an initializers:
StatusNotifications.instance.map.merge!(
  'In Progress' => ['admin']
)
=end
