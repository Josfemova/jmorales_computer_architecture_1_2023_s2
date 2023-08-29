import cv2
import numpy as np
import subprocess
from pathlib import Path

image = cv2.imread("image.png")
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
rows,cols = gray.shape

stdin = gray.tobytes()
stdin_file = open("build/img_in.bin", "wb")
stdin_file.write(stdin)
stdin_file.close()

Ax = 5
Ay = 5
result = subprocess.run("qemu-riscv64-static build/wave {} {} < build/img_in.bin > build/img_out.bin".format(Ax, Ay), shell=True)

img_out = np.zeros((rows,cols,1), np.uint8)

stdout_file = open("build/img_out.bin", "rb")
stdout = stdout_file.read()
for i in range(rows):
    for j in range(cols):
        img_out[i][j] = stdout[j + cols*i]
stdout_file.close()

cv2.imwrite("build/image_result.png",img_out)

