class WordCloud
  def self.generate size, content
    exclusions = WordExclusion.select("LOWER(word) AS word").distinct.order(word: :asc).map(&:word)
    species = Species.select("LOWER(name) AS name").distinct.order(name: :asc).flat_map { |s| s.name.split(/\s/) }
    
    frequencies = content
      .force_encoding("UTF-8")
      .downcase
      .scan(/[\w']+/)
      .tally
      .each_with_object(Hash.new(0)) { |word, memo|
        memo[normalize(species, word[0])] += word[1]
      }
      .delete_if { |word, v| 
        invalid(exclusions, word) 
      }
      .sort_by { |k, v| -v }
      .take(size)
    
    max = frequencies.first.try(:last)
    frequencies.map { |f| [f.first, f.last.to_f / max] }
  end

  def self.normalize species, word
    species.include?(word) ? word : word.singularize
  end

  def self.invalid exclusions, word
    exclusions.include?(word) || 
    word.length <= 2 || 
    Float(word) != nil
  rescue
    false
  end
end