require "spec_helper"
require_relative "../models/emotion"

describe Emotion do
  let(:user) { User.create!(nickname: "testuser_#{SecureRandom.hex(4)}", password: "password") }

  it "is valid with valid attributes" do
    emotion = Emotion.new(user: user, main_emotion: "Happiness", strength: "strong", emotion: "Excited")
    expect(emotion).to be_valid
  end

  it "is invalid without a user" do
    emotion = Emotion.new(main_emotion: "Happiness", strength: "strong", emotion: "Excited")
    expect(emotion).not_to be_valid
  end

  it "is invalid without a main_emotion" do
    emotion = Emotion.new(user: user, strength: "strong", emotion: "Excited")
    expect(emotion).not_to be_valid
  end

  it "is invalid without a strength" do
    emotion = Emotion.new(user: user, main_emotion: "Happiness", emotion: "Excited")
    expect(emotion).not_to be_valid
  end

  it "is invalid without an emotion" do
    emotion = Emotion.new(user: user, main_emotion: "Happiness", strength: "strong")
    expect(emotion).not_to be_valid
  end

  it "saves and retrieves correctly" do
    Emotion.create!(user: user, main_emotion: "Sadness", strength: "weak", emotion: "Discouraged")
    found = Emotion.find_by(user: user, main_emotion: "Sadness", strength: "weak", emotion: "Discouraged")
    expect(found).not_to be_nil
    expect(found.user).to eq(user)
  end
end
