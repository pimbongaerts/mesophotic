class SpeciesController < ApplicationController
  before_action :require_admin_or_editor!, :except => [:show, :index, :species_image]
  before_action :set_species, only: [:show, :edit, :species_image]

  def index
    # Currently set to only show species lists with at least 10 species
    @focusgroups = Focusgroup.joins(:species).group('focusgroups.id').having('count(focusgroup_id) > 10')
    @species = Species.all
  end

  def edit
  end

  def species_image
    render partial: 'species_image', locals: { object: @species }
  end

  private
    def set_species
      @species = Species.find(params[:id])
    end
  end
