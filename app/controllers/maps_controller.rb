class MapsController < ApplicationController
  def world_map
    data = params[:model].singularize.classify.constantize.where(id: params[:ids].split(','))

    render partial: 'shared/world_map_clickable',
           locals: { title: params[:model].pluralize.titleize,
                     data: get_coordinates(data, params[:z]),
                     backgroundcolor: params[:backgroundcolor],
                     height: params[:height] }
  end

  private

  def get_coordinates(places, z)
    places.filter_map { |p| p.place_data(z) }
  end
end
