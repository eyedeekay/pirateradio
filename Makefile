
usage:
	@echo 'usage:'
	@echo '======'
	@echo
	@echo ' install: make install'
	@echo ' reinstall without purging some settings: make reinstall'
	@echo ' re-generate all settings: make clobber reinstall'
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

include config.mk
include include/setup.mk

run: network run-mpd run-eepsite run-website

run-mpd: network
	docker run -d --name pirateradio-mpd \
		--network pirateradio \
		--network-alias pirateradio-mpd \
		--hostname pirateradio-mpd \
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

mpc-playlist:
	mpc -h 127.0.0.1 -p 6601 ls | mpc -h 127.0.0.1 -p 6601 add
	mpc -h 127.0.0.1 -p 6601 play
	mpc -h 127.0.0.1 -p 6601 repeat on
	mpc -h 127.0.0.1 -p 6601 random on

eepsite-address:
	rm -f address.b32.i2p .address.b32.i2p
	/usr/bin/lynx -dump -listonly 127.0.0.1:7071/?page=i2p_tunnels | \
		grep 'destination&b32' | \
		sed 's| 8||g' | sed 's| 9||g' | sed 's| 10||g' | sed 's| 11||g' | sed 's| 12||g' |\
		tr -d '. ' | \
		sed 's|http://127001:7071/?page=local_destination&b32=||g' | tee .address.b32.i2p

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
	/usr/bin/curl -x 127.0.0.1:4444 $(shell tail -n 1 address.b32.i2p) > .index.html
	diff .index.html index.html && rm .index.html
