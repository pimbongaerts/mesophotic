class SpeciationJob < ApplicationJob
  queue_as :default

  def perform(species, publications)
    species.each do |s|
      s.publications.clear
      s.publications << publications.relevance(s.name).to_a
    end
  end
end
