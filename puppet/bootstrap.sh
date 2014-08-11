#!/bin/bash

# Grab the latest Puppet package for Ubuntu 12.04 Precise Pangolin (LTS)
sudo wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
sudo dpkg -i puppetlabs-release-precise.deb

# Update the package manager
sudo apt-get update

# Install the standalone Puppet agent
sudo apt-get install -y puppet-common