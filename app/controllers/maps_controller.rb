class MapsController < ApplicationController
  def world_map
    cached = Rails.cache.fetch(["world_map", params[:model], params[:ids], params[:z], Publication.maximum(:updated_at).to_i]) do
      data = params[:model].singularize.classify.constantize.where(id: params[:ids].split(','))
      render_to_string partial: 'shared/world_map_clickable',
             locals: { title: params[:model].pluralize.titleize,
                       data: get_coordinates(data, params[:z]),
                       backgroundcolor: params[:backgroundcolor],
                       height: params[:height] }
    end
    render html: cached.html_safe
  end

  private

  def get_coordinates(places, z)
    places.filter_map { |p| p.place_data(z) }
  end
end
