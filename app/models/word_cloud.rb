class WordCloud
  def self.generate size, content
    exclusions = WordExclusion.pluck(:word)
    
    freqs = content
    .force_encoding("UTF-8")
    .scan(/[\w']+/)
    .reduce(Hash.new(0)) { |fs, w|
      word = w.singularize.downcase
      fs[word] += 1 unless exclusions.include? w or exclusions.include? word or word.length <= 2 or word.numeric?
      fs
    }
    .sort_by { |k, v| v }
    .reverse
    .take(size)
    
    max = freqs.first.try(:last)
    freqs.map { |w| [w.first, w.last.to_f / max] }
  end
end