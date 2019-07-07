mkdir -p /tmp/lmapd/
lmapd -j -b capabilities.json -r /var/run -q /tmp/lmapd/ -c lmapd-config.json -f
