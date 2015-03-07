class Duty
  include Mongoid::Document
  embeds_one :day
  embeds_one :task
  embeds_many :people

  validates_presence_of :day, :task
end
