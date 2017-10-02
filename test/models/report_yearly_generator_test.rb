require 'test_helper'

class ReportYearlyGeneratorTest < ActiveSupport::TestCase

  setup do
    History.start 'ReportJob'
    stub_checks
    Vpc.update_from_checks
    # the fixture vpcs cannot get a performance
    @fixture_vpcs=Vpc.where("name like ?",'%Fixture%').all.map { |vpc| vpc.id }
  end

  teardown do
    History.finish 'ReportJob'
  end

  def yearly_setup resolution: 'month'
    @date = Date.today.at_beginning_of_year.prev_year

    from=@date.to_time.to_i
    to = @date.next_year.to_time.to_i
    Vpc.all.each do |check|
      stub_average check_id: check.id, from: from, to: to, resolution: resolution
    end

  end

  def yearly_report_generator
    period= 'year'
    resolution = 'month'

    # step 1 report start
    Report.start @date, period: period, resolution: resolution
    assert Report.started(@date,period).count > 0
    assert_equal Report.started(@date,period).count, Vpc.count


    # step 2 save year outages
    Report.save_year_outages @date
    assert Report.outages_saved(@date,period).count> 0

    # step 4 check results
    Report.outages_saved(@date,period).each do |r|
      assert r.outage_uptime>0
      assert_equal r.outage_uptime, r.average_uptime
      assert_equal r.outage_downtime, r.average_downtime
      assert_equal r.outage_unknown, r.average_unknown
    end

  end

  test "Report year generator month resolution" do

    yearly_setup resolution: 'month'
    yearly_report_generator

  end
end
