# frozen_string_literal: true

require "pronto"
require "fasterer/analyzer"
require "fasterer/config"

module Pronto
  class Fasterer < Runner
    def run
      # When no modified files
      return [] if !@patches || @patches.count.zero?

      @patches.select { |patch| valid_patch?(patch) }
              .flat_map { |patch| inspect(patch) }
              .compact
    end

    private

    def valid_patch?(patch)
      return false unless patch.additions.positive?

      # Return boolean value to determine if patch is valid for this runner.
      file_path = patch.new_file_path
      target_file?(file_path) && !fasterer_config.ignored_files.member?(file_path)
    end

    def target_file?(file_path)
      rb_file?(file_path) || rake_file?(file_path)
    end

    def inspect(patch)
      patch_path = patch.new_file_full_path
      offenses = run_fasterer(patch_path)
      messages = []
      offenses.each do |offense|
        next if fasterer_config.ignored_speedups.include?(offense.name)

        added_line = patch.added_lines.find { |line| line.new_lineno == offense.line_number }
        next unless added_line

        messages << message(patch_path, added_line, offense.explanation)
      end

      messages
    end

    def fasterer_config
      @fasterer_config ||= ::Fasterer::Config.new
    end

    def message(path, line, text)
      Message.new(path, line, :warning, text, nil, self.class)
    end

    def run_fasterer(path)
      analyzer = ::Fasterer::Analyzer.new(path)
      analyzer.scan
      analyzer.errors
    end
  end
end
