import tkinter
import requests
import json
import math
from tkinter import PhotoImage
from tkinter import scrolledtext


class App:
    def __init__(self,window):
        #Creacion de la ventana
        self.window = window
        self.window.geometry("838x599")
        self.window.resizable(width=False,height=False)

        #Division de la ventana

        self.left_frame = tkinter.Frame(self.window,width=419,height=599)
        self.right_frame= tkinter.Frame(self.window,width=419,height=599)
        self.left_frame.pack(side=tkinter.LEFT,fill=tkinter.BOTH, expand=True)
        self.right_frame.pack(side=tkinter.RIGHT,fill=tkinter.BOTH, expand=True)


        #Rellena de la mitad izquierda
        self.background = PhotoImage(file="caratula.png")
        self.canva_1 = tkinter.Canvas(self.left_frame, width=419,height=599)
        self.canva_1.pack()
        self.canva_1.create_image(0,0, anchor=tkinter.NW, image = self.background)

        #Rellenar la mitad derecha
        self.console = scrolledtext.ScrolledText(self.right_frame, wrap=tkinter.WORD, width=40, height=20, bg="#7D8703")
        self.console.pack(expand=True, fill="both")

        #Crear los 4 botones de movimiento
        self.up_btn =tkinter.Button(self.left_frame, width=4, height=3, bg="#c41061")
        self.down_btn =tkinter.Button(self.left_frame, width=4, height=3,bg="#c41061")
        self.left_btn =tkinter.Button(self.left_frame, width=6, height=2, bg="#c41061")
        self.right_btn =tkinter.Button(self.left_frame, width=6, height=2, bg="#c41061")
        self.up_btn.place(x=89,y=380)
        self.down_btn.place(x=89,y=475)
        self.left_btn.place(x=37,y=436)
        self.right_btn.place(x=126,y=436)
        
        self.start_btn = tkinter.Button(self.left_frame, width=6, height=2, bg="Grey", text="START", command= lambda: self.startListening() )
        self.start_btn.place(x=280,y= 320)

        #funciones de los botones
        self.is_pressed = False
        self.up_btn.bind("<ButtonRelease-1>", lambda event: self.moveDirection(button="u"))
        self.up_btn.bind("<ButtonPress-1>", lambda event: self.moveDirection(button="up"))
        self.down_btn.bind("<ButtonRelease-1>", lambda event: self.moveDirection(button="d"))
        self.down_btn.bind("<ButtonPress-1>", lambda event: self.moveDirection(button="down"))
        self.left_btn.bind("<ButtonRelease-1>", lambda event: self.moveDirection(button="l"))
        self.left_btn.bind("<ButtonPress-1>", lambda event: self.moveDirection(button="left"))
        self.right_btn.bind("<ButtonRelease-1>", lambda event:self.moveDirection(button="r"))
        self.right_btn.bind("<ButtonPress-1>", lambda event:self.moveDirection(button="right"))
        #Etiqueta de pantalla
        self.mov_label = tkinter.Label(self.left_frame,text="Estado:", font=("Castellar",12), bg="#9fa738", fg="white")
        self.mov_var = tkinter.Label(self.left_frame,text="", font=("Castellar",12), bg="#9fa738", fg="white")
        self.vel_label = tkinter.Label(self.left_frame,text="KM/H:", font=("Castellar",12), bg="#9fa738", fg="white")
        self.vel_var = tkinter.Label(self.left_frame,text="0", font=("Castellar",12), bg="#9fa738", fg="white")
        self.acel_label = tkinter.Label(self.left_frame,text="Aceleracion:", font=("Castellar",12), bg="#9fa738", fg="white")
        self.acel_var = tkinter.Label(self.left_frame,text="0", font=("Castellar",12), bg="#9fa738", fg="white")
        self.ori_label = tkinter.Label(self.left_frame,text="Orientacion:", font=("Castellar",12), bg="#9fa738", fg="white")
        self.ori_var = tkinter.Label(self.left_frame,text="0", font=("Castellar",12), bg="#9fa738", fg="white")
        self.prox_label = tkinter.Label(self.left_frame,text="Proximidad:", font=("Castellar",12), bg="#9fa738", fg="white")
        self.prox_var = tkinter.Label(self.left_frame,text="0", font=("Castellar",12), bg="#9fa738", fg="white")
        self.mov_label.place(x=80,y=40)
        self.vel_label.place(x=80,y=70)
        self.acel_label.place(x=80,y=100)
        self.ori_label.place(x=80,y=130)
        self.prox_label.place(x=80,y=160)
        self.mov_var.place(x=165,y=40)
        self.vel_var.place(x=143,y=70)
        self.acel_var.place(x=225,y=100)
        self.ori_var.place(x=225,y=130)
        self.prox_var.place(x=225,y=160)
        #Funciones de las teclas
        self.window.bind("<Up>",lambda event: self.moveDirection("up"))
        self.window.bind("<KeyRelease-Up>",lambda event:self.moveDirection("u"))
        self.window.bind("<Down>",lambda event: self.moveDirection("down"))
        self.window.bind("<KeyRelease-Down>",lambda event:self.moveDirection("d"))
        self.window.bind("<Right>",lambda event: self.moveDirection("right"))
        self.window.bind("<KeyRelease-Right>",lambda event:self.moveDirection("r"))
        self.window.bind("<Left>",lambda event: self.moveDirection("left"))
        self.window.bind("<KeyRelease-Left>",lambda event:self.moveDirection("l"))
        #Flag para activar comunicacion
        self.active=False

        #Flags de comunicacion
        self.up = False
        self.down = False
        self.right = False
        self.left = False

    #Activa el flag de escritura
    def startListening(self):
        if not self.active:
            self.active = True
            self.start_btn.configure(text="STOP")
            self.writeConsole()
        else:
            self.active = False
            self.start_btn.configure(text="START")
    #Escribe los datos del carro en consola
    def writeConsole(self):
        #Se ejucuta el listening del API
        datos =self.readParams()
        if (datos != None):
            self.console.insert(tkinter.END, "Timestamp: "+str(datos[0]["timestamp"])+ "\n") 
            self.console.insert(tkinter.END, "Aceleracion en X: "+str(datos[0]["aceleracion_x"])+ "\n")
            self.console.insert(tkinter.END, "Aceleracion en Y: "+str(datos[0]["aceleracion_y"])+ "\n")
            self.console.insert(tkinter.END, "Aceleracion en Z: "+str(datos[0]["aceleracion_z"])+ "\n")
            self.console.insert(tkinter.END, "Orientacion en X: "+str(datos[0]["orientacion_x"])+ "\n")
            self.console.insert(tkinter.END, "Orientacion en Y: "+str(datos[0]["orientacion_y"])+ "\n")
            self.console.insert(tkinter.END, "Orientacion en Z: "+str(datos[0]["orientacion_z"])+ "\n")
            self.console.insert(tkinter.END, "Proximidad: "+str(datos[0]["proximidad"])+ "\n")    
            magnitudAcel = math.sqrt(((datos[0]["aceleracion_x"]**2)+(datos[0]["aceleracion_y"]**2)+(datos[0]["aceleracion_z"]**2)))
            magnitudOri = math.sqrt(((datos[0]["orientacion_x"]**2)+(datos[0]["orientacion_z"]**2)+(datos[0]["orientacion_y"]**2)))
            self.acel_var.configure(text=magnitudAcel)
            self.ori_var.configure(text=magnitudOri)
            self.prox_var.configure(text=datos[0]["proximidad"])
        else:
            self.console.insert(tkinter.END, "14/11/23 \n error")
        if self.active:
            self.window.after(1000, self.writeConsole)
    #Envia los comandos de movimiento al carrito
    def moveDirection(self,button):
        if button == "up":
            self.mov_var.configure(text="moviendo adelante")
            self.up = True
        elif button == "down":
            self.mov_var.configure(text="moviendo abajo")
            self.down = True
        elif button == "right":
            self.mov_var.configure(text="doblando derecha")
            self.right = True
        elif button == "left":
            self.mov_var.configure(text="doblando izquierda")
            self.left = True
        else:
            self.mov_var.configure(text="")
            if button == "u":
                self.up = False
            elif button == "d":
                self.down = False
            elif button == "r":
                self.right = False
            else:
                self.left = False
        self.sendPost()
    #Crea el json para enviar al API
    def makeJson(self):
        json_ ={}
        if self.right and self.up:
            self.mov_var.configure(text="Moviendo en diagonal")
            json_ = {"command":1, "x": 255, "y":255 }
        elif self.right and self.down:
            self.mov_var.configure(text="Moviendo en diagonal")
            json_ = {"command":1, "x": 255, "y":-255 }
        elif self.left and self.up:
            self.mov_var.configure(text="Moviendo en diagonal")
            json_ = {"command":1, "x": -255, "y":255 }
        elif self.left and self.down:
            self.mov_var.configure(text="Moviendo en diagonal")
            json_ = {"command":1, "x": -255, "y":-255 }
        elif self.up:
            json_ = {"command":1, "x": 0, "y":255 }
        elif self.down:
            json_ = {"command":1, "x": 0, "y":-255 }
        else:
            json_ = {"command":0, "x": 0, "y":0 }
        return json.dumps(json_, indent=2)
            
    #Envia los comandos de movimiento al API
    def sendPost(self):
        url = "http://192.168.43.191:80/postMovimiento"
        json = self.makeJson()
        try:
            response = requests.post(url,json)
            if response.status_code // 100 ==2:
                print(response)
            else:
                print("error")
        except Exception as e:
            print(e)
    #Obtener los datos de los sensores al API
    def readParams(self):
        url= "http://192.168.43.191:80/env"
        try:
            response = requests.get(url)
            if response.status_code ==200:
                self.console.insert(tkinter.END, "14/11/23 \n datos del API \n")
                return response.json()
            else:
                self.console.insert(tkinter.END, "Error al obtener los datos")
                return None
        except Exception as e:
            print(e)


if __name__ == "__main__":
    window = tkinter.Tk()
    app = App(window)
    window.mainloop()