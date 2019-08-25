
from binascii import hexlify
from network import WLAN

wlan = WLAN()
mac_byte_string = wlan.config('mac')
mac_string = hexlify(mac_byte_string).decode('latin-1')
delimited_mac_string = ':'.join('{}{}'.format(*mac_string[i:i+2]) for i in
                                range(0, len(mac_string), 2))
print(delimited_mac_string)
