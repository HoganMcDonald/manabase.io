# frozen_string_literal: true

require "rails_helper"

RSpec.describe Search::EmbeddingService do
  describe ".embed" do
    context "with valid text" do
      let(:text) { "Lightning Bolt" }
      let(:mock_response) do
        {
          "data" => [
            {
              "embedding" => Array.new(1536) { rand }
            }
          ]
        }
      end

      before do
        allow_any_instance_of(RubyLlm).to receive(:embed).and_return(mock_response)
      end

      it "returns an embedding vector" do
        result = described_class.embed(text)
        expect(result).to be_an(Array)
        expect(result.length).to eq(1536)
      end

      it "normalizes the text before embedding" do
        text_with_whitespace = "Lightning    Bolt\n\nDeal 3 damage"
        expect_any_instance_of(RubyLlm).to receive(:embed).with(
          hash_including(input: "Lightning Bolt Deal 3 damage")
        ).and_return(mock_response)

        described_class.embed(text_with_whitespace)
      end
    end

    context "with blank text" do
      it "returns nil for empty string" do
        expect(described_class.embed("")).to be_nil
      end

      it "returns nil for nil" do
        expect(described_class.embed(nil)).to be_nil
      end

      it "returns nil for whitespace only" do
        expect(described_class.embed("   \n  ")).to be_nil
      end
    end

    context "when API call fails" do
      before do
        allow_any_instance_of(RubyLlm).to receive(:embed).and_raise(StandardError.new("API error"))
      end

      it "returns nil and logs error" do
        expect(Rails.logger).to receive(:error).with(/Embedding generation failed/)
        result = described_class.embed("test")
        expect(result).to be_nil
      end
    end

    context "with very long text" do
      let(:long_text) { "a" * 10000 }
      let(:mock_response) do
        {
          "data" => [
            {
              "embedding" => Array.new(1536) { rand }
            }
          ]
        }
      end

      before do
        allow_any_instance_of(RubyLlm).to receive(:embed).and_return(mock_response)
      end

      it "truncates text to 8000 characters" do
        expect_any_instance_of(RubyLlm).to receive(:embed).with(
          hash_including(input: "a" * 8000)
        ).and_return(mock_response)

        described_class.embed(long_text)
      end
    end
  end

  describe ".embed_batch" do
    context "with valid texts" do
      let(:texts) { ["Lightning Bolt", "Dark Ritual"] }
      let(:mock_response) do
        {
          "data" => [
            {"embedding" => Array.new(1536) { rand }},
            {"embedding" => Array.new(1536) { rand }}
          ]
        }
      end

      before do
        allow_any_instance_of(RubyLlm).to receive(:embed).and_return(mock_response)
      end

      it "returns an array of embeddings" do
        result = described_class.embed_batch(texts)
        expect(result).to be_an(Array)
        expect(result.length).to eq(2)
        expect(result.first.length).to eq(1536)
      end
    end

    context "with empty array" do
      it "returns empty array" do
        expect(described_class.embed_batch([])).to eq([])
      end
    end

    context "when API call fails" do
      before do
        allow_any_instance_of(RubyLlm).to receive(:embed).and_raise(StandardError.new("API error"))
      end

      it "returns empty array and logs error" do
        expect(Rails.logger).to receive(:error).with(/Batch embedding generation failed/)
        result = described_class.embed_batch(["test"])
        expect(result).to eq([])
      end
    end
  end

  describe ".embed_card" do
    let(:card) { create(:card) }
    let(:mock_response) do
      {
        "data" => [
          {
            "embedding" => Array.new(1536) { rand }
          }
        ]
      }
    end

    before do
      allow_any_instance_of(RubyLlm).to receive(:embed).and_return(mock_response)
    end

    it "generates embedding from card attributes" do
      result = described_class.embed_card(card)
      expect(result).to be_an(Array)
      expect(result.length).to eq(1536)
    end

    it "includes card name, type, and oracle text" do
      expect_any_instance_of(RubyLlm).to receive(:embed).with(
        hash_including(input: include(card.name, card.type_line))
      ).and_return(mock_response)

      described_class.embed_card(card)
    end

    context "with multi-faced card" do
      let(:card) { create(:card, :with_faces) }

      it "includes card face information" do
        face_names = card.card_faces.map(&:name)
        expect_any_instance_of(RubyLlm).to receive(:embed).with(
          hash_including(input: include(*face_names))
        ).and_return(mock_response)

        described_class.embed_card(card)
      end
    end
  end

  describe ".embed_card_document" do
    let(:card_doc) do
      {
        name: "Lightning Bolt",
        type_line: "Instant",
        oracle_text: "Lightning Bolt deals 3 damage to any target.",
        keywords: ["Instant"],
        card_faces: []
      }
    end
    let(:mock_response) do
      {
        "data" => [
          {
            "embedding" => Array.new(1536) { rand }
          }
        ]
      }
    end

    before do
      allow_any_instance_of(RubyLlm).to receive(:embed).and_return(mock_response)
    end

    it "generates embedding from card document hash" do
      result = described_class.embed_card_document(card_doc)
      expect(result).to be_an(Array)
      expect(result.length).to eq(1536)
    end

    it "includes all relevant fields" do
      expect_any_instance_of(RubyLlm).to receive(:embed).with(
        hash_including(input: include("Lightning Bolt", "Instant"))
      ).and_return(mock_response)

      described_class.embed_card_document(card_doc)
    end
  end
end
