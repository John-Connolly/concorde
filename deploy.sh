#!/bin/bash
cd /root/concorde
git pull
swift build --product Dev --configuration release
supervisorctl reload
