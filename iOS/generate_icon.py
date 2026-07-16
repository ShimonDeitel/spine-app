from PIL import Image, ImageDraw

SIZE = 1024
BG = "#312513"  # walnut
img = Image.new("RGB", (SIZE, SIZE), BG)
draw = ImageDraw.Draw(img)

# Shelf baseline
shelf_y = 760
draw.rectangle([100, shelf_y, 924, shelf_y + 60], fill="#493A25")

# Three spines standing on the shelf, varying heights/widths/colors.
spines = [
    # (x0, width, height, color)
    (260, 130, 480, "#8F3B3B"),
    (410, 110, 560, "#B69244"),
    (540, 150, 400, "#2E4A6B"),
]

for x0, w, h, color in spines:
    y0 = shelf_y - h
    y1 = shelf_y
    draw.rounded_rectangle([x0, y0, x0 + w, y1], radius=8, fill=color)
    # spine highlight stripe
    draw.rectangle([x0 + w * 0.15, y0 + 30, x0 + w * 0.85, y0 + 50], fill="#00000030")

img.save("/tmp/spine_icon.png")
print("saved", img.size)
