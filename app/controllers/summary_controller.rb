class SummaryController < ApplicationController
  def show
    respond_to do |format|
      format.html {
        @publications = publications(params).page(params[:page]).per(10)
        @objects = @model.joins(:publications).group("#{params[:model]}.id").order('description ASC')   
      }

      format.csv { 
        send_data publications(params).reorder(:id).csv, filename: "#{@model} #{@object.id}, #{@object.description}.csv" 
      }
    end
  end

  def summary_keywords
    publications = publications params.permit(:model, :id)
    render partial: 'shared/wordcloud',  
           object: WordCloud.generate(40, publications.all_content),
           locals: { title: "#{params[:model]}_publication_contents" }
  end

  def summary_researchers
    publications = publications params.permit(:model, :id)
    render partial: 'author', 
           collection: publications.authors, 
           as: :author
  end

  def summary_publications
    publications = publications params.permit(:model, :id)
    render partial: 'shared/keyword',
           locals: { objects: publications },
           collection: [Focusgroup, Field, Platform]
  end

  private

  def publications params
    @model = params[:model].singularize.classify.constantize
    @object = @model.find(params[:id])
    @object.publications.original
  end
end
