# frozen_string_literal: true

require "open3"

RSpec.describe Pronto::Fasterer do
  let(:pronto_cmd) { "pronto run --unstaged -r fasterer" }
  let(:pronto_output) { Open3.capture2(pronto_cmd).first }
  let(:file_path) { File.join(Dir.pwd, "spec", "files", "offense.rb") }
  let(:file_content) { File.read(file_path) }

  context "when file didn't modified" do
    it "hasn't got any output" do
      expect(pronto_output.empty?).to be true
    end
  end

  context "when file modified" do
    let(:analyzer) { ::Fasterer::Analyzer.new(file_path) }
    let(:offense) do
      analyzer.errors[:shuffle_first_vs_sample].first.explanation
    end

    before do
      File.write(file_path, "[].shuffle.first")
      analyzer.scan
    end

    after { File.write(file_path, "") }

    it "has same output as fasterer" do
      expect(pronto_output.empty?).to be false
      expect(pronto_output).to match offense
    end
  end
end
