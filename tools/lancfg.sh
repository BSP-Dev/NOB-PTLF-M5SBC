#!/bin/bash

# /usr/sbin/rcdEepromTool

function  rebind_at24()
{
    echo "6-0057" | tee /sys/bus/i2c/drivers/at24/unbind

    
    echo "6-0057" | tee /sys/bus/i2c/drivers/at24/bind
}

function  write_LAN_mac_address()
{
    error_mac1="00:00:00:00:00:00"
    error_mac2="FF:FF:FF:FF:FF:FF"

    O_ETH0=$(ifconfig -a end0 | awk '/ether/ { print $2 }')

    ETH0_TMP=$(/usr/sbin/smarcCfg -0 )

    calcheckSum=$(/usr/sbin/smarcCfg -p )
    setcheckSum=$(/usr/sbin/smarcCfg -j )
    readcheckSum=$(/usr/sbin/smarcCfg -k )

    if ( [[ "$ETH0_TMP" == "$error_mac1" ]] || [[ "$ETH0_TMP" == "$error_mac2" ]] ) ; then
	    sleep 1
            return
    elif [ "$calcheckSum" != "$readcheckSum" ]; then
	    sleep 1
            return
    else
	    sleep 0.3
    
	N_ETH0=$ETH0_TMP
        ifconfig end0 down

        address=$O_ETH0
        ip link set dev end0 address ${N_ETH0}


        sleep 1.2
        ifconfig end0 up
    fi

}


function  write_LAN_LED_setting()
{

    /usr/sbin/mdio-tool w end0 0x1f 0x0d04
    /usr/sbin/mdio-tool w end0 0x10 0x091b
    /usr/sbin/mdio-tool w end0 0x11 0x0000
    /usr/sbin/mdio-tool w end0 0x1f 0x0000
}

function main()
{
    rebind_at24

    write_LAN_mac_address
    write_LAN_LED_setting
}

main
