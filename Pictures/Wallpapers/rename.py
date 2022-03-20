#!/usr/bin/env python3


from pathlib import Path

i = 0
paths = set()
for img in sorted(Path(__file__).parent.iterdir(), key=lambda it: it.stem):
    if img.name in paths or img.samefile(__file__):
        continue
    while True:
        i += 1
        path = Path(f"{i:08x}{img.suffix}")
        paths.add(path.name)
        if not path.exists():
            img = img.rename(path) 
            print(img)
            break
