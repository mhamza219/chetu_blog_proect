module OrdersHelper
  def status_badge(status)
    case status
    when 'paid'
      content_tag(:span, "Paid", class: "badge badge-success p-2 text-white")
    when 'pending'
      content_tag(:span, "Pending", class: "badge badge-warning p-2 text-dark")
    else
      content_tag(:span, status.titleize, class: "badge badge-secondary p-2")
    end
  end
end