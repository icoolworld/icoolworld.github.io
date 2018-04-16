---
layout: post
title: vim-vdebug-xdebug
categories: vim
---

```
let g:vdebug_options = {
\    "port" : 9001,
\    "timeout" : 20,
\    "server" : '',
\    "on_close" : 'stop',
\    "break_on_open" : 1,
\    "ide_key" : '',
\    "debug_window_level" : 0,
\    "debug_file_level" : 0,
\    "debug_file" : "/tmp/xdebug.log",
\    "path_maps" : {},
\    "watch_window_style" : 'expanded',
\    "marker_default" : '⬦',
\    "marker_closed_tree" : '▸',
\    "marker_open_tree" : '▾',
\    "continuous_mode"  : 0
\}
 
let g:vdebug_keymap = {
\    "run" : "<S-r>",
\    "run_to_cursor" : "<S-c>",
\    "step_over" : "<S-o>",
\    "step_into" : "<S-i>",
\    "step_out" : "<S-o>",
\    "close" : "<S-g>",
\    "detach" : "<S-d>",
\    "set_breakpoint" : "<S-b>",
\    "get_context" : "<S-g>",
\    "eval_under_cursor" : "<S-e>",
\    "eval_visual" : "<Leader>e"
\}
```