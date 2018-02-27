make\[2\]: Entering directory '/home/dev/Downloads/pirateradio'

My i2p Radio Station
====================

If you found my demo site by accident, the music comes from Kevin
MacLeod of incompetech.com.

Turnkey deep web music streaming
--------------------------------

-   [Splash
    URL:](http://htn2vqyafzorjgtliphnymdejfztsqng64hgu3npkdldbcvj2hka.b32.i2p)

-   [Stream
    URL:](http://kcr3ilobiv5igyvrrxlw5kanwvqu2f5hcern2a3nxrwouw7zxr3q.b32.i2p)

Client Configuration
--------------------

To listen as an http stream, you will need a client tunnel. To configure
an client tunnel in i2pd, add the following lines to your
/etc/i2pd/tunnels.conf file(or other tunnels.conf file per your
configuration.

        [radioone-client] 
        type = client 
        address = 127.0.0.1 
        port = 7099 
        destination = kcr3ilobiv5igyvrrxlw5kanwvqu2f5hcern2a3nxrwouw7zxr3q.b32.i2p 
        destinationport = 80 
        inbound.length = 1 
        keys = radioone-client.dat 
        matchtunnels = true

You can also use an http proxy:

        vlc http://kcr3ilobiv5igyvrrxlw5kanwvqu2f5hcern2a3nxrwouw7zxr3q.b32.i2p \ 
         --http-proxy=127.0.0.1:4444 --http-reconnect --http-continuous

make\[2\]: Leaving directory '/home/dev/Downloads/pirateradio'
