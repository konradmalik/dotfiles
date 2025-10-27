#!/usr/bin/env python3

import subprocess
import sys
from datetime import datetime

def exec_command(*args):
    try:
        proc = subprocess.run(args)
        return proc.returncode == 0
    except:
        return False


def notify(title, description):
    if exec_command("notify-send", "-u","normal","-i", "dialog-information", title, description):
        return

    js = f"""
    var app = Application.currentApplication();
    app.includeStandardAdditions = true;
    app.displayNotification({description!r}, {{ withTitle: {title!r} }});
    """
    if exec_command("osascript", "-l", "JavaScript", "-e", js):
        return

    sys.stderr.write("can't send notifications\n")
    sys.exit(1)


def main():
    title = sys.argv[1] if len(sys.argv) > 1 else "notify"
    description = " ".join(sys.argv[2:]) if len(sys.argv) > 2 else "Tiggered via terminal"
    notify(title, description)


if __name__ == "__main__":
    main()

