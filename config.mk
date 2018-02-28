
music_dir:=$(PWD)/music
playlist_dir:=$(PWD)/playlist
tag_cache:=$(PWD)/tag_cache
i2pd_dat:=$(PWD)/i2pd_dat
station:=mpd

define CONFIG_HEAD
\n<!doctype html>\
\n\
\n<html lang=\"en\">\
\n<head>\
\n  <meta charset=\"utf-8\">\
\n\
\n  <title>My i2p Radio Station</title>\
\n  <meta name=\"description\" content=\"My i2p Radio Station\">\
\n  <meta name=\"author\" content=\"idk\">\
\n\
\n  <link rel=\"stylesheet\" href=\"css/styles.css\">\
\n\
\n</head>\n\
\n<body>\n
endef

export CONFIG_HEAD

define CONFIG_PAGE
# My i2p Radio Station\n\
\n If you found my demo site by accident, the music comes from Kevin \
MacLeod of incompetech.com.\n\
\n## Turnkey deep web music streaming\n\
\n\
\n  * [Splash URL:](http://$(shell head -n 1 address.b32.i2p).b32.i2p)
endef

export CONFIG_PAGE

define CONFIG_INFO
\n## Client Configuration \
\n\
To listen as an http stream, you will need a client tunnel. \
To configure an client tunnel in i2pd, add the following lines to \
your /etc/i2pd/tunnels.conf file(or other tunnels.conf file per your \
configuration. \n\
\n  You can use an http proxy: \n\
\n        vlc $(shell tail -n 1 address.b32.i2p).b32.i2p \\ \
\n         --http-proxy=127.0.0.1:4444 --http-reconnect --http-continuous \n\
\n or configure tunnels: \n
endef

export CONFIG_INFO

define TUN_CONF
[RADIO$(station)]\
\ntype = http\
\nhost = pirateradio-$(station)\
\nport = 8080\
\ninport = 80\
\ninbound.length = 1\
\noutbound.length = 1\
\nkeys = radio-$(station).dat\n
endef

export TUN_CONF
