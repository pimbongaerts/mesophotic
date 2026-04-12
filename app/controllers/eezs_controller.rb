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

    @location_eez_map = Location.includes(:eez).where.not(eez_id: nil)
      .order(:description)
      .map { |l| { description: l.description, eez_path: "#{eez_path(l.eez)}#loc-#{l.id}", territory: l.eez.territory, sovereign: l.eez.sovereign } }

    @map_data = Location.joins(:publications, :eez)
      .select("locations.*, eezs.sovereign, COUNT(DISTINCT publications.id) AS pub_count")
      .group("locations.id")
      .map { |l| { name: l.description, lat: l.latitude.to_f, lon: l.longitude.to_f, z: l.pub_count, sovereign: l.sovereign, url: summary_path(model: "locations", id: l.id) } }
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
