#!/bin/bash
# This script is mainly for IdeaPad5 pro 14
# It provides hardware support to change system performance mode
# from low-power balanced performance

sysmod_low-power() {
	sudo sh -c "echo 'low-power' > /sys/firmware/acpi/platform_profile"
}

sysmod_balanced() {
	sudo sh -c "echo 'balanced' > /sys/firmware/acpi/platform_profile"
}

sysmod_performance() {
	sudo sh -c "echo 'performance' > /sys/firmware/acpi/platform_profile"
}

sysmod_show() {
	sh -c "cat /sys/firmware/acpi/platform_profile"
}
