#!/bin/bash
set_dpi() {
# Check if input is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <DPI>"
    exit 1
fi

DPI=$1

# Backup the original .Xresources file
cp ~/.Xresources ~/.Xresources.bak

# Update or add the DPI setting in .Xresources
if grep -q "Xft.dpi:" ~/.Xresources; then
    # If Xft.dpi exists, update its value
    sed -i "s/Xft.dpi:.*/Xft.dpi: $DPI/" ~/.Xresources
else
    # If Xft.dpi doesn't exist, add it to the file
    echo "Xft.dpi: $DPI" >> ~/.Xresources
fi

# Reload Xresources
xrdb -merge ~/.Xresources

# Restart i3 in place to apply changes
i3-msg restart

echo "DPI set to $DPI and i3wm refreshed."
    
}
