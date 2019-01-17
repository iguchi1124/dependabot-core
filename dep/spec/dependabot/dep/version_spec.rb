# frozen_string_literal: true

require "spec_helper"
require "dependabot/dep/version"

RSpec.describe Dependabot::Dep::Version do
  subject(:version) { described_class.new(version_string) }
  let(:version_string) { "1.0.0" }

  describe ".correct?" do
    subject { described_class.correct?(version_string) }

    context "with a string prefixed with a 'v'" do
      let(:version_string) { "v1.0.0" }
      it { is_expected.to eq(true) }
    end

    context "with a string not prefixed with a 'v'" do
      let(:version_string) { "1.0.0" }
      it { is_expected.to eq(true) }
    end

    context "with an 'incompatible' suffix" do
      let(:version_string) { "v1.0.0+incompatible" }
      it { is_expected.to eq(true) }
    end

    context "with an invalid string" do
      let(:version_string) { "va1.0.0" }
      it { is_expected.to eq(false) }
    end

    context "with an empty string" do
      let(:version_string) { "" }
      it { is_expected.to eq(true) }
    end
  end

  describe "#to_s" do
    subject { version.to_s }

    context "with a non-prerelease" do
      let(:version_string) { "1.0.0" }
      it { is_expected.to eq "1.0.0" }
    end

    context "with a normal prerelease" do
      let(:version_string) { "1.0.0.pre1" }
      it { is_expected.to eq "1.0.0.pre1" }
    end

    context "with a PHP-style prerelease" do
      let(:version_string) { "1.0.0-pre1" }
      it { is_expected.to eq "1.0.0-pre1" }
    end

    context "with a leading v" do
      let(:version_string) { "v1.0.0" }
      it { is_expected.to eq "1.0.0" }
    end

    context "with an empty string" do
      let(:version_string) { "" }
      it { is_expected.to eq "" }
    end
  end

  describe "#inspect" do
    subject { version.inspect }

    context "with a version that Gem::Version would mangle" do
      let(:version_string) { "1.0.0-pre1" }
      it "doesn't mangle it" do
        is_expected.to eq "#<Dependabot::Dep::Version \"1.0.0-pre1\">"
      end
    end
  end

  describe "compatibility with Gem::Requirement" do
    subject { requirement.satisfied_by?(version) }
    let(:requirement) { Gem::Requirement.new(">= 1.0.0") }

    context "with a valid version" do
      let(:version_string) { "1.0.0" }
      it { is_expected.to eq(true) }
    end

    context "with an 'incompatible' suffix" do
      let(:version_string) { "1.0.0+incompatible" }
      it { is_expected.to eq(true) }
    end

    context "with an invalid version" do
      let(:version_string) { "0.9.0" }
      it { is_expected.to eq(false) }
    end

    context "with a valid prerelease version" do
      let(:version_string) { "1.1.0-pre" }
      it { is_expected.to eq(true) }
    end

    context "prefixed with a 'v'" do
      context "with a greater version" do
        let(:version_string) { "v1.1.0" }
        it { is_expected.to eq(true) }
      end

      context "with an lesser version" do
        let(:version_string) { "v0.9.0" }
        it { is_expected.to eq(false) }
      end
    end
  end
end