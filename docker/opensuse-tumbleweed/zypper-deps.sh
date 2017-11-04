#!/usr/bin/env bash

zypper -n in $(rpmspec -q $1 --buildrequires)
