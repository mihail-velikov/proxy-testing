# IP-facing management API (default_server).
# Clients call https://<vm-public-ip>/api/game/url-extended/<client> with Basic Auth
# (shared username/password for all clients).

server {
    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;
    http2 on;
    server_name _;

    ssl_certificate     __API_CERT__;
    ssl_certificate_key __API_KEY__;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    location / {
        return 404 '{"status":"NOT_FOUND"}';
        default_type application/json;
    }

    # Require client suffix: /api/game/url-extended/<client>
    location = /api/game/url-extended {
        auth_basic           "proxies domain API";
        auth_basic_user_file __API_HTPASSWD__;
        default_type application/json;
        add_header Cache-Control "no-store" always;
        return 404 '{"status":"NOT_FOUND","message":"Use /api/game/url-extended/<client>"}';
    }

    location ~ ^/api/game/url-extended/([A-Za-z0-9][A-Za-z0-9_-]*)$ {
        auth_basic           "proxies domain API";
        auth_basic_user_file __API_HTPASSWD__;

        default_type application/json;
        add_header Cache-Control "no-store" always;

        # Serve /var/lib/proxies/urls/<client>.json
        rewrite ^ /urls/$1.json break;
        root __URLS_ROOT__;
    }
}
