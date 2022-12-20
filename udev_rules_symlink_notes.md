# UDEV Rules

1. Know your USB device attribute

    Know the attribute of a target USB device using the `udevadm` 

    ``` bash
    udevadm info --atribute-walk --name=/dev/tty****
    ```

2. Create a udev rules file  with number in the prefix of the file name indicating the priority of the rules, lower the number hihger the priority. e.g `XX-filename.rules`

    In our case, we created a file name `100-usb-device.rules`, since we creating a sym link for the usb ports, we would like this rules to get executed once all the high priority rules are done executed.

3. Looking at USB device info 
    >```
    >looking at device '/devices/pci0000:00/0000:00:08.1/0000:05:00.3/usb1/1-1/1-1.2/1-1.2:1.0/ttyUSB0/tty/ttyUSB0':
    >    KERNEL=="ttyUSB0"
    >    SUBSYSTEM=="tty"
    >    DRIVER==""
    >```

    >```
    >looking at parent device '/devices/pci0000:00/0000:00:08.1/0000:05:00.3/usb1/1-1/1-1.2/1-1.2:1.0/ttyUSB0':
    >    KERNELS=="ttyUSB0"
    >    SUBSYSTEMS=="usb-serial"
    >    DRIVERS=="cp210x"
    >    ATTRS{port_number}=="0"
    >```

    >```
    >looking at parent device '/devices/pci0000:00/0000:00:08.1/0000:05:00.3/usb1/1-1/1-1.2/1-1.2:1.0':
    >    KERNELS=="1-1.2:1.0"
    >    SUBSYSTEMS=="usb"
    >    DRIVERS=="cp210x"
    >    ATTRS{bInterfaceSubClass}=="00"
    >    ATTRS{supports_autosuspend}=="1"
    >    ATTRS{bInterfaceNumber}=="00"
    >    ATTRS{interface}=="CP2102 USB to UART Bridge Controller"
    >    ATTRS{bNumEndpoints}=="02"
    >    ATTRS{authorized}=="1"
    >    ATTRS{bAlternateSetting}==" 0"
    >    ATTRS{bInterfaceClass}=="ff"
    >    ATTRS{bInterfaceProtocol}=="00"
    >```

4. If you see the third segment and line `KERNELS=="1-1.2:1.0"` gives us the information thats very useful to know.
    > KERNELS=="`1-1.2`:1.0" 
    
    We can infer that in our case, its a USB c port connected to USB hub with 4xUSB A port connected to our target device.

    `1-1.2` in dicates the the very structure of device tree. We can use this information to target a particular port and create a symlink

5. Find the unique attributes and values, use that to assign a custom name for the devices. e.g:
    >```
    >ACTION=="add", SUBSYSTEMS=="usb", ATTRS{serial}=="383250410D303733", SYMLINK+="RemoteTranseiver"
    >```

6. In our use case, we use silicon labs generic USB to TTL serial device and they have no unique id or attribute to differenciate one from another, so rather than assigning a name based on the target device, we assign names to the port that it connects to. e.g:

    >```
    >ACTION=="add", SUBSYSTEMS=="usb", KERNELS=="1-1.1:1.0", SYMLINK+="RobotClaw"
    >```

7. Make the .rules file executable and reload  the udev rules using the following command 
    >```
    >sudo chmod 0644 XX-filename.rules
    >```

    >```
    >sudo udevadm control --reload-rules && udevadm trigger
    >```

    >```
    >sudo service udev restart
    >```

8. Now if you unplug and plug the devices back, their symlinks will be listed upon hitting `ls /dev/*`