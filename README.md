# pirateradio

Docker containers packaging an mpd based internet radio station and transmitting
it over i2p.

## Explanation

I was always a big fan of Zoidberg's 'Deep Web Radio' services, they're still
around and still cool(also not hard to find. I'll post a link here soon.). But
I wanted to be able to do it myself, and host my own deep web radio services,
and make it easy for others to do so too. To that end, this set of scripts
creates three Docker containers, each running one of the tools necessary to make
a radio station accessible over i2p.

## Usage

First, clone the repository and enter the directory

        git clone https://github.com/eyedeekay/pirateradio
        cd pirateradio

Now, run the script to generate the basic configuration files and start the
services:

        make install

Finally, add some music into the "music" directory. You can change the location
of the music directory by setting the music_dir environment variable. You will
need to use sudo to copy the music into the folder, as it's a docker volume and
mpd needs to control it in the container.

        sudo cp *.ogg music/

When you're ready, run mpc to re-generate the playlist.

        make mpc-start

## Adding More Stations

In order to change the station, simply change the environment variables to point
to a new library. These are in the config.mk file, at the top. You won't need to
change the i2pd_dat environment variable, as this is shared between all the
radio stations. The variables you'll need to change(and their defaults) are as
follows:

        music_dir:=$(PWD)/music
        playlist_dir:=$(PWD)/playlist
        tag_cache:=$(PWD)/tag_cache
        station:=mpd

A script has been provided to help you set up radio stations on the fly, in
bin/pirateradio. Running it with no arguments will create a random radio station
with no music.

