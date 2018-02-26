
music_dir=$(PWD)/music
playlist_dir=$(PWD)/playlist

build: build-mpd

build-mpd:
	docker build -f Dockerfile.mpd -t eyedeekay/pirateradio-mpd .

build-eepsite:
	docker build -f Dockerfile.eepsite -t eyedeekay/pirateradio-eepsite .

run: run-mpd run-eepsite

run-mpd:
	docker run -d --name pirateradio-mpd \
		--volume $(music_dir):/var/lib/mpd/music:ro \
		--volume $(playlist_dir):/var/lib/mpd/playlist:ro \
		-p 127.0.0.1:8080:8080 \
		eyedeekay/pirateradio-mpd

run-eepsite:
	docker run -d --name pirateradio-eepsite \
		-p :4567 \
		-p 127.0.0.1:7071:7071 \
		-p 127.0.0.1::8080 \
		eyedeekay/pirateradio-eepsite

clean: clean-mpd clean-eepsite

clean-mpd:
	docker rm -f pirateradio-mpd; true

clean-eepsite:
	docker rm -f pirateradio-eepsite; true

restart: restart-mpd restart-eepsite

restart-mpd: clean-mpd build-mpd run-mpd log-mpd

restart-eepsite: clean-eepsite build-eepsite run-eepsite log-eepsite

log: log-mpd log-eepsite

log-mpd:
	docker logs pirateradio-mpd

log-eepsite:
	docker logs pirateradio-eepsite

eepsite-address:
	/usr/bin/lynx -dump -listonly 127.0.0.1:7071/?page=i2p_tunnels | grep 'destination&b32' | sed 's|  9||g' | tr -d '. ' | sed 's|http://127001:7071/?page=local_destination&b32=||g' > address.b32.i2p
	@echo http://$(shell cat address.b32.i2p).b32.i2p > address.b32.i2p

md:
	@echo "My i2p Radio Station"
	@echo "===================="
	@echo
	@echo "Turnkey deep web music streaming"
	@echo "--------------------------------"
	@echo
	@echo "  * **[Stream URL:]\($(shell cat address.b32.i2p)\)**"
	@echo

site:
	make -s md | markdown > index.html
