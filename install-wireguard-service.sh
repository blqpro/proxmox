#!/bin/bash
#copy vpn.service to the right directory for systemctl services
sudo cp vpn.service /etc/systemd/system
#enable and start the service for every startup
sudo systemctl enable vpn.service
sudo systemctl start vpn.service
