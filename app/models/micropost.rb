class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  default_scope -> { order(created_at: :desc) }
  validates :content, length: { maximum: 140 }, presence: true
  validates :user_id, presence: true
  validates :image, content_type: { in: %w[image/jpeg image/gif image/png], message: 'must be a valid image format' }, size: { less_than: 5.megabytes, message: 'should be less than 5 Mb' }

  def display_image
    image.variant(resize_to_limit: [500, 500])
  end
end
