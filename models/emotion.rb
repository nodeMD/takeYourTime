class Emotion < ActiveRecord::Base
  belongs_to :user

  validates :user, presence: true
  validates :main_emotion, presence: true
  validates :strength, presence: true
  validates :emotion, presence: true
end
