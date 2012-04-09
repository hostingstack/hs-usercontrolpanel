module ApplicationHelper
  def errors(obj)
    return unless obj && obj.errors.any?
    error_text = "<div class=\"error-messages\">" + pluralize(obj.errors.size, "Error").split(' ')[1] + ': '
    if obj.errors.size == 1
      error_text += obj.errors.full_messages[0]
    else
      error_text += "<ul><li>" + obj.errors.full_messages.join("</li><li>") + "</li></ul>"
    end
    error_text += "</div>"
    error_text.html_safe
  end
  
  def navigation_link_to(name, options = {}, html_options = {})
    html_options[:class] = 'current' if current_page?(options)
    link_to name, options, html_options
  end
  
  def body_classes
    classes = ['controlpanel']
    classes << controller.controller_name
    classes << controller.action_name
    classes.join ' '
  end
end
