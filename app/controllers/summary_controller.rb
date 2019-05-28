class SummaryController < ApplicationController
  def show
    @model = params[:model].singularize.classify.constantize
    @objects = @model.joins(:publications).group("#{params[:model]}.id").order('description ASC')
    @object = @model.find(params[:id])
    @all_publications = @object.publications
    @publications = @all_publications.page(params[:page]).per(10)

    respond_to do |format|
      format.html {}
      format.csv { 
        send_data @publications.csv, filename: "#{@model} #{@object.id}, #{@object.description}.csv" 
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
    model = params[:model].singularize.classify.constantize
    object = model.find(params[:id])
    object.publications
  end
end
