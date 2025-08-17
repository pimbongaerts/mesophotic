module DualRangeHelper
  def dual_range_slider(name, options = {})
    defaults = {
      min: 0,
      max: 100,
      step: 1,
      value: nil,
      class: '',
      suffix: '',
      id: nil,
      min_label: nil,
      max_label: nil
    }
    
    opts = defaults.merge(options)
    
    # Parse current value or use defaults
    current_value = opts[:value] || "#{opts[:min]},#{opts[:max]}"
    min_val, max_val = current_value.split(',').map(&:to_i)
    
    # Generate unique IDs if not provided
    base_id = opts[:id] || name.to_s.gsub(/[\[\]]/, '_').gsub('__', '_')
    min_id = "#{base_id}_min"
    max_id = "#{base_id}_max"
    hidden_id = "#{base_id}_hidden"
    highlight_id = "#{base_id}_highlight"
    min_display_id = "#{base_id}_min_display"
    max_display_id = "#{base_id}_max_display"
    
    render partial: 'shared/dual_range_slider', locals: {
      name: name,
      opts: opts,
      min_val: min_val,
      max_val: max_val,
      current_value: current_value,
      base_id: base_id,
      min_id: min_id,
      max_id: max_id,
      hidden_id: hidden_id,
      highlight_id: highlight_id,
      min_display_id: min_display_id,
      max_display_id: max_display_id
    }
  end
end