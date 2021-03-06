
usage:
	@echo 'usage:'
	@echo '======'
	@echo
	@echo ' install: make install'
	@echo ' reinstall without purging some settings: make reinstall'
	@echo ' re-generate all settings: make clobber install'
	@echo
	@echo 'Configured Directories'
	@echo '----------------------'
	@echo
	@echo "  * Station $(station)"
	@echo "  * Host Music Directory $(music_dir)"
	@echo "  * Host Playlist Directory $(playlist_dir)"
	@echo "  * Host Tag Cache Directory $(tag_cache)"
	@echo "  * Host I2PD Data Directory $(i2pd_dat)"
	@echo
	@echo "Page Configuration"
	@echo "------------------"
	@echo
	@echo "$(CONFIG_PAGE)"
	@echo
	@echo "Tunnel Configuration"
	@echo
	@echo "$(TUN_CONF)"
	@echo

include config.mk
include include/setup.mk

run: network run-mpd run-eepsite run-website

run-mpd: network
	docker run -d --name pirateradio-$(station) \
		--network pirateradio \
		--network-alias pirateradio-$(station) \
		--hostname pirateradio-$(station) \
		-p 127.0.0.1:$(port):$(port) \
		--volume $(music_dir):/var/lib/mpd/music:rw \
		--volume $(playlist_dir):/var/lib/mpd/playlist:rw \
		--volume $(tag_cache):/var/lib/mpd/tag_cache:rw \
		--restart always \
		eyedeekay/pirateradio-mpd


run-website: network
	docker run -d --name pirateradio-splash \
		--network pirateradio \
		--network-alias pirateradio-splash \
		--hostname pirateradio-splash \
		--restart always \
		eyedeekay/pirateradio-splash


run-eepsite: network
	docker run -d --name pirateradio-eepsite \
		--network pirateradio \
		--network-alias pirateradio-eepsite \
		--hostname pirateradio-eepsite \
		--expose 4567 \
		--link pirateradio-splash \
		--link pirateradio-mpd \
		-p :4567 \
		-p 127.0.0.1:7071:7071 \
		--volume $(i2pd_dat):/var/lib/i2pd:rw \
		--restart always \
		eyedeekay/pirateradio-eepsite

new-tunconf:
	@echo | tee tunnels.conf
	@echo '[RADIOSPLASH]' | tee -a tunnels.conf
	@echo 'type = http' | tee -a tunnels.conf
	@echo 'host = pirateradio-splash' | tee -a tunnels.conf
	@echo 'port = 8081' | tee -a tunnels.conf
	@echo 'inport = 80' | tee -a tunnels.conf
	@echo 'inbound.length = 1' | tee -a tunnels.conf
	@echo 'outbound.length = 1' | tee -a tunnels.conf
	@echo 'keys = radio-splash.dat' | tee -a tunnels.conf
	@echo | tee -a tunnels.conf


tunconf:
	cat tunnels.conf | tr '\n' ' ' | grep "$(station)" || \
	echo "$(TUN_CONF)" | tee -a tunnels.conf

mpc-playlist:
	mpc -h 127.0.0.1 -p $(port) ls | mpc -h 127.0.0.1 -p $(port) add
	mpc -h 127.0.0.1 -p $(port) play
	mpc -h 127.0.0.1 -p $(port) repeat on
	mpc -h 127.0.0.1 -p $(port) random on

eepsite-address-splash:
	./bin/ii-tunlist | \
		grep "RADIOSPLASH" | \
		sed "s|RADIOSPLASH||g" | tr -d ' ' | tee -a .address.b32.i2p

eepsite-address-radio:
	./bin/ii-tunlist | \
		grep "RADIO$(station)" | \
		sed "s|RADIO$(station)||g" | tr -d ' ' | tee -a .address.b32.i2p

eepsite-address:
	make eepsite-address-splash
	make eepsite-address-radio
	cat -n .address.b32.i2p | sort -uk2 | sort -nk1 | cut -f2- | tee address.b32.i2p
	cp address.b32.i2p .address.b32.i2p

eepsite-linkfile: eepsite-address

eepsite-content:
	curl http://127.0.0.1:7099/mpd.ogg | ffplay

eepsite-curl:
	/usr/bin/curl -x 127.0.0.1:4444 $(shell head -n 1 address.b32.i2p).b32.i2p

tail: eepsite-address
	@echo "$(shell tail -n $(shell make -s expr) address.b32.i2p )" | tr ' ' '\n' | tee stations.txt

expr:
	expr $(shell wc -l address.b32.i2p | sed 's| address.b32.i2p||g') - 1

md:
	@echo "$(CONFIG_PAGE)"
	./bin/link-helper
	@echo "$(CONFIG_INFO)"
	./bin/config-helper

html:
	make head-helper
	make -s md | markdown | tee index.html
	@echo '</body>' | tee -a index.html

link-helper:
	./bin/link-helper | markdown | tee -a index.html

config-helper:
	./bin/config-helper | markdown | tee -a index.html

head:
	@echo "$(CONFIG_HEAD)"

head-helper:
	@echo "$(CONFIG_HEAD)" | tee index.html

site: eepsite-linkfile tail
	make head-helper
	make -s md | markdown | tee -a index.html
	@echo '</body>' | tee -a index.html
	make restart-website

diffsite:
	/usr/bin/curl -x 127.0.0.1:4444 $(shell head -n 1 address.b32.i2p) > .index.html
	diff .index.html index.html && rm .index.html

dist-config-helper:
	mkdir -p downloads
	./bin/config-helper | sed 's|        ||g' | tee downloads/tunnels.client.conf

visit:
	http_proxy='http://127.0.0.1:4443' /usr/bin/surf 'http://gkso46tc47hdua2kva5zahj3unmyh6ia7bv5oc2ybn2hmeowpz7a.b32.i2p'

visit-classic:
	http_proxy='http://127.0.0.1:4444' /usr/bin/surf 'http://gkso46tc47hdua2kva5zahj3unmyh6ia7bv5oc2ybn2hmeowpz7a.b32.i2p'
