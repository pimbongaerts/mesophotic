class StatsController < ApplicationController
  before_action :set_publications, only: [:index, 
                                          :growing_depth_range, 
                                          :growing_publications_over_time,
                                          :growing_locations_over_time,
                                          :growing_authors_over_time]
  before_action :set_publications_total_counts, only: [:time_refuge, :time_mesophotic]

  def index
    @latest_update = Publication.maximum(:updated_at)
  end

  def growing_depth_range
    render partial: "growing_depth_range"
  end

  def growing_publications_over_time
    render partial: "growing_publications_over_time"
  end

  def growing_locations_over_time
    render partial: "growing_locations_over_time"
  end

  def growing_authors_over_time
    render partial: "growing_authors_over_time"
  end

  def summarized_fields
    @fields = Field.joins(:publications)
                    .select('*, count(publications.id) as publications_count')
                    .group('fields.id')
                    .order('count(fields.id) DESC')
    @fields_top = @fields.limit(10)

    render partial: "summarized_fields"
  end

  def summarized_journals
    @journals = Journal.joins(:publications)
                            .select('*, count(publications.id) as publications_count')
                            .group('journals.id')
                            .order('count(journals.id) DESC')
    @journals_top = @journals.limit(10)

    render partial: "summarized_journals"
  end

  def summarized_focusgroups
    @focusgroups = Focusgroup.joins(:publications)
                                .select('*, count(publications.id) as publications_count')
                                .group('focusgroups.id')
                                .order('count(focusgroups.id) DESC')
    @focusgroups_top = @focusgroups.limit(10)

    render partial: "summarized_focusgroups"
  end

  def summarized_platforms
    @platforms = Platform.joins(:publications)
                            .select('*, count(publications.id) as publications_count')
                            .group('platforms.id')
                            .order('count(platforms.id) DESC')
    @platforms_top = @platforms.limit(10)

    render partial: "summarized_platforms"
  end

  def world_publications
    @locations_raw = Location.all

    render partial: "world_publications"
  end

  def world_users
    @users = User.all

    render partial: "world_users"
  end

  def world_locations
    @locations = Location.joins(:publications)
                            .select('*, count(publications.id) as publications_count')
                            .group('locations.id')
                            .order('count(locations.id) DESC')
    @locations_top = @locations.limit(25)

    render partial: "world_locations"
  end

  def time_refuge
    @publications_refuge_counts = Publication.relevance('refug')
                                            .select('publication_year, count(id) as publications_count')
                                            .group('publication_year')

    render partial: "time_refuge"
  end

  def time_mesophotic
    @publications_mesophotic_counts = Publication.relevance('mesophotic')
                                                 .select('publication_year, count(id) as publications_count')
                                                 .group('publication_year')
    render partial: "time_mesophotic"
  end

  private

  def set_publications
    @publications = Publication.include_in_stats.order('publication_year DESC, created_at DESC')
  end

  def set_publications_total_counts
    @publications_total_counts = Publication.select('*, count(id) as publications_count')
                                            .all
                                            .group('publication_year')
  end
end
