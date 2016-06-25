# name: discourse-affiliate
# about: Official affiliation plugin for Discourse
# version: 0.2
# authors: Régis Hanol (zogstrip)
# url: https://github.com/jiangleme/plugin

enabled_site_setting :affiliate_enabled

register_asset "javascripts/affiliate_dialect.js", :server_side
register_asset "javascripts/onebox_dialect.js", :server_side
