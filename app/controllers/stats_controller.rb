class StatsController < ApplicationController
  before_action :load_publications_for_status, only: [
    :growing_depth_range,
    :growing_publications_over_time,
    :growing_locations_over_time,
    :growing_authors_over_time,
    :world_publications,
    :world_locations,
    :summarized_fields,
    :summarized_journals,
    :summarized_focusgroups,
    :summarized_platforms,
    :time_refuge,
    :time_mesophotic
  ]

  before_action :load_annual_counts, only: [
    :time_refuge,
    :time_mesophotic
  ]

  module Status
    ALL = :all
    VALIDATED = :validated
  end

  def all
    @latest_update = Publication.maximum(:updated_at)
    @status = Status::ALL
    @year = params[:year].to_i
    @title = "All Publications"
    @stats_subtitle = "Stats up to #{@year}"
    @publications = Publication.statistics @status, @year

    render :index
  end

  def validated
    @latest_update = Publication.maximum(:updated_at)
    @status = Status::VALIDATED
    @year = params[:year]
    @title = "Validated Publications"
    @stats_subtitle = "Stats up to #{@year}"
    @publications = Publication.statistics @status, @year

    render :index
  end

  def growing_depth_range
    render_in_turbo_frame("stats-growing_depth_range") { render_to_string partial: "growing_depth_range" }
  end

  def growing_publications_over_time
    render_in_turbo_frame("stats-growing_publications_over_time") { render_to_string partial: "growing_publications_over_time" }
  end

  def growing_locations_over_time
    render_in_turbo_frame("stats-growing_locations_over_time") { render_to_string partial: "growing_locations_over_time" }
  end

  def growing_authors_over_time
    render_in_turbo_frame("stats-growing_authors_over_time") { render_to_string partial: "growing_authors_over_time" }
  end

  def summarized_fields
    @fields =
      Field
      .joins(:publications)
      .select('*, count(publications.id) as publications_count')
      .where("publications.id IN (SELECT id FROM (#{@publications.to_sql}))")
      .group('fields.id')
      .order(Arel.sql('count(fields.id) DESC'))

    render_in_turbo_frame("stats-summarized_fields") { render_to_string partial: "summarized_fields" }
  end

  def summarized_journals
    @journals =
      Journal
      .joins(:publications)
      .select('*, count(publications.id) as publications_count')
      .where("publications.id IN (SELECT id FROM (#{@publications.to_sql}))")
      .group('journals.id')
      .order(Arel.sql('count(journals.id) DESC'))

    render_in_turbo_frame("stats-summarized_journals") { render_to_string partial: "summarized_journals" }
  end

  def summarized_focusgroups
    @focusgroups =
      Focusgroup
      .joins(:publications)
      .select('*, count(publications.id) as publications_count')
      .where("publications.id IN (SELECT id FROM (#{@publications.to_sql}))")
      .group('focusgroups.id')
      .order(Arel.sql('count(focusgroups.id) DESC'))

    render_in_turbo_frame("stats-summarized_focusgroups") { render_to_string partial: "summarized_focusgroups" }
  end

  def summarized_platforms
    @platforms =
      Platform
      .joins(:publications)
      .select('*, count(publications.id) as publications_count')
      .where("publications.id IN (SELECT id FROM (#{@publications.to_sql}))")
      .group('platforms.id')
      .order(Arel.sql('count(platforms.id) DESC'))

    render_in_turbo_frame("stats-summarized_platforms") { render_to_string partial: "summarized_platforms" }
  end

  def world_publications
    render_in_turbo_frame("stats-world_publications") { render_to_string partial: "world_publications" }
  end

  def world_users
    @users = User.all

    render_in_turbo_frame("stats-world_users") { render_to_string partial: "world_users" }
  end

  def world_locations
    @locations =
      Location
      .joins(:publications)
      .select('*, count(publications.id) as publications_count')
      .where("publications.id IN (SELECT id FROM (#{@publications.to_sql}))")
      .group('locations.id')
      .order(Arel.sql('count(locations.id) DESC'))

    render_in_turbo_frame("stats-world_locations") { render_to_string partial: "world_locations" }
  end

  def time_refuge
    @annual_refuge_counts = @publications.relevance('refug').annual_counts

    render_in_turbo_frame("stats-time_refuge") { render_to_string partial: "time_refuge" }
  end

  def time_mesophotic
    @annual_mesophotic_counts = @publications.relevance('mesophotic').annual_counts

    render_in_turbo_frame("stats-time_mesophotic") { render_to_string partial: "time_mesophotic" }
  end

  private

  def load_publications_for_status
    @status = params[:status].to_sym
    @year = params[:year].to_i
    @publications = Publication.statistics @status, @year
  end

  def load_annual_counts
    @annual_counts = @publications.annual_counts
  end
end
