#!/bin/bash

ulimit -u 200
sudo -u nobody ruby1.9 lib/main.rb $*

