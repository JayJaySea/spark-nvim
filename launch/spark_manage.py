#!/bin/python3
import subprocess
from io import StringIO
import csv
import os
import sys

def main():
    options = {
        "open": open_note,
        "add": add_note
    }

    if sys.argv[1].strip() in options:
        mk_path("/tmp/spark")
        options[sys.argv[1]]()

    else:
        print("Options: " + list(options.keys()))

def open_note():
    notes_csv = subprocess.check_output(["spark", "list", "notes", "--id", "--title"]).decode()
    notes = csv.reader(StringIO(notes_csv))

    ids = []
    titles = []
    for note in notes:
        ids.append(note[0])
        titles.append(note[1])

    chosen_note = rofi_choose(titles, "Open note:")
    if not chosen_note:
        return

    index = titles.index(chosen_note)
    open_note_by_id(ids[index])

def rofi_choose(items: list, label: str) -> bool:
    chosen = None
    try:
        chosen = subprocess.check_output(
            'echo "{items}" | rofi -dmenu -i -p "{label}"'
                .format(items="\n".join(items), label=label),
            shell=True
        ).decode('utf-8').strip()
    except:
        pass

    return chosen

def open_note_by_id(note_id):
    path = "/tmp/spark/" + note_id + ".spark.md"
    subprocess.call(["spark", "get", "note", note_id, "--path", path], stderr=open("/dev/null"))
    subprocess.call(["alacritty", "-e", "nvim", path])

def add_note():
    template = """#

## References
### Internal
### External"""

    filepath = "/tmp/spark/new_note.spark.md"
    mk_path(filepath)

    with open(filepath, "w") as f:
        f.write(template)

    subprocess.call(["nvim", filepath])

def mk_path(path):
    if not os.path.exists(os.path.dirname(path)):
        try:
            os.makedirs(os.path.dirname(path))
        except OSError as exc: 
            if exc.errno != errno.EEXIST:
                raise

if __name__ == "__main__":
    main()
