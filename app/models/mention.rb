# == Schema Information
#
# Table name: mentions
#
#  id           :integer          not null, primary key
#  micropost_id :integer
#  user_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Mention < ActiveRecord::Base
  attr_accessible :micropost_id, :user_id
end
