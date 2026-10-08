# ScreenPolish for the Omarchy bar

Start, stop and watch a [ScreenPolish](https://github.com/BkashJEE/screenpolish)
recording from the Omarchy bar, so recording does not mean leaving the window
you are recording.

    ●            idle — click to record the screen
    ● 1:24       recording — click to stop
    ● 1:24       paused
    󰔟            finishing — the take is being written

**Left click** records, or stops a recording that is running.
**Middle click** opens the library.

## Install

    omarchy plugin add https://github.com/BkashJEE/screenpolish-omarchy-plugin --enable

It needs ScreenPolish 0.4.1 or newer on your `PATH`:

    curl -fsSL https://github.com/BkashJEE/screenpolish/releases/latest/download/ScreenPolish-installer.run -o sp.run
    chmod +x sp.run && ./sp.run

## How it works

ScreenPolish keeps its state in `~/.config/ScreenPolish/cli/state.json`, along
with its own process id. The widget reads that file every four seconds, and
every second while recording, through `status.sh`, which treats the file as
stale if that process is gone. Nothing is started to ask: ScreenPolish stays
closed when you close it, and the bar costs a `cat`.

Clicking runs `screenpolish record start`, `record stop` or `open`, which start
the app if it is not running.

## Licence

MIT, the same as ScreenPolish.
