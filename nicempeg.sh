#!/bin/sh

exec /usr/bin/nice -n 19 /usr/bin/ffmpeg "$@"
