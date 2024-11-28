#!/usr/bin/env bash
if [ -f ./check ]; then
  git pull
  sudo rm -rf /etc/nixos/*
  sudo cp -r ./machines ./modules ./stuff ./flake.lock ./flake.nix /etc/nixos/
else
  echo "change your working directory to dotfiles already"
fi
