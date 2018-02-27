
music_dir=$(PWD)/music
playlist_dir=$(PWD)/playlist
tag_cache=$(PWD)/tag_cache
i2pd_dat=$(PWD)/i2pd_dat

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
	@echo "  * Host Tag Cache Directory$(tag_cache)"
	@echo "  * Host I2PD Data Directory$(i2pd_dat)"
	@echo

install: network build run
	sleep 5; make site
	make mpc-playlist

reinstall: clean-network install

network:
	docker network create pirateradio
	@echo 'pirateradio' | tee network

log-network:
	docker network inspect pirateradio

clean-network: clean
	rm -f network
	docker network rm pirateradio; true

build: build-mpd build-website build-eepsite

build-mpd:
	docker build -f Dockerfile.mpd -t eyedeekay/pirateradio-mpd .

build-website:
	touch index.html
	docker build -f Dockerfile.splash -t eyedeekay/pirateradio-splash .

build-eepsite:
	docker build -f Dockerfile.eepsite -t eyedeekay/pirateradio-eepsite .

run: network run-mpd run-eepsite run-website

run-mpd: network
	docker run -d --name pirateradio-mpd \
		--network pirateradio \
		--network-alias pirateradio-mpd \
		--hostname pirateradio-mpd \
		--expose 8080 \
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
		eyedeekay/pirateradio-eepsite

clean: clean-mpd clean-website clean-eepsite

clean-mpd:
	docker rm -f pirateradio-mpd; true

clean-website:
	docker rm -f pirateradio-splash; true

clean-eepsite:
	docker rm -f pirateradio-eepsite; true

clobber: clean clobber-mpd clobber-website clobber-eepsite clean-network
	rm -rf tag_cache i2pd_dat

clobber-mpd:
	docker rmi -f eyedeekay/pirateradio-mpd; true

clobber-website:
	docker rmi -f eyedeekay/pirateradio-splash; true

clobber-eepsite:
	docker rmi -f eyedeekay/pirateradio-eepsite; true

restart: clean build run

restart-mpd: clean-mpd build-mpd run-mpd
	sleep 2
	make log-mpd

restart-website: clean-website build-website run-website
	sleep 2
	make log-website

restart-eepsite: clean-eepsite build-eepsite run-eepsite
	sleep 2
	make log-eepsite

log: log-mpd log-eepsite

log-mpd:
	docker logs pirateradio-mpd

log-website:
	docker logs pirateradio-splash

log-eepsite:
	docker logs pirateradio-eepsite

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
	@echo "My i2p Radio Station"
	@echo "===================="
	@echo
	@echo "Turnkey deep web music streaming"
	@echo "--------------------------------"
	@echo
	@echo "  * **[Splash URL:]($(shell tail -n 1 address.b32.i2p))**"
	@echo "  * **[Stream URL:]($(shell head -n 1 address.b32.i2p))**"
	@echo
	@echo " To listen as an http stream, you will need a client tunnel. "
	@echo "To configure an client tunnel in i2pd, add the following lines to"
	@echo "your /etc/i2pd/tunnels.conf file(or other tunnels.conf file per your"
	@echo "configuration."
	@echo
	@echo "        [radioone-client]"
	@echo "        type = client"
	@echo "        address = 127.0.0.1"
	@echo "        port = 7099"
	@echo "        destination = $(shell head -n 1 address.b32.i2p | sed 's|http://||g')"
	@echo "        destinationport = 80"
	@echo "        inbound.length = 1"
	@echo "        keys = radioone-client.dat"
	@echo "        matchtunnels = true"
	@echo
	@echo ' You can also use an http proxy:'
	@echo
	@echo "        vlc $(shell head -n 1 address.b32.i2p) \\"
	@echo "         --http-proxy=127.0.0.1:4444 --http-reconnect --http-continuous"
	@echo


site: eepsite-linkfile
	make -s md | markdown | tee index.html
	make restart-website

diffsite:
	/usr/bin/curl -x 127.0.0.1:4444 $(shell tail -n 1 address.b32.i2p) > .index.html
	diff .index.html index.html && rm .index.html
