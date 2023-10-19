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

ser = Serial(mi_puerto, 921600)
while(True):
    while(ser.readline() != b'@START@\r\n'):
        pass
    print("Comienza transmisión")
    file = open("/tmp/datos_arqui.txt", "w")
    while(True):
        line = ser.readline()
        if(line == b'@END@\r\n'):
            print("Termina transmisión")
            break
        else:
            num = int(line.decode('utf-8').split(":")[1], 16)
            line  = "{:016b}\n".format(num)
            print(line, end = "")
    file.close()