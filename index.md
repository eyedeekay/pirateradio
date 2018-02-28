gkso46tc47hdua2kva5zahj3unmyh6ia7bv5oc2ybn2hmeowpz7a
epdldsx4sk6vu5bsv5mlujr3fiblptiyzb5qosaegoamo6jxgada
gkso46tc47hdua2kva5zahj3unmyh6ia7bv5oc2ybn2hmeowpz7a
epdldsx4sk6vu5bsv5mlujr3fiblptiyzb5qosaegoamo6jxgada
epdldsx4sk6vu5bsv5mlujr3fiblptiyzb5qosaegoamo6jxgada

My i2p Radio Station
====================

If you found my demo site by accident, the music comes from Kevin
MacLeod of incompetech.com.

Turnkey deep web music streaming
--------------------------------

-   [Splash
    URL:](http://gkso46tc47hdua2kva5zahj3unmyh6ia7bv5oc2ybn2hmeowpz7a.b32.i2p)
-   [RADIOmpd](http://epdldsx4sk6vu5bsv5mlujr3fiblptiyzb5qosaegoamo6jxgada.b32.i2p)

Client Configuration
--------------------

To listen as an http stream, you will need a client tunnel. To configure
an client tunnel in i2pd, add the following lines to your
/etc/i2pd/tunnels.conf file(or other tunnels.conf file per your
configuration.

You can use an http proxy:

        vlc epdldsx4sk6vu5bsv5mlujr3fiblptiyzb5qosaegoamo6jxgada \ 
         --http-proxy=127.0.0.1:4444 --http-reconnect --http-continuous \m

or configure tunnels

        [RADIOmpd-client]
        type = client
        address = 127.0.0.1
        port = 7090
        destination = epdldsx4sk6vu5bsv5mlujr3fiblptiyzb5qosaegoamo6jxgada.b32.i2p
        destinationport = 80
        inbound.length = 1
        keys = radioone-client.dat
        matchtunnels = true
