import math as m

Ax = 100.0
Ay = 100.0
Lx = 75.0
Ly = 75.0
for y in range(0, 480):
    for x in range(0, 640):
        xp  = x + Ax*m.sin(m.tau * y / Lx)
        yp  = y + Ay*m.sin(m.tau * x / Ly)
        xp = round(xp)
        yp = round(yp)
        print("x:{}, y:{} ---- xp:{} ,yp:{}".format(x,y,xp,yp))
