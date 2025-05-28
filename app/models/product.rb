class Product < ApplicationRecord
  has_many :reviews, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items

  # 商品の状態 (enum: draft: 下書き, published: 公開中, archived: 販売終了)
  enum status: { draft: 0, published: 1, archived: 2 }

  # 公開中で在庫があり、価格が0より大きい商品のみを検索するスコープ
  scope :available_for_sale, -> { published.where("stock_quantity > ?", 0).where("price > ?", 0) }

  # 平均レビュー評価を更新するメソッド
  def update_average_rating!
    new_average = reviews.average(:rating).to_f.round(1)
    update(average_rating: new_average)
    Rails.logger.info "Product ##{id} average rating updated to #{new_average}"
  end
end
