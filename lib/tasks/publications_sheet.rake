namespace :publications do
  desc "Output publication statuses for publication titles in supplied list"
  task :statuses, [:input_file, :output_file] => [:environment] do |t, args|
    File.open(args[:output_file], "w+") do |output|
      File.open(args[:input_file], "r") do |input|
        input.each_line do |title|
          lines = Publication.where(title: title.strip).map do |p|
            "\t#{p.created_at.strftime("%d/%m/%Y")}\t#{p.id}\t#{p.contributor.try(:full_name_normal).try(:strip)}\t\t\t#{p.title}"
          end

          lines.each do |l|
            output.puts l || "\t\t\t\t\t\t#{title.strip}"
          end
        end
      end
    end
  end

  desc "Output duplicated publication statuses for publication titles in supplied list"
  task :duplicates, [:input_file, :output_file] => [:environment] do |t, args|
    File.open(args[:output_file], "w+") do |output|
      File.open(args[:input_file], "r") do |input|
        input.each_line do |title|
          lines = Publication.where(title: title.strip).map do |p|
            "\t#{p.created_at.strftime("%d/%m/%Y")}\t#{p.id}\t#{p.contributor.try(:full_name_normal).try(:strip)}\t\t\t#{p.title}"
          end

          lines.each do |l|
            output.puts l || "\t\t\t\t\t\t#{title.strip}"
          end if lines.count > 1
        end
      end
    end
  end


  desc "Everything"
  task :everything, [:start_id, :input_file, :output_file] => [:environment] do |t, args|
    File.open(args[:output_file], "w+") do |output|
      everything = Publication.where("id >= ?", args[:start_id]).order(:title, :id)

      found_titles = everything.map(&:title).sort
      missing = File.open(args[:input_file]).map(&:chomp).reject { |title| found_titles.include?(title) }

      everything.each do |p|
        output.puts "\t#{p.created_at.strftime("%d/%m/%Y")}\t#{p.id}\t#{p.contributor.try(:full_name_normal).try(:strip)}\t\t\t#{p.title}"
      end

      output.puts "\n"

      missing.each do |t|
        output.puts "\t\t\t\t\t\t#{t}"
      end
    end
  end
end
