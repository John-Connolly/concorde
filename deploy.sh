#!/bin/bash
cd /root/concorde && git pull
cd /root/concorde && swift build --product Dev --configuration release
supervisorctl reload
