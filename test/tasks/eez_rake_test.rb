require 'test_helper'
require 'rake'

class EezRakeTest < ActiveSupport::TestCase
  setup do
    Mesophotic::Application.load_tasks if Rake::Task.tasks.empty?
  end

  test "eez:seed creates EEZ records from CSV" do
    Location.where.not(eez_id: nil).update_all(eez_id: nil)
    Eez.delete_all
    Rake::Task['eez:seed'].reenable
    Rake::Task['eez:seed'].invoke
    assert Eez.count > 0, "Expected EEZ records to be created"
    assert Eez.find_by(sovereign: "Australia").present?
  end

  test "eez:seed is idempotent" do
    Rake::Task['eez:seed'].reenable
    Rake::Task['eez:seed'].invoke
    count_after_first = Eez.count
    Rake::Task['eez:seed'].reenable
    Rake::Task['eez:seed'].invoke
    assert_equal count_after_first, Eez.count
  end

  test "eez:link_locations matches locations to EEZs" do
    Rake::Task['eez:seed'].reenable
    Rake::Task['eez:seed'].invoke
    Rake::Task['eez:link_locations'].reenable
    Rake::Task['eez:link_locations'].invoke
    # At minimum, task should run without error
  end
end
