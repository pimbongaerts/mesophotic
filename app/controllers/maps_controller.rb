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
    places.map do |p|
      { 
        name: p.place_name, 
        lat: p.latitude,
        lon: p.longitude, 
        z: z.try(:to_i) || p.z,
        url: send(p.place_path, p.place_id)
      }
    end
  end
end
