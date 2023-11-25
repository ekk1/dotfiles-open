# Nginx fancyindex plugin

```bash
apt install libnginx-mod-http-fancyindex
# put all files under /var/www/html
```

```conf
# nginx config
server {
    listen 80;
    charset utf-8;
    root /var/www/html;
    #autoindex on;
    server_name _;
    location / {
        fancyindex on;
        fancyindex_exact_size off;
        fancyindex_footer /.fancyindex/footer.html;
        fancyindex_header /.fancyindex/header.html;
        fancyindex_css_href /.fancyindex/style.css;
        fancyindex_time_format "%B %e, %Y";
    }
}
```

