#!/bin/bash
# Author: Sudo
# E-mail: Sudharsansci@gmail.com
# 

# INSTALL SCRIPT FOR UBUNTU 22.04 LTS
# Note if there is a '\r' command not found then run from the same folder as first_script.sh file,
# sed -i -e 's/\r$//' first_script.sh


# Get OS and Distro Info
# cat /etc/os-release | grep "VERSION_ID=" | tr -d '"' |awk -F= '/^VERSION_ID/ {print $2 }'



# First update, Upgrade and remove unnecessary files

echo "Runnig Installation script to setup work environment as $USER"
echo " "

alias sys_update="sudo -- sh -c 'apt-get -y update && apt-get -yy upgrade && apt-get -y autoremove'"

cd ~
sys_update
# clear
echo "Basic source update and upgrade completed...!"

function install_snapstore_apps(){

    echo "Installing Packages from SNAP store ..."
    echo " "
    # List of IDEs
    sudo snap install brave
    sudo snap install code --classic
    sudo snap install clion --classic
    sudo snap install goland --classic
    sudo snap install webstorm --classic
    sudo snap install pycharm-professional --classic
    sudo snap install intellij-idea-community --classic

    # Other Utilities from snap store
    sudo snap install vlc
    sudo snap install slack

    if [ $? == 0 ]; 
    then 
        echo "Snap apps installed successfully!"
        echo " "
    fi

    return 0
}

function install_essential_packages() {

    echo "Installing dev Packages ..."
    echo " "

    # Install basic packages & Dev env essentials
    sudo -- sh -c 'apt install -yy htop \
    nmap \
    git \
    curl \
    wget \
    build-essential \
    cmake \
    gcc-arm-none-eabi \
    libnewlib-arm-none-eabi \
    doxygen \
    python3'
    sudo -- sh -c 'git config --global credential.helper cache'
    sudo -- sh -c 'add-apt-repository universe'
    sudo -- sh -c 'apt -y update && apt install -yy libfuse2'

    if [ $? == 0 ]; 
    then 
        echo "nmap git curl wget build-essential cmake gcc doxygen python3 installed successfully!"
        echo " "
    fi

    return 0
}

function install_ros_humble() {
    
    echo "Installing ROS2 Humble Hawkbills ..."
    echo " "

    locale  # check for UTF-8

    sudo apt update && sudo apt install locales
    sudo locale-gen en_US en_US.UTF-8
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    export LANG=en_US.UTF-8

    locale  # verify settings

    sudo -- sh -c 'apt install -yy software-properties-common'
    sudo -- sh -c 'add-apt-repository universe'
    apt-cache policy | grep universe

    # Add ROS2 apt repository to system
    sudo -- sh -c 'apt -y update && apt install -yy curl gnupg lsb-release'
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

    # Add ROS2 Repository to the sources list
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && \
    echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

    # Update the sources list and upgrade before installing ROS2
    sudo -- sh -c 'apt -y update && apt -yy upgrade'

    sudo -- sh -c 'apt install -y ros-humble-desktop'

    if [ $? == 0 ]; 
    then 
        echo "ROS2 Humble hawksbill installed successfully!"
        gnome-terminal --tab --title "Talker" -- bash -c 'source /opt/ros/humble/setup.bash; ros2 run demo_nodes_cpp talker' 
        gnome-terminal --tab --title "Listener" -- bash -c 'source /opt/ros/humble/setup.bash; ros2 run demo_nodes_py listener' 
        echo "Demo program has started in terminal Talker and Listener as a result of successful installation"
        echo " "
    fi

    return 0

}

function install_docker() {

    echo "Installing Docker Engine ..."
    echo " "

    # Docker
    # uninstall old version
    sudo -- sh -c 'apt-get remove -yy docker docker-engine docker.io containerd runc'

    # Setup the docker repository
    sudo -- sh -c 'apt -y update && apt install -yy ca-certificates curl gnupg lsb-release'
    sudo -- sh -c 'mkdir -p -y /etc/apt/keyrings'

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Setup the repository
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo -- sh -c 'apt-get -y update && \
    apt-get install -yy docker-ce docker-ce-cli containerd.io docker-compose-plugin'

    # Install Docker Post-Installation script
    sudo -- sh -c 'groupadd docker'
    sudo usermod -aG docker $USER

    if [ $? == 0 ]; 
    then 
        echo "Docker installed successfully!, pending Reboot & verification"
        echo " "
    fi

    return 0

}


