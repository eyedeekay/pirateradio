
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