class SpeciationJob < ApplicationJob
  queue_as :default

  def perform(*species)
    # Do something later
    puts species.to_yaml
  end
end
