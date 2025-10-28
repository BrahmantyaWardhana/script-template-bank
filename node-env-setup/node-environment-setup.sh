#!/usr/bin/env bash

sudo apt update && sudo apt upgrade -y
sudo apt install npm
sudo npm install -g n
sudo n stable