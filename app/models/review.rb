class Review < ApplicationRecord
  belongs_to :product
  belongs_to :user

  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5, only_integer: true }
  validates :comment, presence: true, length: { maximum: 1000 }

  # レビューが作成された後に商品の平均評価を更新するコールバック
  after_create_commit :update_product_average_rating_job
  after_destroy_commit :update_product_average_rating_job # 削除時も更新

  private

  def update_product_average_rating_job
    # 実際のアプリケーションではバックグラウンドジョブで実行することを推奨
    # (例: UpdateProductAverageRatingJob.perform_later(product_id))
    product.update_average_rating! if product.present?
  end
end
