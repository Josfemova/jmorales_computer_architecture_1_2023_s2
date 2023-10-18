from serial import Serial
from serial.tools.list_ports import comports

puertos = comports()
mi_puerto = None 

for puerto in puertos:
    if puerto.manufacturer == "SISA" and puerto.product == "Extractor":
        mi_puerto = puerto.device

if mi_puerto == None:
    print("No se logró encontrar el microcontrolador")
    exit(1)

ser = Serial(mi_puerto, 115200)
#while(True):
#    print(ser.readline())
while(ser.readline() != b'@START@\r\n'):
    pass

print("OWO")
while(True):
    line = ser.readline()
    if(line == b'@END@\r\n'):
        print("Adios")
        break
    else:
        print(line.decode('utf-8'), end="")