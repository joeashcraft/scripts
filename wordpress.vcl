backend default {
    .host = "127.0.0.1";
    .port = "8080";
}
backend master {
 .host = "10.x.x.x";
 .port = "80";
}
acl purge {
        "localhost";
}
sub vcl_recv {
    if (req.request == "PURGE") {
        if (!client.ip ~ purge) {
            error 405 "Not allowed.";
        }
        return(lookup);
    }
    if (req.restarts == 0) {
        if (req.http.x-forwarded-for) {
            set req.http.X-Forwarded-For =
            req.http.X-Forwarded-For + ", " + client.ip;
        } else {
            set req.http.X-Forwarded-For = client.ip;
        }
    }
    
    ## prevents admin-ajax requests pounding the master server due to the next rule. kind of experimental but so far, so good.
    if (req.url ~ "admin-ajax" && req.http.Content-Type !~ "multipart/form-data")
    {
       return(pass);
    }

    ### woocommerce config
    if (req.url ~ "^/(cart|my-account|checkout|addons)") {
        return (pass);
    }
    if ( req.url ~ "\?add-to-cart=" ) {
        return (pass);
    }
    
    ### do not cache these files:
    ##never cache the admin pages, or the server-status page
    if (req.url ~ "wp-(admin|login)" || req.http.Content-Type ~ "multipart/form-data")
    {
        set req.backend = master;
        return(pass);
    }
 
    ## always cache these images & static assets
    if (req.request == "GET" && req.url ~ "\.(css|js|gif|jpg|jpeg|bmp|png|ico|img|tga|wmf)$") {
        remove req.http.cookie;
        return(lookup);
    }
    if (req.request == "GET" && req.url ~ "(xmlrpc.php|wlmanifest.xml)") {
        remove req.http.cookie;
        return(lookup);
    }
 
    #never cache POST requests
    if (req.request == "POST")
    {
        return(pass);
    }
    #DO cache this ajax request
    if(req.http.X-Requested-With == "XMLHttpRequest" && req.url ~ "recent_reviews")
    {
        return (lookup);
    }
 
    #dont cache ajax requests
    if(req.http.X-Requested-With == "XMLHttpRequest" || req.url ~ "nocache" || req.url ~ "(control.php|wp-comments-post.php|wp-login.php|bb-login.php|bb-reset-password.php|register.php)")
    {
        return (pass);
    }
 
    if (req.http.Cookie && req.http.Cookie ~ "wordpress_") {
        set req.http.Cookie = regsuball(req.http.Cookie, "wordpress_test_cookie=", "; wpjunk=");
    }
    ### don't cache authenticated sessions
    if (req.http.Cookie && req.http.Cookie ~ "(wordpress_|PHPSESSID)") {
        return(pass);
    }
 
    ### parse accept encoding rulesets to make it look nice
    if (req.http.Accept-Encoding) {
        if (req.http.Accept-Encoding ~ "gzip") {
            set req.http.Accept-Encoding = "gzip";
        } elsif (req.http.Accept-Encoding ~ "deflate") {
            set req.http.Accept-Encoding = "deflate";
        } else {
            # unkown algorithm
            remove req.http.Accept-Encoding;
        }
    }
 
 
    if (req.http.Cookie)
    {
        set req.http.Cookie = ";" + req.http.Cookie;
        set req.http.Cookie = regsuball(req.http.Cookie, "; +", ";");
        set req.http.Cookie = regsuball(req.http.Cookie, ";(vendor_region|PHPSESSID|themetype2)=", "; \1=");
        set req.http.Cookie = regsuball(req.http.Cookie, ";[^ ][^;]*", "");
        set req.http.Cookie = regsuball(req.http.Cookie, "^[; ]+|[; ]+$", "");
 
        if (req.http.Cookie == "") {
            remove req.http.Cookie;
        }
    }
    if (req.url ~ "^/$") {
        unset req.http.cookie;
    }
    return(lookup);
}
sub vcl_hit {
    if (req.request == "PURGE") {
        set obj.ttl = 0s;
        error 200 "Purged.";
    }
}

sub vcl_hash {
  ## Keep a separate cache for HTTP and HTTPS requests that come in over an SSL Terminated Load Balancer
    if (req.http.x-forwarded-proto) {
        hash_data(req.http.x-forwarded-proto);
    }
}

sub vcl_miss {
    if (req.request == "PURGE") {
        error 404 "Not in cache.";
    }
    if (!(req.url ~ "wp-(login|admin)")) {
        unset req.http.cookie;
    }
    if (req.url ~ "^/[^?]+.(jpeg|jpg|png|gif|ico|js|css|txt|gz|zip|lzma|bz2|tgz|tbz|html|htm)(\?.|)$") {
        unset req.http.cookie;
        set req.url = regsub(req.url, "\?.$", "");
    }
    if (req.url ~ "^/$") {
        unset req.http.cookie;
    }
}
 
sub vcl_pass {
    # Mark return(pass) calls.  So we can avoid the cookie stripping in vcl_fetch
    set req.http.x-pass = true;
}
 
sub vcl_fetch {
   if (req.url ~ "^/$") {
        unset beresp.http.set-cookie;
    }
    if (!(req.http.x-pass || req.url ~ "wp-(login|admin)")) {
        unset beresp.http.set-cookie;
    }
}
