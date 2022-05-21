# frozen_string_literal: true

require "rugged/patch"

RSpec.describe Pronto::Fasterer do
  let(:patch) { Rugged::Patch.from_strings }
  let(:repo) { Pronto::Git::Repository.new(Dir.pwd) }
  let(:pronto_patches) { Pronto::Git::Patches.new(repo, nil, [patch]) }
  let(:file) { File.new("spec/files/offense.rb") }
  let(:analyzer) { ::Fasterer::Analyzer.new(file.path) }
  let(:addition) { "test" }

  before do
    File.write(file.path, addition)
    analyzer.scan
  end

  after { File.write(file.path, "") }

  subject(:output) { described_class.new(pronto_patches).run }

  context "when no patches at all" do
    it "hasn't got any output" do
      expect(output).to eql []
    end
  end

  context "when file is not ruby file" do
    let(:patch) { Rugged::Patch.from_strings(nil, "added\n") }

    it "hasn't got any output" do
      expect(output).to eql []
    end
  end

  context "when file added" do
    let(:patch) { Rugged::Patch.from_strings(nil, addition, old_path: nil, new_path: file.path) }

    it "hasn't detect any offenses" do
      expect(output).to eql []
    end

    context "when has offense" do
      let(:addition) { "[].shuffle.first" }
      let(:offense) do
        analyzer.errors[:shuffle_first_vs_sample].first.explanation
      end

      it "has same output as fasterer" do
        expect(output.empty?).to be false
        expect(output.first.msg).to eql offense
      end
    end
  end

  context "with fasterer config" do
    let(:config_path) { File.join(Dir.pwd, ".fasterer.yml") }
    let(:config_file) { File.new(config_path, "w") }
    let(:addition) { "[].shuffle.first" }
    let(:patch) { Rugged::Patch.from_strings(nil, addition, old_path: nil, new_path: file.path) }

    context "when file_path in exclude paths config" do
      before do
        config_file.puts("exclude_paths:\n - #{file.path}")
        config_file.close
      end

      it "hasn't got any output" do
        expect(output).to eql []
      end
    end

    context "when speedup disabled" do
      before do
        config_file.puts("speedups:\n shuffle_first_vs_sample: false")
        config_file.close
      end

      it "hasn't got any output" do
        expect(output).to eql []
      end
    end

    after { File.delete(config_path) }
  end
end
