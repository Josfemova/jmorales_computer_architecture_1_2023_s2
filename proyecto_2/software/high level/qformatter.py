# -*- coding: utf-8 -*-
"""Lectura del archivo WAV"""

import wave

input_file = "acousticGuitarMono441k.wav"
output_file = "guitarMono441kHeaderless.txt"

with wave.open(input_file, 'rb') as wav_in:
    params = wav_in.getparams()
    header_size = params.nframes * params.sampwidth
    audio_data = wav_in.readframes(params.nframes)

"""Normalizacion de los datos del audio"""

binary_data = bytearray(audio_data)
normalized_float_data = []
int_data = [int(byte) for byte in binary_data]

for value in int_data:
  normalized_value = (value / 255.0) * 2 - 1
  normalized_float_data.append(normalized_value)

"""Conversion a Q15.16 (de momento)"""

qformatData = []

for val in normalized_float_data:
  if val < 0:
      binary = "100000000000000"
  else:
      binary = "000000000000000"
  integer = int(abs(val))
  binary = binary + str(integer)
  decimal = abs(val) - int(abs(val))
  sum = 0
  for i in range(16):
      if sum + 2**(-(i+1)) < decimal:
          sum += 2**(-(i+1))
          binary = binary + "1"
      else:
          binary = binary + "0"
  while len(binary)<32:
    binary+="0"
    print(len(binary))
  qformatData.append(binary)

"""Escritura en un txt de los numeros con Q15.16"""

with open(output_file, 'w') as txt_out:
    for value in qformatData:
        txt_out.write(value+"\n")