ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  if instance.instance_variable_get(:@options)[:hide_errors]
    html_tag
  else
    "<div class=\"field_with_errors\">#{html_tag}</div>".html_safe
  end
end
