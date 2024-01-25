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
    @title = "Stats for all publications up to #{@year}"
    @publications = Publication.statistics @status, @year

    render :index
  end

  def validated
    @latest_update = Publication.maximum(:updated_at)
    @status = Status::VALIDATED
    @year = params[:year]
    @title = "Stats for validated publications up to #{@year}"
    @publications = Publication.statistics @status, @year

    render :index
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
    @fields =
      Field
      .joins(:publications)
      .select('*, count(publications.id) as publications_count')
      .where("publications.id IN (SELECT id FROM (#{@publications.to_sql}))")
      .group('fields.id')
      .order('count(fields.id) DESC')

    render partial: "summarized_fields"
  end

  def summarized_journals
    @journals =
      Journal
      .joins(:publications)
      .select('*, count(publications.id) as publications_count')
      .where("publications.id IN (SELECT id FROM (#{@publications.to_sql}))")
      .group('journals.id')
      .order('count(journals.id) DESC')

    render partial: "summarized_journals"
  end

  def summarized_focusgroups
    @focusgroups =
      Focusgroup
      .joins(:publications)
      .select('*, count(publications.id) as publications_count')
      .where("publications.id IN (SELECT id FROM (#{@publications.to_sql}))")
      .group('focusgroups.id')
      .order('count(focusgroups.id) DESC')

    render partial: "summarized_focusgroups"
  end

  def summarized_platforms
    @platforms =
      Platform
      .joins(:publications)
      .select('*, count(publications.id) as publications_count')
      .where("publications.id IN (SELECT id FROM (#{@publications.to_sql}))")
      .group('platforms.id')
      .order('count(platforms.id) DESC')

    render partial: "summarized_platforms"
  end

  def world_publications
    render partial: "world_publications"
  end

  def world_users
    @users = User.all

    render partial: "world_users"
  end

  def world_locations
    @locations =
      Location
      .joins(:publications)
      .select('*, count(publications.id) as publications_count')
      .where("publications.id IN (SELECT id FROM (#{@publications.to_sql}))")
      .group('locations.id')
      .order('count(locations.id) DESC')

    render partial: "world_locations"
  end

  def time_refuge
    @annual_refuge_counts = @publications.relevance('refug').annual_counts

    render partial: "time_refuge"
  end

  def time_mesophotic
    @annual_mesophotic_counts = @publications.relevance('mesophotic').annual_counts

    render partial: "time_mesophotic"
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
