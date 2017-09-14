class Vpc < ApplicationRecord
  belongs_to :customer

  def self.checks
    Pingdom::Check.all
  end

  def self.update_from_checks
    updated = 0
    created = 0

    self.checks.each do |check|

      vpc=self.find_or_create_by id: check.id

      vpc.new_record? ? created+=1 : updated+=1

      vpc.name             = check.name
      vpc.hostname         = check.hostname
      vpc.lasterrortime    = check.lasterrortime
      vpc.lastresponsetime = check.lastresponsetime
      vpc.lasttesttime     = check.lasttesttime
      vpc.resolution       = check.resolution
      vpc.status           = check.status
      vpc.check_type       = check.type
      vpc.data             = { tags: check.tags }.merge(vpc.data || {} )
      vpc.save

    end

    { total: updated + created, updated: updated, created: created }

  end
end
