require "spec_helper"
require_relative "../models/emotion"

describe Emotion do
  let(:user) { User.create!(nickname: "testuser_#{SecureRandom.hex(4)}", password: "password") }
  let(:valid_attributes) { { user: user, main_emotion: "Happiness", strength: "strong", emotion: "Excited" } }

  describe "validations" do
    it "is valid with valid attributes" do
      emotion = Emotion.new(valid_attributes)
      expect(emotion).to be_valid
    end

    it "is invalid without a user" do
      emotion = Emotion.new(valid_attributes.except(:user))
      expect(emotion).not_to be_valid
      expect(emotion.errors[:user]).to include("can't be blank")
    end

    it "is invalid without a main_emotion" do
      emotion = Emotion.new(valid_attributes.except(:main_emotion))
      expect(emotion).not_to be_valid
      expect(emotion.errors[:main_emotion]).to include("can't be blank")
    end

    it "is invalid without a strength" do
      emotion = Emotion.new(valid_attributes.except(:strength))
      expect(emotion).not_to be_valid
      expect(emotion.errors[:strength]).to include("can't be blank")
    end

    it "is invalid without an emotion" do
      emotion = Emotion.new(valid_attributes.except(:emotion))
      expect(emotion).not_to be_valid
      expect(emotion.errors[:emotion]).to include("can't be blank")
    end

    it "is invalid with invalid strength value" do
      emotion = Emotion.new(valid_attributes.merge(strength: "invalid"))
      expect(emotion).not_to be_valid
      expect(emotion.errors[:strength]).to include("is not included in the list")
    end
  end

  describe "associations" do
    it "belongs to a user" do
      emotion = Emotion.create!(valid_attributes)
      expect(emotion.user).to eq(user)
    end

    it "is destroyed when associated user is destroyed" do
      emotion = Emotion.create!(valid_attributes)
      expect { 
        Emotion.where(user: user).delete_all
        user.destroy
      }.to change(Emotion, :count).by(-1)
    end
  end

  describe "database operations" do
    it "saves and retrieves correctly" do
      emotion = Emotion.create!(valid_attributes)
      found = Emotion.find(emotion.id)
      expect(found).to eq(emotion)
      expect(found.user).to eq(user)
    end

    it "can be updated" do
      emotion = Emotion.create!(valid_attributes)
      emotion.update!(main_emotion: "Sadness")
      expect(emotion.main_emotion).to eq("Sadness")
    end

    it "can be destroyed" do
      emotion = Emotion.create!(valid_attributes)
      expect { emotion.destroy }.to change(Emotion, :count).by(-1)
    end
  end
end
