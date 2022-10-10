# personal-stuff
A repository containing small code I make use of

## FinTS
Encrypt your online banking login for `banking.py` with chosen password and generated salt in `DO_NOT_DELETE_ME.bin`:
```sh
python encrypter.py
Password: # password of choice
Data: # Your online banking login
Entry: banking_login

python encrypter.py
Password: # password you just typed in
Data: # Your online banking pin
Entry: banking_pin
```

Decrypt the data again and access your banking information with FinTS Api:
```sh
python banking.py
Password: # password you chose

======
OUTPUT
======

Balance: 4.20€
```

## Theme Changer
Toggles active theme of Windows Terminal and Helix editor. Add to `.zshrc` or `.bashrc`:
```sh
alias tt="node /.../winTerminalToggleColorMode.js"
```