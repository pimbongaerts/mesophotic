class EezsController < ApplicationController
  def index
    @studied = Eez.with_publications
      .select("eezs.*, COUNT(DISTINCT publications.id) AS publications_count")
      .joins(locations: :publications)
      .group("eezs.id")
      .order(:sovereign, :territory)
      .group_by(&:sovereign)

    @unstudied = Eez.where.not(id: Eez.with_publications)
      .order(:sovereign, :territory)
      .group_by(&:sovereign)
  end

  def show
    @eez = Eez.find_by(id: params[:id])
    return head(:not_found) unless @eez

    @locations = @eez.locations
      .left_joins(:publications)
      .select("locations.*, COUNT(publications.id) AS publications_count")
      .group("locations.id")
      .order(Arel.sql("COUNT(publications.id) DESC"))
  end
end
