require 'test_helper'
require 'rake'

class EezRakeTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  test "seed CSV exists with correct headers and sufficient records" do
    require 'csv'
    csv_path = Rails.root.join('db/seeds/eezs.csv')
    assert File.exist?(csv_path)

    table = CSV.read(csv_path, headers: true)
    %w[mrgid geoname sovereign territory].each do |col|
      assert_includes table.headers, col
    end
    assert table.length > 200, "Expected at least 200 EEZ records, got #{table.length}"
  end

  test "eez:seed creates EEZ records from CSV" do
    Location.where.not(eez_id: nil).update_all(eez_id: nil)
    Eez.delete_all

    Rake::Task['eez:seed'].reenable
    quietly { Rake::Task['eez:seed'].invoke }

    assert Eez.count > 200
    assert Eez.find_by(sovereign: "Australia").present?
  end

  test "eez:seed is idempotent" do
    Rake::Task['eez:seed'].reenable
    quietly { Rake::Task['eez:seed'].invoke }
    count_after_first = Eez.count

    Rake::Task['eez:seed'].reenable
    quietly { Rake::Task['eez:seed'].invoke }
    assert_equal count_after_first, Eez.count
  end

  test "eez:link_locations runs without error" do
    Rake::Task['eez:seed'].reenable
    quietly { Rake::Task['eez:seed'].invoke }

    Rake::Task['eez:link_locations'].reenable
    assert_nothing_raised { quietly { Rake::Task['eez:link_locations'].invoke } }
  end

  private

  def quietly
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = original_stdout
  end
end
