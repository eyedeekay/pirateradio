
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
		-p 127.0.0.1:6601:6601 \
		--volume $(music_dir):/var/lib/mpd/music:rw \
		--volume $(playlist_dir):/var/lib/mpd/playlist:rw \
		--volume $(tag_cache):/var/lib/mpd/tag_cache:rw \
		eyedeekay/pirateradio-mpd


run-website: network
	docker run -d --name pirateradio-splash \
		--network pirateradio \
		--network-alias pirateradio-splash \
		--hostname pirateradio-splash \
		eyedeekay/pirateradio-splash\


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
	@echo "$(TUN_CONF)" | tee -a tunnels.conf

mpc-playlist:
	mpc -h 127.0.0.1 -p 6601 ls | mpc -h 127.0.0.1 -p 6601 add
	mpc -h 127.0.0.1 -p 6601 play
	mpc -h 127.0.0.1 -p 6601 repeat on
	mpc -h 127.0.0.1 -p 6601 random on

eepsite-address-splash:
	./bin/ii-tunlist | \
		grep "RADIOSPLASH" | \
		sed "s|RADIOSPLASH||g" | tr -d ' ' | tee .address.b32.i2p

eepsite-address:
	rm -f address.b32.i2p .address.b32.i2p
	make eepsite-address-splash
	make eepsite-address-radio

eepsite-address-radio:
	./bin/ii-tunlist | \
		grep "RADIO$(station)" | \
		sed "s|RADIO$(station)||g" | tr -d ' ' | tee -a .address.b32.i2p


eepsite-linkfile: eepsite-address
	@echo http://$(shell head -n 1 .address.b32.i2p).b32.i2p | tee address.b32.i2p #&& rm .address.b32.i2p
	@echo http://$(shell tail -n 1 .address.b32.i2p).b32.i2p | tee -a address.b32.i2p #&& rm .address.b32.i2p

eepsite-content:
	curl http://127.0.0.1:7099/mpd.ogg | ffplay

eepsite-curl:
	/usr/bin/curl -x 127.0.0.1:4444 $(shell head -n 1 address.b32.i2p)

md:
	@echo "$(CONFIG_PAGE)"

html:
	make -s md | markdown | tee index.html

site: eepsite-linkfile
	make -s md | markdown | tee index.html
	make restart-website

diffsite:
	/usr/bin/curl -x 127.0.0.1:4444 $(shell head -n 1 address.b32.i2p) > .index.html
	diff .index.html index.html && rm .index.html
