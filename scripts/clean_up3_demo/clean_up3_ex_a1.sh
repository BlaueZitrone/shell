#!/bin/bash

find "$TMP" -name "CR_S*" -atime +1 -exec /opt/sfw/bin/rm $1 {} \;
