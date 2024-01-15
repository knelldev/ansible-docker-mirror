#!/bin/sh

# just a little helper for emphasized/colored output
#
# usage (like echo):
#   section_echo "installing python pip..."
#
function section_echo() {
    echo ""
    echo -e "\e[1m\e[93m[$1]\e[0m"
}

# just a little helper for emphasized/colored output
#
# usage (like echo):
#   notice_echo "beware of the dogs!"
#
function notice_echo() {
    echo -e "\e[96m$1\e[0m"
}

# Load config file
#function loadconfig() {
#    if test -f /opt/scripts/config ; then
#    . /opt/scripts/config
#    fi
#}