
import network
import webrepl
from usleep import sleep

import config


WLAN_CONNECT_WAIT_SECONDS = 3


def wlan_connect(ssid, password):
    wlan = network.WLAN(network.STA_IF)
    if not wlan.active() or not wlan.isconnected():
        wlan.active(True)
        print('connecting to:', ssid)
        wlan.connect(ssid, password)
        wait_seconds_remaining = WLAN_CONNECT_WAIT_SECONDS
        while not wlan.isconnected() and wait_seconds_remaining:
            sleep(1)
            wait_seconds_remaining -= 1

    print('network config:', wlan.ifconfig())


if config.WIFI_CONNECT_ON_BOOT:
    wlan_connect(config.WIFI_SSID, config.WIFI_PASSWORD)

if config.WEBREPL_START_ON_BOOT:
    webrepl.start()
