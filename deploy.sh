#!/bin/bash
git pull
swift build --product Dev --configuration release
supervisorctl reload
