class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  # 注文ステータス (enum: pending: 保留中, processing: 処理中, shipped: 発送済み, delivered: 配達完了, cancelled: キャンセル)
  enum status: { pending: 0, processing: 1, shipped: 2, delivered: 3, cancelled: 4 }

  # 特定の条件下でのみキャンセル可能にするバリデーション (例)
  validate :cancellable_order, on: :update, if: :status_changed_to_cancelled?

  # 注文作成完了後にメール送信とSlack通知を行う
    after_create_commit :send_notifications

  def total_amount
    order_items.sum(&:subtotal)
  end

  private

  def send_notifications
    send_order_confirmation_email
    notify_admin_on_slack
  end

  def send_order_confirmation_email
    OrderMailer.order_confirmation(self).deliver_later # deliver_laterで非同期送信
    Rails.logger.info "Order confirmation email queued for Order ##{id} to #{user.email}"
  rescue StandardError => e
    Rails.logger.error "Failed to queue order confirmation email for Order ##{id}: #{e.message}"
  end

  def notify_admin_on_slack
    # Gemfileに gem 'slack-notifier' を追加し、bundle install が必要
    # 環境変数 SLACK_WEBHOOK_URL の設定も必要
    # 開発/テスト環境でも通知を試したい場合は、Rails.env.production? の条件を調整してください。
    return unless ENV['SLACK_WEBHOOK_URL'].present? && (Rails.env.production? || Rails.env.development?)

    begin
      notifier = Slack::Notifier.new(ENV.fetch('SLACK_WEBHOOK_URL'))
      message = <<~MESSAGE
        🎉 新規注文が入りました！
        --------------------
        注文ID: #{id}
        顧客名: #{user.name} (#{user.email})
        注文日時: #{created_at.strftime('%Y-%m-%d %H:%M:%S')}
        合計金額: #{total_amount}円
        注文内容:
      MESSAGE
      order_items.each do |item|
        message += "- #{item.product.name} × #{item.quantity} (単価: #{item.price_at_purchase}円)\n"
      end
      notifier.ping message, icon_emoji: ':shopping_cart:'
      Rails.logger.info "Slack notification sent for Order ##{id}"
    rescue StandardError => e
      Rails.logger.error "Slack notification failed for Order ##{id}: #{e.message}"
    end
  end

  def cancellable_order
    # 既に発送済み、配達完了の場合はキャンセル不可
    if status_was.in?(["shipped", "delivered"])
      errors.add(:status, "は発送済みまたは配達完了のため変更できません。")
    end
  end

  def status_changed_to_cancelled?
    status_changed?(to: "cancelled")
  end
end
