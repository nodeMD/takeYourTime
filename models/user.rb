require "bcrypt"

class User < ActiveRecord::Base
  has_secure_password
  has_many :needs, dependent: :destroy
  has_many :wants, dependent: :destroy
  has_many :esteems, dependent: :destroy
  has_one :stoper, dependent: :destroy
  has_many :checklists, dependent: :destroy
  has_many :checklist_items, through: :checklists

  validates :nickname, presence: true, uniqueness: true, length: {minimum: 5}
  validates :password, length: {minimum: 8}, if: -> { new_record? || !password.nil? }
end
