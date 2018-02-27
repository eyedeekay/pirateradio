
music_dir:=$(PWD)/music
playlist_dir:=$(PWD)/playlist
tag_cache:=$(PWD)/tag_cache
i2pd_dat:=$(PWD)/i2pd_dat
station:=mpd

define CONFIG_PAGE
# My i2p Radio Station\n\
\n If you found my demo site by accident, the music comes from Kevin \
MacLeod of incompetech.com.\n\
\n## Turnkey deep web music streaming\n\
\n\
\n  * [Splash URL:]($(shell tail -n 1 address.b32.i2p))\n\
\n  * [Stream URL:]($(shell head -n 1 address.b32.i2p))\n\
\n## Client Configuration \
\n\
To listen as an http stream, you will need a client tunnel. \
To configure an client tunnel in i2pd, add the following lines to \
your /etc/i2pd/tunnels.conf file(or other tunnels.conf file per your \
configuration. \n\
\n        [radioone-client] \
\n        type = client \
\n        address = 127.0.0.1 \
\n        port = 7099 \
\n        destination = $(shell head -n 1 address.b32.i2p | sed 's|http://||g') \
\n        destinationport = 80 \
\n        inbound.length = 1 \
\n        keys = radioone-client.dat \
\n        matchtunnels = true \n\
\n  You can also use an http proxy: \n\
\n        vlc $(shell head -n 1 address.b32.i2p) \\ \
\n         --http-proxy=127.0.0.1:4444 --http-reconnect --http-continuous
endef

export CONFIG_PAGE

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
