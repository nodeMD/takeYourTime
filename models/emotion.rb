class Emotion < ActiveRecord::Base
  belongs_to :user

  validates :user, presence: true
  validates :main_emotion, presence: true
  validates :strength, presence: true, inclusion: {in: ["weak", "moderate", "strong"]}
  validates :emotion, presence: true
end
