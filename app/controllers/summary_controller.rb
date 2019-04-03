class SummaryController < ApplicationController
  def show
    @model = params[:model].singularize.classify.constantize
    @objects = @model.joins(:publications).group("#{params[:model]}.id").order('description ASC')
    @object = @model.find(params[:id])
    @all_publications = @object.publications
    @publications = @all_publications.page(params[:page]).per(10)
  end
end
