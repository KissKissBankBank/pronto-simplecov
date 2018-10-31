module Pronto
  module ProntoSimplecov
    class Runner < Runner
      def run
        return [] unless @patches
        return [] if coverage.empty?
        @patches.map { |patch| process(patch) }
                .flatten.compact
      end

      def process(patch)
        file_coverage = coverage[patch.new_file_full_path.to_s]
        return unless file_coverage
        messages = patch.added_lines
             .select { |line| file_coverage.line(line.new_lineno).missed? unless file_coverage.line(line.new_lineno).nil? }
             .map { |line| message(line) }
        messages_count = messages.count
        if messages_count > 0
          path = messages.first.path
          line = messages.first.line
          msg = "#{messages_count} lines of this file are not covered below"
          [Message.new(path, line, :error, msg, nil, self.class)]
        else
          []
        end
      end


      def message(line)
        path = line.patch.delta.new_file[:path]
        Message.new(path, line, :error, 'This file misses test coverage', nil, self.class)
      end

      def coverage
        @coverage ||= Hash[SimpleCov::ResultMerger.merged_result.files.map { |file| [file.filename, file] }]
      end
    end
  end
end
