class UpdateBooleanColumns < ActiveRecord::Migration[5.2]
  def change
    {
      Journal => [:open_access],
      Comment => [:internal, :request, :request_handled],
      Observation => [:depth_estimate],
      Photo => [:contains_species, :underwater, :creative_commons, :showcases_location, :media_gallery],
      Post => [:draft],
      Presentation => [:oral],
      Publication => [:mce, :tme, :new_species, :original_data, :mesophotic],
      Site => [:estimated],
      User => [:editor, :admin, :locked]
    }.each { |model, fields|
      fields.each { |field|
        model.where("#{field} = 't'").update_all(field => 1)
        model.where("#{field} = 'f'").update_all(field => 0)
      }
    }
  end
end
