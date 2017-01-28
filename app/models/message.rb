class Message < ApplicationRecord
  after_create_commit { BloadcastMessageJob.perform_later self }
end
