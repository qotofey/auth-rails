class User < ApplicationRecord
  has_many :credentials, class_name: "UserCredential", dependent: :destroy

  # enum gender: {
  #   male: "male",
  #   female: "female"
  # }
end
