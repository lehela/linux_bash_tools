#!/bin/bash
#
#set -x

function print_man {
echo
echo Usage
echo ====================================================================================
echo vb [OPTION] [MACHINE]
echo
echo Without parameters the available virtual machines will be listed
echo
echo MACHINE : specify the name of the virtual machine to be controlled in headless mode
echo
echo OPTION
echo -l,--list        List virtual machines \(available and running\)
echo -i,--info        Shows configuration settings of virtual machines
echo -t,--toggle      Toggles the state of the machine between headless, and savedstate
echo -a,--acpi        Shuts down the machine through ACPI
echo -q,--quit        Shuts down the machine through power off
echo -s,--save        Puts machine into save state
echo -h,--headless    Starts the machine in headless mode
echo
}

function print_vms {
	    echo
            echo Available Machines
            echo ------------------
            VBoxManage list vms
            echo
            echo Running Machines
            echo ------------------
            VBoxManage list runningvms
	    echo
}

function vm_is_running {
# $1"  : name of machine
# y    : vm is running
# n    : vm is not running
	local runvms=$(VBoxManage list runningvms) 
	if grep -q "$1" <<< "$runvms";
	then
		result=y
	else
		result=n
	fi
}

function vm_start_headless {
# $1"  : name of machine
	vm_is_running "$1"
	if [ $result == "n" ] 
	then
		VBoxManage startvm "$1" -type headless
	else
		echo Virtual Machine $1 is running already.
	fi
}

function vm_save {
# $1"  : name of machine
	vm_is_running "$1"
	if [ $result == "y" ] 
	then
		VBoxManage controlvm "$1" savestate
	else
		echo Virtual Machine $1 is not running.
	fi

}

function vm_acpi {
# $1"  : name of machine
	vm_is_running "$1"
	if [ $result == "y" ] 
	then
		VBoxManage controlvm "$1" acpipowerbutton
	else
		 echo Virtual Machine $1 is not running.
	fi

}

function vm_quit {
# $1"  : name of machine
	vm_is_running "$1"
	if [ $result == "y" ] 
	then
		VBoxManage controlvm "$1" poweroff
	else
		echo Virtual Machine $1 is not running.
	fi

}

function vm_toggle {
# $1"  : name of machine
	vm_is_running "$1"
	if [ $result == "y" ] 
	then
		vm_save "$1"	
	else
		vm_start_headless "$1"
	fi
}

function vm_info {
	INFO=$(VBoxManage showvminfo "$1")
	INFO+=$(echo -e "\n \nGuest Properties:\n------------------ \n")
	INFO+=$(echo -e " \n ")
	INFO+=$(VBoxManage guestproperty enumerate "$1")
	echo -e "$INFO"|less
}

SHORT=la:t:q:s:h:i:
LONG=list,acpi,toggle:,quit:,save:,headless:,info:

PARSED=`getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@"`
if [[ $? -ne 0 ]]; then
    # e.g. $? == 1
    #  then getopt has complained about wrong arguments to stdout
    print_man
    exit 2
fi

# use eval with "$PARSED" to properly handle the quoting
eval set -- "$PARSED"

option=$1
machine=$2

# Check the first option and machine if anyy
    case "$option" in
        -l|--list)
	    print_vms
            ;;
        -h|--headless)
	    vm_start_headless $machine
            ;;
        -s|--save)
	    vm_save $machine
            ;;
        -q|--quit)
	    vm_quit $machine
            ;;
        -a|--acpi)
            vm_acpi $machine
            ;;
        -i|--info)
            vm_info $machine
            ;;
        -t|--toggle)
            vm_toggle $machine
            ;;
        --)
	    print_man
            ;;
        *)
            echo "Option not implemented"
            exit 3
            ;;
    esac

exit 0;

