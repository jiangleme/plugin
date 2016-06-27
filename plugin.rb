# name: discourse-affiliate
# about: Official affiliation plugin for Discourse
# version: 0.4
# authors: Régis Hanol (zogstrip)
# url: https://github.com/jiangleme/plugin

enabled_site_setting :affiliate_enabled

#register_asset "javascripts/affiliate_dialect.js", :server_side
#register_asset "javascripts/onebox_dialect.js", :server_side
register_asset "javascripts/discourse/dialects/autolink_dialect.js", :server_side
register_asset "javascripts/discourse/dialects/onebox_dialect.js", :server_side


require 'htmlentities'

#class Onebox::Engine::WhitelistedGenericOnebox
#      include Onebox::Engine
Onebox = Onebox

module Onebox
  module Engine
    class GeneralOnebox
      include Engine

      def self.priority
        @priority = 10
      end

      def self.whitelist=(list)
        @whitelist = list
      end

      def self.whitelist
        @whitelist ||= default_whitelist.dup
      end

      def self.default_whitelist
        %w(23hq.com
          zappos.com
          feelunique.com
          zillow.com)
      end

      # Often using the `html` attribute is not what we want, like for some blogs that
      # include the entire page HTML. However for some providers like Flickr it allows us
      # to return gifv and galleries.
      def self.default_html_providers
        ['Flickr', 'Meetup']
      end

      def self.html_providers
        @html_providers ||= default_html_providers.dup
      end

      def self.html_providers=(new_provs)
        @html_providers = new_provs
      end

      # A re-written URL coverts http:// -> https://
      def self.rewrites
        @rewrites ||= https_hosts.dup
      end

      def self.rewrites=(new_list)
        @rewrites = new_list
      end

      def self.https_hosts
        %w(slideshare.net dailymotion.com livestream.com)
      end

      def self.host_matches(uri, list)
        !!list.find {|h| %r((^|\.)#{Regexp.escape(h)}$).match(uri.host) }
      end

      def self.probable_discourse(uri)
        !!(uri.path =~ /\/t\/[^\/]+\/\d+(\/\d+)?(\?.*)?$/)
      end

      def self.probable_wordpress(uri)
        !!(uri.path =~ /\d{4}\/\d{2}\//)
      end

      def self.===(other)
        if other.kind_of?(URI)
          return WhitelistedGenericOnebox.host_matches(other, WhitelistedGenericOnebox.whitelist) ||
                 WhitelistedGenericOnebox.probable_wordpress(other) ||
                 WhitelistedGenericOnebox.probable_discourse(other)
        else
          super
        end
      end



      def rewrite_https(html)
        return html unless html
        uri = URI(@url)
        if WhitelistedGenericOnebox.host_matches(uri, WhitelistedGenericOnebox.rewrites)
          html.gsub!(/http:\/\//, 'https://')
        end
        html
      end



      def to_html
        #rewrite_https(generic_html)
        imgur_data = get_imgur_data
        return "<a href='#{imgur_data[:url]}' target='_blank'><img src='#{imgur_data[:image]}' alt='' >#{ imgur_data[:title] }</a>" if imgur_data[:image]
        return "<a href='#{imgur_data[:url]}' target='_blank'><img src='#{imgur_data[:image]}' alt='' >#{ imgur_data[:title] }</a>" 
        return nil 
      end

      def placeholder_html
        #result = nil
        #return to_html if article_type?
        #result = image_html if (data[:html] && data[:html] =~ /iframe/) || data[:video] || photo_type?
        #result || to_html
        to_html
      end

      
      private
      def get_imgur_data
        response = Onebox::Helpers.fetch_response(url)
        html = Nokogiri::HTML(response.body)
        imgur_data = {}
        html.css('meta').each do |m|
          #if m.attribute('property') && m.attribute('property').to_s.match(/^og:/i)
          if m.attribute('property')
            m_content = m.attribute('content').to_s.strip
            m_property = m.attribute('property').to_s.gsub('og:', '')
            imgur_data[m_property.to_sym] = m_content
          elsif m.attribute('name')
            m_content = m.attribute('content').to_s.strip
            m_property = m.attribute('name').to_s
            imgur_data[m_property.to_sym] ||= m_content
          end
        end
        return imgur_data
      end

    end
  end
end
