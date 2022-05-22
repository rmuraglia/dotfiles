# check_bluetooth.py

from yaml import load, FullLoader
from subprocess import Popen, PIPE

cmd = ['system_profiler', 'SPBluetoothDataType']
proc = Popen(cmd, stdout=PIPE, stderr=PIPE)
stdout, stderr = proc.communicate()

y = load(stdout, Loader=FullLoader)

try:
    bt_info = y['Bluetooth']['Connected']
except KeyError:
    bt_info = {}


bt_devices = []

for k, v in bt_info.items():
    battery_level = v.get('Battery Level', None)

    device_info_str = f'{k} ({battery_level})' if battery_level else k
    bt_devices.append(device_info_str)

print('\n'.join(bt_devices), end='')
