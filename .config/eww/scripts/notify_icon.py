import subprocess

x = subprocess.run(['makoctl', 'mode'], capture_output=True, text=True).stdout
if 'do-not-disturb' in x:
    print('')
else:
    print('')
