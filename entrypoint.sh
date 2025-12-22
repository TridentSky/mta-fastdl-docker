#!/bin/bash
cd /home/container

if [ -f start.sh ]; then
    exec bash start.sh
else
    exec /bin/bash
fi
