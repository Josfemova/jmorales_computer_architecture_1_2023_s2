import tkinter
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
        self.up_btn =tkinter.Button(self.left_frame, width=4, height=3, bg="#c41061", command=self.mod_state)
        self.down_btn =tkinter.Button(self.left_frame, width=4, height=3,bg="#c41061")
        self.left_btn =tkinter.Button(self.left_frame, width=6, height=2, bg="#c41061")
        self.right_btn =tkinter.Button(self.left_frame, width=6, height=2, bg="#c41061")
        self.up_btn.place(x=89,y=380)
        self.down_btn.place(x=89,y=475)
        self.left_btn.place(x=37,y=436)
        self.right_btn.place(x=126,y=436)
        #Etiqueta de pantalla
        self.mov_label = tkinter.Label(self.left_frame,text="Estado:", font="Castellar", bg="#9fa738", fg="white")
        self.mov_var = tkinter.Label(self.left_frame,text="aqui", font="Castellar", bg="#9fa738", fg="white")
        self.vel_label = tkinter.Label(self.left_frame,text="KM/H:", font="Castellar", bg="#9fa738", fg="white")
        self.vel_var = tkinter.Label(self.left_frame,text="aqui", font="Castellar", bg="#9fa738", fg="white")
        self.acel_label = tkinter.Label(self.left_frame,text="Aceleracion:", font="Castellar", bg="#9fa738", fg="white")
        self.acel_var = tkinter.Label(self.left_frame,text="aqui", font="Castellar", bg="#9fa738", fg="white")
        self.ori_label = tkinter.Label(self.left_frame,text="Orientacion:", font="Castellar", bg="#9fa738", fg="white")
        self.ori_var = tkinter.Label(self.left_frame,text="aqui", font="Castellar", bg="#9fa738", fg="white")
        self.prox_label = tkinter.Label(self.left_frame,text="Proximidad:", font="Castellar", bg="#9fa738", fg="white")
        self.prox_var = tkinter.Label(self.left_frame,text="aqui", font="Castellar", bg="#9fa738", fg="white")
        self.mov_label.place(x=80,y=40)
        self.vel_label.place(x=80,y=70)
        self.acel_label.place(x=80,y=100)
        self.ori_label.place(x=80,y=130)
        self.prox_label.place(x=80,y=160)
        self.mov_var.place(x=175,y=40)
        self.vel_var.place(x=153,y=70)
        self.acel_var.place(x=245,y=100)
        self.ori_var.place(x=245,y=130)
        self.prox_var.place(x=245,y=160)

    def mod_state(self):
        self.mov_var.configure(text="Moviendo adelante")



if __name__ == "__main__":
    window = tkinter.Tk()
    app = App(window)
    window.mainloop()