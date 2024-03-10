#!/bin/sh

wd=$(realpath $(dirname $0)) || exit $?

if [ ${wd} == /etc/nixos ]; then
  echo 'nothing to do'
  exit 0
fi

sudo mv /etc/nixos/configuration.nix ${wd}/configuration.nix.bak
sudo mv /etc/nixos/hardware-configuration.nix ${wd}/

sudo rmdir /etc/nixos
sudo mv ${wd} /etc/nixos

echo 'do not forget checking the bootloader setting in configuration.nix'
