#!/bin/bash

ulimit -u 200
sudo -u nobody ruby start.rb $*

