#!/bin/bash

# Same structure as `/etc/mesosphere/roles` for now.
new-item -ItemType Directory -Force "$env:PKG_PATH\etc_master\roles\master"
new-item -ItemType Directory -Force "$env:PKG_PATH\etc_slave\roles\slave"
new-item -ItemType Directory -Force "$env:PKG_PATH\etc_slave_public\roles\slave_public"
