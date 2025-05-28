class OrderMailer < ApplicationMailer
  default from: "noreply@example.com"

  def order_confirmation(order)
    @order = order
    @user = order.user
    mail(to: @user.email, subject: "【MCPサンプルショップ】ご注文ありがとうございます")
  end
end
