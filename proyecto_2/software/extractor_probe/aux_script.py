from serial import Serial
from serial.tools.list_ports import comports
import sys

puertos = comports()
mi_puerto = None 

for puerto in puertos:
    if puerto.manufacturer == "SISA" and puerto.product == "Extractor":
        mi_puerto = puerto.device

if mi_puerto == None:
    print("No se logró encontrar el microcontrolador")
    exit(1)

print("Conectados al micro")

ser = Serial(mi_puerto, 12000000)
while(True):
    while(ser.readline() != b'@START@\r\n'):
        pass
    print("Comienza transmisión")
    file = open(sys.argv[1], "w")
    i = 0
    while(True):
        line = ser.readline()
        if(line == b'@END@\r\n'):
            print("Termina transmisión")
            break
        else:
            i= i+1
            num = int(line.decode('utf-8').split(":")[1], 16)
            line  = "{:016b}\n".format(num)
            print(f"count:{i} val: {line}", end = "")
            file.write(line)
    file.close()