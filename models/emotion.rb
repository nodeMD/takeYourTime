class Emotion < ActiveRecord::Base
  belongs_to :user
  validates :main_emotion, :strength, :emotion, presence: true
end
