#!/bin/bash

ulimit -u 10
sudo -u nobody ruby start.rb $*

