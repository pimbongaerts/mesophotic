class MapsController < ApplicationController
  ALLOWED_MODELS = %w[Location Site Photo].freeze

  def world_map
    model_class = safe_constantize(params[:model])
    return head(:bad_request) unless model_class

    cached = Rails.cache.fetch(["world_map", params[:model], params[:ids], params[:z], Publication.maximum(:updated_at).to_i]) do
      ids = params[:ids].to_s.split(',').reject(&:blank?)
      data = ids.any? ? model_class.where(id: ids) : model_class.none
      render_to_string partial: 'shared/world_map_clickable',
             locals: { title: params[:model].pluralize.titleize,
                       data: get_coordinates(data, params[:z]),
                       backgroundcolor: params[:backgroundcolor],
                       height: params[:height] }
    end
    render_in_turbo_frame("world-map-#{params[:key]}") { cached }
  end

  private

  def safe_constantize(model_param)
    class_name = model_param.to_s.singularize.classify
    class_name.constantize if ALLOWED_MODELS.include?(class_name)
  end

  def get_coordinates(places, z)
    places.filter_map { |p| p.place_data(z) }
  end
end
