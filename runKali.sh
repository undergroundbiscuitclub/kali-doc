#!/bin/bash
#
# Use --build to build the image
# Use --persistent to prevent destroying the container after exit
# No arguments will remove the container on exit
#
#
#
SSHKEY=$(cat key.pub)
VNCEXPOSE=0 # Expose VNC PORT
VNCPORT=5900 # VNC Port
VNCPWD=changeme # VNC Password
VNCDISPLAY=1920x1080
VNCDEPTH=16
NOVNCPORT=1337 # NOVNC port
MODE="-ti" # Run interactively
MAPPING="./data:/data:rw" # Use to map local folders to the container

if [ "$1" == "--build" ]
then
    docker build -t kali-doc .
else
    if [ "$1" != "--persistent" ]
    then
	MODE="--rm -ti"
    fi
    docker run \
      $MODE \
      -e SSHKEY="$SSHKEY" \
      -e VNCEXPOSE=$VNCEXPOSE \
      -e VNCPORT=$VNCPORT \
      -e VNCPWD="$VNCPWD" \
      -e VNCDISPLAY=$VNCDISPLAY \
      -e VNCDEPTH=$VNCDEPTH \
      -e NOVNCPORT=$NOVNCPORT \
      -v $MAPPING \
      kali-doc
fi
