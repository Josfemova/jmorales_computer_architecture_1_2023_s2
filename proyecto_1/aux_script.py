import cv2
import numpy as np
import subprocess
from pathlib import Path

image = cv2.imread("image.png")
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
rows,cols = gray.shape

qemu = "qemu-riscv64-static"
program = "build/wave"
in_img = "build/img_in.bin"
out_img = "build/img_out.bin"
video_file = "build/wave.mp4"

stdin = gray.tobytes()
stdin_file = open(in_img, "wb")
stdin_file.write(stdin)
stdin_file.close()


Lx = 75
Ly = 75
frames = list()
fourcc = cv2.VideoWriter_fourcc(*'mp4v') # Be sure to use lower case
video = cv2.VideoWriter(video_file, fourcc, 4.0, (cols,rows))
for k in range(5,205,5):
    Ax = k
    Ay = k
    img_out = np.zeros((rows,cols,1), np.uint8)
    result = subprocess.run(
        f"{qemu} {program} {Ax} {Ay} {Lx} {Ly} < {in_img} > {out_img}", 
        shell = True,
        check = True
        )
    with open(out_img, "rb") as stdout_file:
        stdout = stdout_file.read()
        for i in range(rows):
            for j in range(cols):
                img_out[i][j] = stdout[j + cols*i]
    cv2.imwrite("build/image_result.png",img_out)
    frame = cv2.imread("build/image_result.png")
    frames.append(frame)
    video.write(frame)

# Mostrar video
for frame in frames:
    cv2.imshow('frame',frame)
    # 1/4 de segundo por frame para mostrar 40 frames en 10 segundos 
    if cv2.waitKey(250) & 0xFF == ord('q'):
        break    

video.release()
cv2.destroyAllWindows()