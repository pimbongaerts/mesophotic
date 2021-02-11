class WordCloud
  def self.generate size, content
    exclusions = WordExclusion.pluck(:word).map(&:downcase).sort
    species = Species.all.flat_map { |s| s.name.split(/\s/) }.map(&:downcase).sort
    
    frequencies = Hash.new(0)
    
    content
      .force_encoding("UTF-8")
      .scan(/[\w']+/)
      .map { |word| [word, normalize(species, word)] }
      .reject { |wn| 
        invalid(exclusions, wn.first, wn.last) 
      }
      .map(&:last)
      .each { |word| 
        frequencies[word] += 1 
      }
    
    frequencies = frequencies
      .sort_by { |k, v| -v }
      .take(size)
    
    max = frequencies.first.try(:last)
    frequencies.map { |f| [f.first, f.last.to_f / max] }
  end

  def self.normalize species, word
    species.include?(word) ? word.downcase : word.singularize.downcase
  end

  def self.invalid exclusions, word, norm
    exclusions.include? word or 
    exclusions.include? norm or 
    norm.length <= 2 or 
    norm.numeric?
  end
end
