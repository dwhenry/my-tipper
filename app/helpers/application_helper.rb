module ApplicationHelper
  def current_selection(fixture, pick_value, force: false)
    if pick_value.blank? or pick_value == 0
      force ? 'Draw' : ''
    elsif pick_value < 0
      "#{fixture.home.short_name} by #{pick_value.to_i.abs}"
    else
      "#{fixture.away.short_name} by #{pick_value.to_i.abs}"
    end
  end

  def correct_team(fixture, pick)
    return '' unless fixture.result && pick
    return 'incorrect-pick' if fixture.result == 0 || pick == 0
    pick.to_f / fixture.result > 0 ? 'correct-pick' : 'incorrect-pick'
  end

  def current_path(changes={})
    uri = URI(request.env['REQUEST_URI'])
    existing_params = URI.decode_www_form(uri.query || '')
    new_params = changes.each_with_object(Hash[existing_params]) do |(k, v), h|
      if v.blank?
        h.delete(k.to_s)
      else
        h[k.to_s] = v
      end
    end
    uri.query       = URI.encode_www_form(new_params.to_a)
    uri.to_s
  end

  def render_errors(form, field)
    return if form.object.valid?
    errors = form.object.errors.full_messages_for(field)
    return unless errors
    content_tag('div', errors.join('. '), class: 'field_with_errors red bold')
  end
end
