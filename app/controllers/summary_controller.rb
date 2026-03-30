class SummaryController < ApplicationController
  before_action :model, :object

  def show
    respond_to do |format|
      format.html {
        @publications = publications.page(params[:page]).per(10)
        @objects = @model.joins(:publications).group("#{params[:model]}.id").order(description: :asc)
      }

      format.csv { 
        send_data publications.reorder(:id).csv, filename: "#{@model} #{@object.id}, #{@object.description}.csv" 
      }
    end
  end

  def summary_keywords
    cached = Rails.cache.fetch(["summary_keywords", params[:model], params[:id], Publication.maximum(:updated_at)]) do
      word_cloud = publications.word_cloud(40)
      word_cloud.present? ? render_to_string(partial: 'shared/wordcloud', object: word_cloud, locals: { title: "#{params[:model]}_publication_contents" }) : ""
    end
    render html: cached.html_safe
  end

  def summary_researchers
    cached = Rails.cache.fetch(["summary_researchers", params[:model], params[:id], Publication.maximum(:updated_at)]) do
      render_to_string partial: 'author', collection: publications.authors
    end
    render html: cached.html_safe
  end

  def summary_publications
    cached = Rails.cache.fetch(["summary_publications", params[:model], params[:id], Publication.maximum(:updated_at)]) do
      render_to_string partial: 'shared/item_counts',
             collection: {
               "Focusgroups": focusgroups,
               "Fields": fields,
               "Platforms": platforms
             }
    end
    render html: cached.html_safe
  end

  private

  def model
    @model = params[:model].singularize.classify.constantize
  end

  def object
    @object = @model.find(params[:id])
  end

  def publications
    @object.publications.original
  end

  def focusgroups
    publications
      .select('focusgroups.id, focusgroups.description, count(focusgroups.id) AS count')
      .joins(:focusgroups)
      .group('focusgroups.id')
      .order(Arel.sql('count DESC'))
      .limit(5)
  end

  def fields
    publications
      .select('fields.id, fields.description, count(fields.id) AS count')
      .joins(:fields)
      .group('fields.id')
      .order(Arel.sql('count DESC'))
      .limit(5)
  end

  def platforms
    publications
      .select('platforms.id, platforms.description, count(platforms.id) AS count')
      .joins(:platforms)
      .group('platforms.id')
      .order(Arel.sql('count DESC'))
      .limit(5)
  end
end
