import busio
import board
import digitalio
import time
from adafruit_ht16k33.segments import Seg7x4

scl = board.GP21
sda = board.GP20
i2c = busio.I2C(scl, sda)
display = Seg7x4(i2c)
display.brightness = 1
display.blink_rate = 0 
display.print("ABCD")

def cfg_pin(pin):
    button = digitalio.DigitalInOut(pin)
    button.direction = digitalio.Direction.INPUT
    button.pull = digitalio.Pull.UP
    return button

def cfg_pin_out(pin):
    button = digitalio.DigitalInOut(pin)
    button.direction = digitalio.Direction.OUTPUT
    return button

bit15 = cfg_pin(board.GP15)
bit14 = cfg_pin(board.GP14)
bit13 = cfg_pin(board.GP13)
bit12 = cfg_pin(board.GP12)
bit11 = cfg_pin(board.GP11)
bit10 = cfg_pin(board.GP10)
bit09 = cfg_pin(board.GP9)
bit08 = cfg_pin(board.GP8)
bit07 = cfg_pin(board.GP7)
bit06 = cfg_pin(board.GP6)
bit05 = cfg_pin(board.GP5)
bit04 = cfg_pin(board.GP4)
bit03 = cfg_pin(board.GP3)
bit02 = cfg_pin(board.GP2)
bit01 = cfg_pin(board.GP1)
bit00 = cfg_pin(board.GP0)

bits = [bit00, bit01, bit02, bit03,
        bit04, bit05, bit06, bit07,
        bit08, bit09, bit10, bit11,
        bit12, bit13, bit14, bit15]

# indica que se puede empezar a transmitir cuando se pone en bajo
# en ultimo valor se levanta antes del ack
ready_flag = cfg_pin(board.GP16)
# Cliente hace toggle para solicitar un valor
request_pin = cfg_pin_out(board.GP17)
# Servidor hace toggle para indicar que el valor ya está en el bus
ack_pin = cfg_pin(board.GP18)

slow_exe_pin = cfg_pin(board.GP22)

def get_binval():
    value = 0
    for i in range(0,16):
        value |= (bits[i].value << i)
    return value

def print_val(i):
    value = get_binval()
    print("#{0}:0x{1:04x}".format(i,value))
    display.print("{:04x}".format(value))

def request():
    request_pin.value = False
    while(ack_pin.value):
        pass
    request_pin.value = True
    while(not ack_pin.value):
        pass

counter = 0
while(1):
    while(ready_flag.value):
        pass
    print("dummy")
    print("dummy")
    print("@START@")
    counter = 0
    while(not ready_flag.value):
        if(slow_exe_pin.value):
            time.sleep(1)
        request()
        print_val(counter)
        counter +=1

    print("@END@")
    
