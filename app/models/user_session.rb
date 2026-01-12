class UserSession < ApplicationRecord
  belongs_to :user_credential_id
end
