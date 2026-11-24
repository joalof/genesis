# VisiData vim keymap cheat sheet

Keymap defined in [`config.py`](config.py), written against VisiData 3.4. The leader is `,`.

Anything not listed here can be run by name: `:` (or `Space`) opens the command palette.
To see every binding on the current sheet, press `,h`.

## How it's organised

- **Vim keys do the vim thing:** `hjkl`, `gg`/`G`, `0`/`$`, `/`, `n`, `u`, `.`, `i`, `o`, `p` and so on.
- **`d` / `y` / `c` are operators.** Follow one with a target:

  | Target | Cut (`d`) | Copy (`y`) | Change (`c`) |
  |---|---|---|---|
  | row (doubled key) | `dd` | `yy` | – |
  | cell (`w`, "word") | `dw` | `yw` | `cw` |
  | selected rows (`v`, "visual") | `dv` | `yv` | `cv` |
  | column (`c`) | `dc` (hide) | `yc` | `cc` (rename) |

- **Registers:** `"+` uses the system clipboard; `"_` deletes without copying.
- **`v` / `V`** add rows to / remove rows from the selection. Rows stay selected until you unselect them; there's no visual mode.
- **`z` fold keys** expand and collapse nested data.
- **`,` (leader)** holds the VisiData features vim has no key for.

## Motion

| Keys | Action |
|---|---|
| `h` `j` `k` `l` | left / down / up / right |
| `gg` `G` | first / last row |
| `0` `^` `$` | first / first / last column |
| `H` `M` `L` | top / middle / bottom row on screen |
| `<C-d>` `<C-u>` | half page down / up |
| `<C-f>` `<C-b>` | page down / up |
| `<C-e>` `<C-y>` | scroll down / up one row |
| `zz` | center the current row on screen |
| `w` `b` | next / previous *different* value in this column |
| `}` `{` | next / previous empty cell in this column |
| `)` `(` | next / previous selected row |
| `f` | go to a column by name |
| `\|` | go to a column by number |
| `go` | go to a row by number |
| `zh` `zj` `zk` `zl` | scroll the text inside a wide cell |

## Sheets

| Keys | Action |
|---|---|
| `<C-o>` `<C-^>` | previous sheet |
| `<A-1>`…`<A-9>`, `<A-0>` | jump to sheet 1–10 |
| `-` | parent sheet (the sheet this one came from) |
| `gt` `gT` | next / previous sheet in the same file (e.g. xlsx tabs) |
| `gf` | open the file or URL named in this cell |
| `gx` | open this cell in `$BROWSER` |
| `,s` `,S` | list open sheets / all sheets this session |
| `U` | reopen the last closed sheet |

## Search

| Keys | Action |
|---|---|
| `/` `?` | search this column forward / backward (regex) |
| `n` `N` | next / previous match |
| `g/` `g?` | search all columns forward / backward |
| `z/` `z?` | search by Python expression forward / backward |
| `*` `#` | next / previous row with the same value as this cell |
| `,k` | find a row by its key column |
| `,/` | clear search highlighting |

## Editing

| Keys | Action |
|---|---|
| `i` `a` | edit this cell |
| `cw` | clear this cell, then edit it |
| `ce` | edit this cell in `$EDITOR` |
| `o` `O` | new row below / above |
| `x` | cut this cell |
| `p` `P` | paste rows after / before this row |
| `gp` | paste into this cell |
| `gP` | paste into this column for all selected rows |
| `<C-a>` `<C-x>` | add / subtract 1 (column needs a number type) |
| `u` `<C-r>` | undo / redo |
| `.` | repeat the last change, including what you typed |
| `Q` | start / stop recording a macro |
| `,m` | list macros |

### Change selected cells in this column (`c`)

| Keys | Action |
|---|---|
| `cv` | set them all to one value you type |
| `c=` | set them to a Python expression |
| `cs` `cS` | regex substitute in this column / all columns |
| `cf` | fill empty cells with the value above |
| `ci` | fill with 1, 2, 3, … |

## Cut, copy, delete

| Keys | Action |
|---|---|
| `dd` `dw` `dv` | cut row / cell / selected rows |
| `dc` | hide this column (`u` brings it back, `zE` unhides all) |
| `du` | hide columns where every row has the same value |
| `yy` `yw` `yv` | copy row / cell / selected rows |
| `yc` | copy this column for the selected rows |
| `"+yy` `"+yw` `"+yv` `"+yc` | same, to the system clipboard |
| `"+yn` | copy the column name to the system clipboard |
| `"+p` | paste from the system clipboard |
| `"_dd` `"_dw` `"_dv` `"_x` | delete without copying |

## Selection

