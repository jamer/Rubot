#!/bin/bash

ulimit -u 200
sudo -u nobody ruby lib/main.rb $*

