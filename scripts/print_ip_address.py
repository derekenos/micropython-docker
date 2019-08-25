
from time import sleep
import network


TIMEOUT_SECONDS = 5


wlan = network.WLAN(network.STA_IF)
seconds_remaining = TIMEOUT_SECONDS
while True:
    if wlan.isconnected():
        print(wlan.ifconfig()[0])
    else:
        sleep(1)
        seconds_remaining -= 1
        if not seconds_remaining:
            print('Timed out while waiting for WLAN connection!')
            break
