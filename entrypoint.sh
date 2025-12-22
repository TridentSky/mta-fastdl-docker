#!/bin/bash
cd /home/container

if [ -f /opt/start.sh ]; then
    exec bash /opt/start.sh
else
    exec /bin/bash
fi
