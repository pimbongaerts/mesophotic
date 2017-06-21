class SpeciesController < ApplicationController
  before_action :require_admin_or_editor!, :except => [:show, :index]

  def index
  end

  def show
  end
end
