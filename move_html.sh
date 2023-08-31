#!/bin/bash

# Move existing files
if [ -f /var/www/html/index.nginx-debian.html ]; then
  sudo rm /var/www/html/index.nginx-debian.html
fi

if [ -f /var/www/html/index.html ]; then
  sudo rm /var/www/html/index.html
fi

# Move uploaded file
sudo mv index.html /var/www/html/
