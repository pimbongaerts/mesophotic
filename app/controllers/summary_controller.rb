class SummaryController < ApplicationController
  before_action :model, :object

  def show
    respond_to do |format|
      format.html {
        @publications = publications.page(params[:page]).per(10)
        @objects = @model.joins(:publications).group("#{params[:model]}.id").order('description ASC')   
      }

      format.csv { 
        send_data publications.reorder(:id).csv, filename: "#{@model} #{@object.id}, #{@object.description}.csv" 
      }
    end
  end

  def summary_keywords
    word_cloud = publications.word_cloud(40)
    
    if word_cloud.present?
      render partial: 'shared/wordcloud',  
             object: word_cloud,
             locals: { key: publications.key, title: "#{params[:model]}_publication_contents" }
    end
  end

  def summary_researchers
    render partial: 'author', collection: publications.authors
  end

  def summary_publications
    render partial: 'shared/item_counts', 
           collection: { 
             "Focusgroups": focusgroups, 
             "Fields": fields, 
             "Platforms": platforms 
           }
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
      .order('count DESC')
      .limit(5)
  end

  def fields
    publications
      .select('fields.id, fields.description, count(fields.id) AS count')
      .joins(:fields)
      .group('fields.id')
      .order('count DESC')
      .limit(5)
  end

  def platforms
    publications
      .select('platforms.id, platforms.description, count(platforms.id) AS count')
      .joins(:platforms)
      .group('platforms.id')
      .order('count DESC')
      .limit(5)
  end
end
