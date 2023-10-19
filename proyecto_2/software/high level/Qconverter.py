"""
Restricciones:
  1. Los audios deben durar 7 segundos
  2. Los audios deben ser Mono
  3. Los audios deben tener una frecuencia de muestreo de 44100 Hz
  4. Los audios deben tener una resolución de 8 bits
  5. Los audios deben ser WAV
  6. Los audios deben estar en la misma carpeta que el programa
"""

import wave
import sys

def audio_to_q114(input_file, Qformat_file):
  # Abre el archivo WAV y toma sus datos de audio
    with wave.open(input_file, 'rb') as wav_in:
        paramsIn = wav_in.getparams()
        header_size = paramsIn.nframes * paramsIn.sampwidth
        audio_data = wav_in.readframes(paramsIn.nframes)
  # Convierte esos datos a entero
    binary_data = bytearray(audio_data)
    normalized_float_data = []
    int_data = [int(byte) for byte in binary_data]
  # Normaliza los datos entre -1 y 1
    for value in int_data:
        normalized_value = (value / 255.0) * 2 - 1
        normalized_float_data.append(normalized_value)
  # Escribe el formato Q1.14
    qformatData = []
    for val in normalized_float_data:
        if val < 0:
            binary = "1"  # Signo negativo
        else:
            binary = "0"  # Signo positivo

        integer = int(abs(val))
        binary = binary + str(integer) # Parte entera
  # Sub-algoritmo para convertir el float a binario
        decimal = abs(val) - int(abs(val))
        sum = 0
        for i in range(14):
            if sum + 2**(-(i + 1)) < decimal:
                sum += 2**(-(i + 1))
                binary = binary + "1"
            else:
                binary = binary + "0"
        while len(binary) < 15:
            binary += "0"
        qformatData.append(binary) # Parte decimal
  # Escritura de los datos Q1.14 a un archivo TXT
    with open(Qformat_file, 'w') as txt_out:
        for value in qformatData:
            txt_out.write(value + "\n")
    return paramsIn

def q114_to_audio(Qformat_file, reconstructed_file, paramsIn):
  # Lee los datos del TXT generado antes
    with open(Qformat_file, 'r') as txt_in:
        qformat_data = [line.strip() for line in txt_in]
  # Convierte los datos de Q1.14 a float
    float_data = []
    for binary in qformat_data:
        sign_bit = int(binary[0])
        integer_part = int(binary[1], 2)
        fractional_part = 0
        for i in range(14):
            fractional_part += int(binary[i + 2]) * (2 ** -(i + 1))
        value = (-1 if sign_bit == 1 else 1) * (integer_part + fractional_part)
        float_data.append(value)
  # Convierte los float a binario
    int_data = [int((value + 1) * 127.5) for value in float_data]
    binary_data = bytearray(int_data)
  # Escribe los datos en binario al nuevo archivo WAV
    with wave.open(reconstructed_file, 'wb') as wav_out:
        wav_out.setparams(paramsIn)
        wav_out.writeframes(binary_data)

"""TO DO: SOLO LEER BINARIO Y DE UNA VEZ PASARLO A .WAV, cuando este lo de C """
def float_to_binary_and_audio_reconstruction(input_file, reconstructed_file, paramsInput):
    with open(input_file, 'r') as txt_in:
        float_data = [float(line.strip()) for line in txt_in]

    int_data = [(int((value + 1) * 127.5)) for value in float_data]
    binary_data = bytearray(int_data)

    with wave.open(reconstructed_file, 'wb') as wav_out:
        wav_out.setparams(paramsInput)
        wav_out.writeframes(binary_data)


"""---------------LLAMAR A ESTAS FUNCIONES-------------------------------------"""
def generate_txt_Q114():
    input_file = "audio_Mono441k7seg.wav"
    Qformat_file = "audio_Q114.txt"
    reconstructed_file = "reconstructed_audio.wav"
    paramsInput = audio_to_q114(input_file, Qformat_file)
    q114_to_audio(Qformat_file, reconstructed_file, paramsInput)

def reconstruct_modified_audios():
  paramsInput = audio_to_q114("audio_Mono441k7seg.wav", "audio_Q114.txt")
  float_to_binary_and_audio_reconstruction("insercion.txt", "reverbed_audio.wav", paramsInput)


if __name__ == '__main__':
  if(sys.argv[1] == "gen"):
    input_file = sys.argv[2]
    qformat_file = sys.argv[3]
    audio_to_q114(input_file, qformat_file)
  else:
    ref_file = sys.argv[2]
    qformat_file = sys.argv[3]
    reconstructed_file = sys.argv[4]
    with wave.open(ref_file, 'rb') as wav_in:
        q114_to_audio(qformat_file, reconstructed_file, wav_in.getparams())


