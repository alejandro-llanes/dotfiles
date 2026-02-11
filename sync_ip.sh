#!/bin/bash
cd ~
rclone sync gdrive:sync_ip sync_ip --metadata
