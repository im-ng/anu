#!/bin/bash

echo -e 'Backup recent dconf setting'
dconf dump / > config/dconf-settings.ini
echo -e 'Backup done'

