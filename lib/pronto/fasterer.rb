# frozen_string_literal: true

require "pronto"
require "fasterer/analyzer"

module Pronto
  class Fasterer < Runner
    def run
      # When no modified files
      return [] if !@patches || @patches.count.zero?

      @patches.select { |patch| valid_patch?(patch) }
              .map { |patch| inspect(patch) }
              .compact
    end

    private

    def valid_patch?(patch)
      return false unless patch.additions.positive?

      # Return boolean value to determine if patch is valid for this runner.
      file_path = patch.new_file_full_path
      rb_file?(file_path) || rake_file?(file_path)
    end

    def inspect(patch)
      patch_path = patch.new_file_full_path
      offenses = run_fasterer(patch_path)
      offenses.map do |offense|
        next unless patch.added_lines.find { |line| line.new_lineno == offense.line_number }

        Message.new(patch_path, offense.line_number, :warning, offense.explanation, nil, self.class)
      end
    end

    def run_fasterer(path)
      ::Fasterer::Analyzer.new(path).scan
    end
  end
end
