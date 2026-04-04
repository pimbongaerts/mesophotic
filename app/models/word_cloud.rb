class WordCloud
  def self.generate size, content
    return [] unless content.present?

    exclusions = WordExclusion.select("LOWER(word) AS word").distinct.order(Arel.sql("LOWER(word) ASC")).map(&:word)
    species = Species.select("LOWER(name) AS name").distinct.order(Arel.sql("LOWER(name) ASC")).flat_map { |s| s.name.split(/\s/) }
    
    frequencies = content.dup
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