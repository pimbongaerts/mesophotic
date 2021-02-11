class WordCloud
  def self.generate size, content
    exclusions = WordExclusion.select("LOWER(word) AS word").distinct.order(word: :asc).map(&:word)
    species = Species.select("LOWER(name) AS name").distinct.order(name: :asc).flat_map { |s| s.name.split(/\s/) }
    
    frequencies = content
      .force_encoding("UTF-8")
      .scan(/[\w']+/)
      .each_with_object(Hash.new(0)) { |word, memo|
        norm = normalize(species, word)
        memo[word] += 1 unless invalid(exclusions, word, norm)
      }
      .sort_by { |k, v| -v }
      .take(size)
    
    max = frequencies.first.try(:last)
    frequencies.map { |f| [f.first, f.last.to_f / max] }
  end

  def self.normalize species, word
    species.include?(word) ? word.downcase : word.singularize.downcase
  end

  def self.invalid exclusions, word, norm
    exclusions.include?(word) || 
    exclusions.include?(norm) || 
    norm.length <= 2 || 
    norm.numeric?
  end
end
