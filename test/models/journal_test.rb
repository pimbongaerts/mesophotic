require 'test_helper'

class JournalTest < ActiveSupport::TestCase
  test "requires name" do
    journal = Journal.new
    assert_not journal.valid?
    assert_includes journal.errors[:name], "can't be blank"
  end

  test "has many publications" do
    journal = journals(:open_journal)
    assert_includes journal.publications, publications(:scientific_article)
  end

  test "description returns name" do
    journal = journals(:open_journal)
    assert_equal "Open Access Journal", journal.description
  end
end
