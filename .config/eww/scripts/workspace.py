#!/usr/bin/python
import json
import subprocess


def workspaces():
    j = subprocess.run(['hyprctl', 'workspaces',  '-j'],
                       capture_output=True, text=True).stdout
    ids = list(map(lambda x: x['id'], json.loads(j)))

    j2 = subprocess.run(['hyprctl', 'monitors', '-j'],
                        capture_output=True, text=True).stdout
    cur_wss = list(map(lambda x: x['activeWorkspace']['id'], json.loads(j2)))

    s = ""
    for i in range(1, 11):
        if i in cur_wss:
            s += '  '
        elif i in ids:
            s += '  '
        else:
            s += 'ﱤ  '
    return s


if __name__ == "__main__":
    print(workspaces())
