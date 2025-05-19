class Esteem < ActiveRecord::Base
  belongs_to :user, dependent: :destroy

  validates :esteem, presence: true
end
