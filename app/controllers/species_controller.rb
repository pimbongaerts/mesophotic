class SpeciesController < ApplicationController
  before_action :require_admin_or_editor!, :except => [:show, :index]
  before_action :set_species, only: [:show, :edit]

  def index
  	@species = Species.all.order('focusgroup_id ASC')
  end

  def show
    params[:search] = @species.name
    @publications = Publication.relevance(@species.name)
  end

  def edit
  end

  private
    def set_species
      @species = Species.find(params[:id])
    end
end
