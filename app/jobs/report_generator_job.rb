class ReportGeneratorJob < ApplicationJob
  include SuckerPunch::Job
  queue_as :default

  def perform(date, period: 'day', resolution: 'hour', cron: nil)

    ActiveRecord::Base.connection_pool.with_connection do

      History.start "Starting #{self.class.name} on #{date}, #{period} period and #{resolution} resolution", cron: cron

      Report.start date , period: period, resolution: resolution

      Report.save_performances date, period

      Report.save_outages date, period

      History.finish

    end if History.free

  end


end
