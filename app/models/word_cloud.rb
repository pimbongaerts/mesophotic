class WordCloud
  def self.generate size, content
    exclusions = WordExclusion.pluck(:word)
    species = Species.all.flat_map { |s| s.name.split(/\s/) }
    
    frequencies = content
    .force_encoding("UTF-8")
    .scan(/[\w']+/)
    .reduce(Hash.new(0)) { |freqs, w|
      word = normalize(species, w)
      freqs[word] += 1 unless invalid(exclusions, word, w)
      freqs
    }
    .sort_by { |k, v| v }
    .reverse
    .take(size)
    
    max = frequencies.first.try(:last)
    frequencies.map { |w| [w.first, w.last.to_f / max] }
  end

  def self.normalize species, w
    species.include?(w) ? w.downcase : w.singularize.downcase
  end

  def self.invalid exclusions, word, w
    exclusions.include? w or 
    exclusions.include? word or 
    word.length <= 2 or 
    word.numeric?
  end
end
