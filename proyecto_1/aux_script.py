import cv2
import numpy as np
import subprocess
from pathlib import Path

# read input image data
image = cv2.imread("image.png") 
# transform input image data into 1 byte grayscale
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
rows,cols = gray.shape

qemu = "qemu-riscv64-static"
program = "build/wave"
in_img = "build/img_in.bin"
out_img = "build/img_out.bin"
video_file = "build/wave.mp4"

# write image data to the binary file to be used as input to the asm program
stdin = gray.tobytes()
stdin_file = open(in_img, "wb")
stdin_file.write(stdin)
stdin_file.close()

# define the Lx, Ly parameters 
Lx = 75
Ly = 75

# list for opencv animation
frames = list()
# codec to use for video writer
fourcc = cv2.VideoWriter_fourcc(*'mp4v') 
# instance of video writer, configured for 4fps
video = cv2.VideoWriter(video_file, fourcc, 4.0, (cols,rows))
for k in range(5,205,5):
    Ax = k
    Ay = k
    img_out = np.zeros((rows,cols,1), np.uint8)
    # call asm program via qemu in shell mode (input options in subprocess.run
    # seemed to be buggy at the moment)
    result = subprocess.run(
        f"{qemu} {program} {Ax} {Ay} {Lx} {Ly} < {in_img} > {out_img}", 
        shell = True,
        check = True
        )
    # Read file to which STDOUT was redirected from the asm program. Use that
    # to create the frame for the animation
    with open(out_img, "rb") as stdout_file:
        stdout = stdout_file.read()
        for i in range(rows):
            for j in range(cols):
                img_out[i][j] = stdout[j + cols*i]
    # add frames for opencv animation and video writer
    cv2.imwrite("build/image_result.png",img_out)
    frame = cv2.imread("build/image_result.png")
    frames.append(frame)
    video.write(frame)

# show video
for frame in frames:
    cv2.imshow('frame',frame)
    # 250ms per frame = 4fps, 40 frames in 10s
    if cv2.waitKey(250) & 0xFF == ord('q'):
        break    

video.release()
cv2.destroyAllWindows()