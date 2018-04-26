class SummaryController < ApplicationController
  def show
    @model = params[:model].singularize.classify.constantize
    @objects = @model.joins(:publications).group("#{params[:model]}.id").order('description ASC')
    @object = @model.find(params[:id])
    @publications = @object.publications.page(params[:page]).per(10)
  end
end
