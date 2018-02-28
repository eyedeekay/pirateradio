
install: tunconf network clean config build run
	sleep 5; make tail; make site
	make mpc-playlist

reinstall: clean-network network clean config build run
	sleep 5; make tail; make site
	make mpc-playlist

config:
	mkdir -p $(music_dir) $(playlist_dir) $(tag_cache) $(i2pd_dat) $(station)

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
	docker build -f Dockerfiles/Dockerfile.mpd -t eyedeekay/pirateradio-mpd .

build-website:
	touch index.html
	docker build -f Dockerfiles/Dockerfile.splash -t eyedeekay/pirateradio-splash .

build-eepsite:
	docker build -f Dockerfiles/Dockerfile.eepsite -t eyedeekay/pirateradio-eepsite .

clean: clean-mpd clean-website clean-eepsite

clean-mpd:
	docker rm -f pirateradio-mpd; true

clean-website:
	docker rm -f pirateradio-splash; true

clean-eepsite:
	docker rm -f pirateradio-eepsite; true

clobber:
	sudo rm -rf tag_cache i2pd_dat *.b32.i2p ./.*.b32.i2p station.txt index.html index.md
	make clean clobber-mpd clobber-website clobber-eepsite clean-network new-tunconf

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

log: log-mpd log-website log-eepsite

log-mpd:
	docker logs pirateradio-mpd

log-website:
	docker logs pirateradio-splash

log-eepsite:
	docker logs pirateradio-eepsite