| Keys | Action |
|---|---|
| `vv` `<C-v>` | toggle this row |
| `va` `vn` `vi` | select all / none / invert |
| `vG` `vgg` | select from this row to the bottom / top |
| `v)` `v(` | select up to the next / previous selected row |
| `v*` | select rows where this column equals this cell |
| `vr` | select rows identical to this row |
| `vd` | select duplicate rows |
| `v/` `vg/` | select rows matching a regex in this column / any column |
| `v=` | select rows matching a Python expression |
| `VV` | unselect this row |
| `VG` `Vgg` | unselect to the bottom / top |
| `V/` `Vg/` `V=` | unselect by regex / regex in any column / expression |
| `,d` | new sheet with only the selected rows |
| `,D` | new sheet with a copy of all rows |

## Columns

| Keys | Action |
|---|---|
| `cc` | rename this column |
| `dc` | delete (hide) this column; `,w` then saves without it |
| `K` | toggle key column |
| `=` | add a column from a Python expression |
| `+` | add a summary (sum, mean, …) to this column |
| `[` `]` | sort ascending / descending by this column |
| `g[` `g]` | sort by the key columns |
| `z[` `z]` | sort by this column, keeping earlier sort columns first |
| `gz[` `gz]` | add the key columns to the existing sort |
| `<` `>` | fewer / more decimal places |
| `_` | toggle full width (`g_` all columns, `z_` type a width) |
| `<A-h>` `<A-l>` | move this column left / right |
| `<A-j>` `<A-k>` | move this row down / up |
| `,c` `,C` | columns sheet (this sheet / all sheets) |
| `,v` | toggle showing multi-line cells |

### Nested data (folds)

| Keys | Action |
|---|---|
| `zo` `zc` | expand / collapse this column one level |
| `zO` `zC` | expand / collapse this column to a depth you type |
| `zr` `zm` | expand / collapse all columns one level |
| `zR` `zM` | expand / collapse all columns to a depth you type |
| `zE` | unhide all hidden columns |

### Set type (`,t`)

| Keys | Type | Keys | Type |
|---|---|---|---|
| `,ti` | int | `,td` | date |
| `,tf` | float | `,tD` | datetime |
| `,tF` | SI float (1.2k) | `,ta` | any |
| `,tc` | currency | `,tl` | length |
| `,ts` | string | | |

### Add column (`,a`)

| Keys | Action | Keys | Action |
|---|---|---|---|
| `,a=` | Python expression | `,ac` | regex capture groups |
| `,an` | empty | `,ar` | regex substitute |
| `,ai` | 1, 2, 3, … | `,aw` | window of nearby rows |
| `,as` | split by regex | `,a!` | shell command |
| `,af` | frozen copy of this column | | |

## Analysis

| Keys | Action |
|---|---|
| `,f` `,F` | frequency table for this column / the key columns |
| `,p` | pivot |
| `,M` | melt (unpivot) |
| `,T` | transpose |
| `,j` `,J` | join the top two sheets / all sheets |
| `,g` `,G` | plot this column / all numeric columns |
| `,i` `,I` | describe this sheet / all sheets |

## Files and saving

| Keys | Action |
|---|---|
| `,w` | save over the source file, no prompts (like `:w`) |
| `<C-s>` | save as (asks for a filename) |
| `,W` | save all sheets |
| `,e` | open a file |
| `,n` | new empty sheet |
| `,r` | reload from disk |

`,w` writes the sheet *as displayed*: hidden columns are left out, and the sort order and edits are written. A sheet you made inside VisiData (frequency table, pivot, …) is saved under its own name in the current directory.

## Windows and quitting

| Keys | Action |
|---|---|
| `<C-w>s` `<C-w>v` | split the screen |
| `<C-w>w` `<C-w><C-w>` `<Tab>` | switch to the other pane |
| `<C-w>x` | swap the panes |
| `<C-w>o` `<C-w>c` `<C-w>q` | close the split |
| `q` | close this sheet |
| `ZQ` `ZZ` `,q` | quit VisiData |

## Other

| Keys | Action |
|---|---|
| `:` `Space` | run any command by name |
| `,h` `,H` | list commands for this sheet / all sheet types |
| `,o` `,O` | options (global / this sheet) |
| `,l` `,L` | command log (this sheet / everything) |
| `,b` | toggle the sidebar |
| `,E` | show the last error |
| `,x` | evaluate a Python expression and open the result as a sheet |
| `,X` | run a Python statement |
| `,!` | drop into a shell |
| `<C-l>` | redraw |
| `<C-c>` | cancel what's running |
| `<C-z>` | suspend |
| `<C-h>` `<F1>` | help |
| `<A-f>` `<A-e>` `<A-v>` `<A-c>` `<A-r>` `<A-d>` `<A-p>` `<A-s>` | menus |
