
(function() {

  var AMAZON_LINK_REGEX = /((?:https?:)?(?:\/\/)?(?:www\.)?amazon\.[^\b\s"'<>()]+)/ig;
  var AMAZON_DOMAIN_EXTRACTOR_REGEX = /amazon\.([^\?\/]{2,})/i;
  var AMAZON_ASIN_EXTRACTOR_REGEX = /\/([A-Z0-9]{10})(?:[\?\/%]|$)/i;

  Discourse.Dialect.addPreProcessor(function(text) {
    if (Discourse.SiteSettings.affiliate_enabled) {
      text = text.replace(AMAZON_LINK_REGEX, function(href) {
        if (AMAZON_DOMAIN_EXTRACTOR_REGEX.test(href)) {
          var domain = AMAZON_DOMAIN_EXTRACTOR_REGEX.exec(href)[1];
          if (AMAZON_ASIN_EXTRACTOR_REGEX.test(href)) {
            var asin = AMAZON_ASIN_EXTRACTOR_REGEX.exec(href)[1];
            href = "https://www.amazon." + domain + "/dp/" + asin;
            if (Discourse.SiteSettings.affiliate_amazon_tag.length > 0) {
              href += "?tag=" + Discourse.SiteSettings.affiliate_amazon_tag;
            }
          }
        }
        return href;
      });
    }
    return text;
  });

})();

(function() {
    console.log("begin");
Discourse.Dialect.on("parseNode", function(event) {
    console.log("begin---");
    var node = event.node;

    // We only care about links
    if (node[0] !== 'a')  { return; }
    var url = node[1].href
    if(url.indexOf("mmqqg.com")>0) return true;

    node[1].href = "http://www.mmqqg.com/j?url=" + encodeURIComponent(url);
  })
}) ();
