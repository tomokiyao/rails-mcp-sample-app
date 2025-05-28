class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :price_at_purchase, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # 注文時に価格を固定するため、product.priceではなくprice_at_purchaseを使用
  def subtotal
    price_at_purchase * quantity
  end

  # OrderItem作成時にProductの価格をprice_at_purchaseに保存する例
  before_validation :set_price_at_purchase, on: :create

  private

  def set_price_at_purchase
    self.price_at_purchase ||= product&.price if product.present?
  end
end
