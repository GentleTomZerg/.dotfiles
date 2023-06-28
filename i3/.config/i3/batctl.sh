#!/bin/bash
# This script is mainly for Lenovo XiaoXin Pro 14. or (IdeaPad5 pro 14)
# IdeaPad5 provides hardware support to toggle Battery conservation mode
# If the the battery is charging, this option must be turned off
# or the battery will not be charged.

# Turn on:
bat_conservation_on() {
	sudo sh -c "echo 1 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"
}

# Turn off:
bat_conservation_off() {
	sudo sh -c "echo 0 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"
}
