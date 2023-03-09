My laptop is Xiaoxin Pro 14, and Fedora cannot recognize my laptop's keyboard.

Solution:
In `/etc/default/grub`, change GRUB_CMDLINE_LINUX as shown below.
`GRUB_CMDLINE_LINUX="rhgb quiet i8042.dumbkbd"`
