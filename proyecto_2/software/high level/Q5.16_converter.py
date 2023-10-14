
"""Lectura del archivo WAV ----------------------------------------------------"""

import wave

input_file = "audio_Mono441k7seg.wav"
output_file = "audio_output.txt"

with wave.open(input_file, 'rb') as wav_in:
    params = wav_in.getparams()
    header_size = params.nframes * params.sampwidth
    audio_data = wav_in.readframes(params.nframes)

"""Normalizacion de los datos del audio ---------------------------------------"""

binary_data = bytearray(audio_data)
normalized_float_data = []
int_data = [int(byte) for byte in binary_data]

for value in int_data:
  normalized_value = (value / 255.0) * 2 - 1
  normalized_float_data.append(normalized_value)

"""Conversion a Q5.16 ---------------------------------------------------------"""

qformatData = []

for val in normalized_float_data:
  #SIGNO -----------------------------------------------------------------------
  if val < 0:
      binary = "10000" #signo negativo (tiene 5 bits porque luego se suma la parte entera)
  else:
      binary = "00000" #signo positivo (tiene 5 bits porque luego se suma la parte entera)

  #PARTE ENTERA ----------------------------------------------------------------
  integer = int(abs(val))
  binary = binary + str(integer) #se suma el entero (uno o cero)
  decimal = abs(val) - int(abs(val))

  #PARTE DECIMAL ---------------------------------------------------------------
  sum = 0
  for i in range(16): # el 16 es porque usamos Q5.16
      if sum + 2**(-(i+1)) < decimal:
          sum += 2**(-(i+1))
          binary = binary + "1"
      else:
          binary = binary + "0"
  while len(binary)<21: # 5 + 16 = 21
    binary+="0"
    print(len(binary))
  qformatData.append(binary)

"""Escritura en un txt de los numeros con Q5.16--------------------------------"""

with open(output_file, 'w') as txt_out:
    for value in qformatData:
        txt_out.write(value+"\n")