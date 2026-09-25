#!/bin/bash
FILEPATH="$1"
if [ -z "$FILEPATH" ];then
    exit 0
fi
if [ -f "$FILEPATH" ];then
    cat "$FILEPATH"
fi
exit 0
