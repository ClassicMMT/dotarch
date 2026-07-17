keyd config
================================

What it is
------------

Adds system wide key remappings:

  - ``Cmd + Left/Right``   → Home / End
  - ``Cmd + Up/Down``      → document start / end
  - ``Cmd + Backspace``   → delete to start of line
  - ``Alt + Left/Right``   → jump one word (``Shift`` to select)
  - ``Alt + Backspace``   → delete previous word
  - ``Alt + h / Alt + l`` → browser Back / Forward

Fresh install
------------------------

::

    sudo pacman -S keyd
    sudo ln -sf ~/.dotfiles/etc/keyd/default.conf /etc/keyd/default.conf
    sudo systemctl enable --now keyd

