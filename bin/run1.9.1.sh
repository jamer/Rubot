#!/bin/bash

ulimit -u 10
sudo -u nobody ruby1.9.1 start.rb $*

