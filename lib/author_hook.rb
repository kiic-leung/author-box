require "#{RAILS_ROOT}/vendor/plugins/gravatar/lib/gravatar"

class AuthorHook  < Redmine::Hook::ViewListener
    include GravatarHelper::PublicMethods

    def view_layouts_base_html_head(context = {})
        stylesheet_link_tag('author', :plugin => 'author')
    end

    def view_layouts_base_sidebar(context = {})
        box = ''
        if context[:project].present? &&
           (context[:controller].is_a?(ProjectsController) ||
            context[:controller].is_a?(WikiController))
            settings = Setting.plugin_author_plugin
            if settings[:author_role_id].present?
                role = Role.find_by_id(settings[:author_role_id])
                members = context[:project].members.select {|m| m.roles.detect {|r| r.id == role.id}}.collect {|m| m.user}.sort
                if members.count > 0
                    box += content_tag(:h3, h(role))
                    members.each do |member|
                        avatar = avatar(member, :size => members.count == 1 ? "100" : "80")
                        link = content_tag(:span, link_to_user(member, :class => 'user'),
                            :class => members.count == 1 ? 'author' : 'author small')
                        profile = ''
                        hooks = Redmine::Hook.call_hook(:view_sidebar_author_box_bottom, :user => member, :count => members.count)
                        hooks.each do |hook|
                            profile += hook
                        end
                        box += content_tag(:div, avatar + link + profile, :class => members.count == 1 ? 'author box' : 'author box small')
                    end
                end
            end
        end
        return box
    end

end
