(function() {
    console.log("begin");
Discourse.Dialect.on("parseNode", function(event) {
    console.log("begin---");
    var node = event.node;

    // We only care about links
    if (node[0] !== 'a')  { return; }
    var url = node[1].href
    if(url.indexOf("mmqqg.com")>0) return true;
    if(url.toLowerCase().match(/jpg|png|gif|jpeg$/)) return true;

    node[1].href = "http://www.mmqqg.com/j?url=" + encodeURIComponent(url);
    node[1].ohref = url;
  })
}) ();
