from pathlib import Path
# from tkinter import *
# Explicit imports to satisfy Flake8
from tkinter import Tk, Canvas, Entry, Text, Button, PhotoImage

OUTPUT_PATH = Path(__file__).parent
ASSETS_PATH = OUTPUT_PATH / Path("./assets/intrusion")

CamScaleW = 1072
CamScaleH = 762
def relative_to_assets(path: str) -> Path:
    return ASSETS_PATH / Path(path)

class IntrusionApp:
    def __init__(self,window, window_title,):

        self.window = window

        self.window.geometry(str(CamScaleW) + "x" + str(CamScaleH))
        self.window.configure(bg = "#3E4541")
        self.window.title(window_title)

        self.canvas = Canvas(
            window,
            bg = "#3E4541",
            height = 762,
            width = 1072,
            bd = 0,
            highlightthickness = 0,
            relief = "ridge"
        )

        self.canvas.place(x = 0, y = 0)
        self.canvas.create_rectangle(
            0.0,
            0.0,
            1072.0,
            51.0,
            fill="#E9A91C",
            outline="")

        self.canvas.create_text(
            36.0,
            13.0,
            anchor="nw",
            text="SAMIDS",
            fill="#FFFFFF",
            font=("Inter Bold", 20 * -1)
        )

        image_image_1 = PhotoImage(
            file=relative_to_assets("image_1.png"))
        image_1 = self.canvas.create_image(
            536.0,
            305.0,
            image=image_image_1
        )

        image_image_2 = PhotoImage(
            file=relative_to_assets("image_2.png"))
        image_2 = self.canvas.create_image(
            831.0,
            628.0,
            image=image_image_2
        )

        button_image_1 = PhotoImage(
            file=relative_to_assets("button_1.png"))
        button_1 = Button(
            image=button_image_1,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: print("button_1 clicked"),
            relief="flat"
        )
        button_1.place(
            x=59.0,
            y=561.0,
            width=275.0,
            height=61.0
        )

        button_image_2 = PhotoImage(
            file=relative_to_assets("button_2.png"))
        button_2 = Button(
            image=button_image_2,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: print("button_2 clicked"),
            relief="flat"
        )
        button_2.place(
            x=59.0,
            y=638.0,
            width=275.0,
            height=61.0
        )

        button_image_3 = PhotoImage(
            file=relative_to_assets("button_3.png"))
        button_3 = Button(
            image=button_image_3,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: print("button_3 clicked"),
            relief="flat"
        )
        button_3.place(
            x=350.8316650390625,
            y=638.0,
            width=277.3367004394531,
            height=61.0
        )

        image_image_3 = PhotoImage(
            file=relative_to_assets("image_3.png"))
        image_3 = self.canvas.create_image(
            488.0,
            590.0,
            image=image_image_3
        )

        button_image_4 = PhotoImage(
            file=relative_to_assets("button_4.png"))
        button_4 = Button(
            image=button_image_4,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: print("button_4 clicked"),
            relief="flat"
        )
        button_4.place(
            x=351.0,
            y=559.0,
            width=218.0,
            height=62.0
        )

        button_image_5 = PhotoImage(
            file=relative_to_assets("button_5.png"))
        button_5 = Button(
            image=button_image_5,
            borderwidth=0,
            highlightthickness=0,
            command=self.transition,
            relief="flat"
        )
        button_5.place(
            x=785.0,
            y=5.0,
            width=247.0,
            height=39.0
        )

        button_image_6 = PhotoImage(
            file=relative_to_assets("button_6.png"))
        button_6 = Button(
            image=button_image_6,
            borderwidth=0,
            highlightthickness=0,
            command=lambda: print("button_6 clicked"),
            relief="flat"
        )
        button_6.place(
            x=569.0,
            y=559.0,
            width=59.0,
            height=62.0
        )

        window.resizable(False, False)
        window.mainloop()

    def transition(self):
        self.window.destroy()
        self.window = None
        self.Tflag1 = False
        self.Tflag2 = True
