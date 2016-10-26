class Project < ApplicationRecord
  include TagsConcern
  include FlagBitsConcern

  array_field :tags

  has_many :members, class_name: 'ProjectMember'
  has_many :profiles, through: :members

end
