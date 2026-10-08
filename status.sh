#!/bin/sh
# What ScreenPolish is doing, read from the state file the app keeps, so the
# bar never has to start the app to ask. Prints the same JSON line as
# `screenpolish status`; exits 1 when the app is not running (no file, or the
# file names a process that is gone, as after a crash).
f="${XDG_CONFIG_HOME:-$HOME/.config}/ScreenPolish/cli/state.json"
[ -r "$f" ] || exit 1
line=$(cat "$f") || exit 1
pid=$(printf '%s' "$line" | sed -n 's/.*"pid":\([0-9][0-9]*\).*/\1/p')
[ -n "$pid" ] && kill -0 "$pid" 2>/dev/null || exit 1
printf '%s\n' "$line"
