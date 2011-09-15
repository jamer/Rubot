#!/bin/bash

ulimit -u 10
sudo -u nobody ruby1.8 start.rb $*