function install_docker_compose() {

    sudo -- sh -c 'curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose'
    sudo -- sh -c 'chmod +x /usr/local/bin/docker-compose'

    if [ $? == 0 ]; 
    then 
        echo "Docker compose has been successfully installed!, pending Reboot & verification"
        echo " "
    fi

    return 0
}

function install_arduinoIDE2_0() {
    
    echo "Installing Arduino IDE 2.0 App Image ..."
    echo " "

    # Arduino IDE 2.0-rc6
    sudo -- sh -c 'mkdir -p /opt/AppImage/ArduinoIDE'
    cd /opt/AppImage/ArduinoIDE

    sudo -- sh -c 'wget -c https://downloads.arduino.cc/arduino-ide/arduino-ide_2.0.0_Linux_64bit.AppImage'

    sudo -- sh -c 'chmod +x arduino-ide_2.0.0_Linux_64bit.AppImage'
    sudo -- sh -c 'touch /usr/share/applications/ArduinoIDE2.0.desktop'

    sudo -- sh -c 'echo "[Desktop Entry]\nName=ArduinoIDE2.0\nExec=/opt/AppImage/ArduinoIDE/arduino-ide_2.0.0_Linux_64bit.AppImage\nIcon=/opt/AppImage/ArduinoIDE/arduinoide_icon.png\ncomment=cloud\nType=Application\nTerminal=false\nEncoding=UTF-8\nCategories=Utility;" >> /usr/share/applications/ArduinoIDE2.0.desktop'

    cd ~

    if [ $? == 0 ]; 
    then 
        echo "Arduino IDE 2.0 installed successfully!"
        echo " "
    fi

    return 0
}

function install_google_chrome() {

    echo "Installing Google Chrome ..."
    echo " "

    # packages to be downlaoded and installed manually
    cd ~/Downloads/
    mkdir Software && cd Software

    # Google Chrome
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo -- sh -c 'dpkg -i google-chrome-stable_current_amd64.deb'
    sudo -- sh -c 'rm -f google-chrome-stable_current_amd64.deb'

    # Back to Home directory
    cd ~/.

    if [ $? == 0 ]; 
    then 
        echo " "
        echo "Google Chrome installed successfully!"
        echo " "
    fi

    return 0
}


function install_ros_humble_navigation() {
    sudo -- sh -c 'apt install ros-humble-navigation2'
    sudo -- sh -c 'apt install ros-humble-nav2-bringup'    

    if [ $? == 0 ]; 
    then 
        echo " "
        echo "ROS Navigation for humble has been installed successfully!"
        echo " "
    fi

    return 0
}

function install_ros_misc() {
    #install all turtlebot packages
    sudo -- sh -c 'apt install ros-humble-turtlebot3*'

    if [ $? == 0 ]; 
    then 
        echo " "
        echo "ROS misc has been installed successfully!"
        echo " "
    fi

    return 0
}

function install_grub_customizer() {
    # Add Grub Customizer
    sudo add-apt-repository ppa:danielrichter2007/grub-customizer 
    sudo -- sh -c 'apt -y update && apt install -y grub-customizer'

    if [ $? == 0 ]; 
    then 
        echo " "
        echo "Grub Customizer has been installed successfully!"
        echo " "
    fi

    return 0
}

function install_system36_power() {
    # Add system36 power
    sudo --sh -c 'apt-add-repository ppa:system76-dev/stable'
    sudo -- sh -c 'apt install gnome-shell-extension-system76-power system76-power'

    # optional - a Gnome extension to toggle graphics
    sudo --sh -c 'apt install gnome-shell-extension-prefs'

    if [ $? == 0 ]; 
    then 
        echo " "
        echo "System36-power has been installed successfully!"
        echo " "
    fi

    return 0
}

function install_misc() {
    # power top
    sudo --sh -c 'atp install powertop'
    # htop
    sudo --sh -c 'apt install htop'
    # Nvidia - nvtop
    sudo --sh -c 'apt install nvtop'


    if [ $? == 0 ]; 
    then 
        echo " "
        echo "Misc. packages has been installed successfully!"
        echo " "
    fi

    return 0
}

install_essential_packages
install_snapstore_apps
install_ros_humble
install_arduinoIDE2_0
install_google_chrome
install_docker
install_docker_compose





# Reboot Option
read -p "Script has finished setting up your computer, Shall we reboot to let the changes take effect?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    reboot
fi
