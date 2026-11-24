"""Vim-flavoured keymap for VisiData (written against v3.4).

Philosophy:
  * Keys that mean something in vim do that thing (hjkl, gg/G, 0/$, H/M/L,
    w/b, {/}, / ? n N * #, u <C-r> ., i o O x p P, q, ZQ, <C-w>...).
  * d / y / c are operators, followed by a noun:
        dd yy        row           (doubled, like a line)
        dw yw cw     cell          ("word")
        dv yv cv     selected rows ("visual")
        dc yc cc     column        (cc renames it)
    "+ prefixes the system clipboard ("+yy, "+p) and "_ is the black hole
    register: "_dd deletes without copying.
  * v/V add/remove rows from the selection. VisiData has no visual mode, so
    rows stay selected until you unselect them.
  * zo/zc and friends fold nested data: they expand and contract columns.
  * Commands vim has no equivalent for go behind the leader (",", as in
    nvim), grouped by mnemonic letter. That includes ,t (set type) and
    ,a (add column).
  * Anything else is reachable by name: ":" (or Space) opens the command palette.

The default letter/symbol bindings on regular sheets are cleared first, so the
old VisiData keys don't linger, along with g/z-prefixed Ctrl keys and the
Ctrl/Alt keys that clash with vim or duplicate a binding below. Untouched:
<C-f> <C-b> <C-l> <C-^> <C-c> <C-z> <C-s> <C-h>, <A-0..9> and the <A-letter> menus.

Cheat sheet: CHEATSHEET.md next to this file.
"""

# .visidatarc/config.py is exec()ed with separate globals and locals, so
# module-level helpers aren't visible from inside functions. Everything lives
# in _setup() and its closures instead.

LEADER = ','


def _setup(leader: str) -> list[list[str]]:
    import re

    from visidata import TableSheet, vd

    # ---------------------------------------------------------------------------
    # Machinery: vim-style key notation -> VisiData keystrokes, auto-prefixes.

    _SHEETS_TO_CLEAR = ('BaseSheet', 'TableSheet', 'PandasSheet')
    _DEFAULT_KEY = re.compile(r'(g|z|gz)?(Shift\+[A-Z]|[!-~])|(g|z|gz)Ctrl\+.+')
    _DROPPED_KEYS = (
        'Ctrl+D', 'Ctrl+E', 'Ctrl+R', 'Ctrl+Y',  # rebound below
        'Ctrl+O', 'Ctrl+V', 'Ctrl+X',  # clash with vim, rebound below
        'Ctrl+P', 'Ctrl+G', 'Ctrl+T', 'Ctrl+K', 'Ctrl+_', 'Ctrl+N',  # rarely used
        'Alt+-', 'Alt++', 'Alt+m',  # duplicates of < > and rarely used
    )
    _sequences: list[list[str]] = []


    def _tokens(seq: str) -> list[str]:
        """'V/' -> ['Shift+V', '/'], '<C-w>s' -> ['Ctrl+W', 's'], '<A-j>' -> ['Alt+j']."""
        toks = []
        for t in re.findall(r'<[CA]-.>|.', seq.replace('<leader>', leader)):
            if t.startswith('<C-'):
                toks.append('Ctrl+' + t[3].upper())
            elif t.startswith('<A-'):
                toks.append('Alt+' + t[3])
            elif 'A' <= t <= 'Z':
                toks.append('Shift+' + t)
            else:
                toks.append(t)
        return toks


    def bind(seq: str, longname: str, cls: str = 'TableSheet') -> None:
        toks = _tokens(seq)
        _sequences.append(toks)
        vd.bindkey(''.join(toks), longname, cls)


    def unbind(key: str, cls: str) -> None:
        vd.bindkeys.get(key, {}).pop(cls, None)


    def _register_prefixes() -> None:
        """Every proper prefix of a bound sequence becomes a VisiData prefix key,
        and any command bound to exactly that key (on any sheet type) is dropped,
        otherwise it would fire before the rest of the sequence is typed."""
        bound = {''.join(t) for t in _sequences}
        for toks in _sequences:
            for i in range(1, len(toks)):
                prefix = ''.join(toks[:i])
                assert prefix not in bound, f'{prefix!r} is both a command and a prefix'
                if prefix not in vd.allPrefixes:
                    vd.allPrefixes.append(prefix)
                    vd.bindkeys.pop(prefix, None)


    # Start from a clean slate: drop the default letter/symbol keys (optionally
    # g/z-prefixed) and g/z-prefixed Ctrl keys on regular sheets. Arrows, Enter,
    # mouse etc. stay, as do plain Ctrl/Alt keys not in _DROPPED_KEYS.
    for _key, _per_sheet in vd.bindkeys.items():
        if _DEFAULT_KEY.fullmatch(_key):
            for _cls in _SHEETS_TO_CLEAR:
                _per_sheet.pop(_cls, None)

    for _key in _DROPPED_KEYS:
        for _cls in _SHEETS_TO_CLEAR:
            unbind(_key, _cls)


    # ---------------------------------------------------------------------------
    # A few commands vim has but VisiData lacks.

    @TableSheet.api
    def search_cell(sheet, backward: bool = False) -> None:
        'Search the current column for the exact value of the current cell (vim * and #).'
        regex = '^' + re.escape(sheet.cursorCol.getFullDisplayValue(sheet.cursorRow)) + '$'
        vd.moveRegex(sheet, regex=regex, regex_flags='', columns='cursorCol', backward=backward)
        sheet.setHighlightRegex({'regex': regex, 'flags': ''}, [sheet.cursorCol])


    @TableSheet.api
    def add_row_above(sheet) -> None:
        idx = sheet.cursorRowIndex
        vd.sync(sheet.addRows([sheet.newRow()], index=idx - 1))
        sheet.cursorRowIndex = idx


    @TableSheet.api
    def add_to_cell(sheet, n: int) -> None:
        value = sheet.cursorTypedValue
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            vd.fail('not a number; set a numeric type first (,ti / ,tf)')
        sheet.cursorCol.setValues([sheet.cursorRow], value + n)


    TableSheet.addCommand(None, 'increment-cell', 'add_to_cell(1)', 'add 1 to the current numeric cell')
    TableSheet.addCommand(None, 'decrement-cell', 'add_to_cell(-1)', 'subtract 1 from the current numeric cell')
    TableSheet.addCommand(None, 'search-cell-next', 'search_cell()', 'search forwards in current column for value of current cell')
    TableSheet.addCommand(None, 'search-cell-prev', 'search_cell(backward=True)', 'search backwards in current column for value of current cell')
    TableSheet.addCommand(None, 'add-row-above', 'add_row_above()', 'insert a blank row above the current row')
    TableSheet.addCommand(None, 'change-cell', 'cursorCol.setValues([cursorRow], None); cursorCol.setValues([cursorRow], editCell(cursorVisibleColIndex))', 'clear current cell and edit it')


    # ---------------------------------------------------------------------------
    # Motion (bound on BaseSheet so canvases/graphs and other sheets get them too)

    B = 'BaseSheet'
    bind('h', 'go-left', B)
    bind('j', 'go-down', B)
    bind('k', 'go-up', B)
    bind('l', 'go-right', B)
    bind('gg', 'go-top', B)
    bind('G', 'go-bottom', B)
    bind('0', 'go-leftmost', B)
    bind('^', 'go-leftmost', B)
    bind('$', 'go-rightmost', B)
    bind('<C-d>', 'go-pagedown-half', B)
    bind('<C-u>', 'go-pageup-half', B)
    bind('<C-e>', 'scroll-down', B)
    bind('<C-y>', 'scroll-up', B)
    bind('-', 'open-source', B)
    bind('<C-o>', 'jump-prev', B)
    bind('gt', 'open-source-next', B)
    bind('gT', 'open-source-prev', B)

    bind('H', 'go-screen-top')
    bind('M', 'go-screen-middle')
    bind('L', 'go-screen-bottom')
    bind('zz', 'scroll-middle')
    bind('w', 'go-next-value')
    bind('b', 'go-prev-value')
    bind('}', 'go-next-null')
    bind('{', 'go-prev-null')
    bind(')', 'go-next-selected')
    bind('(', 'go-prev-selected')
    bind('f', 'go-col-name')
    bind('|', 'go-col-number')
    bind('go', 'go-row-number')
    bind('gf', 'open-cell-file')
    bind('gx', 'open-url')
    bind('zh', 'scroll-cells-left')
    bind('zj', 'scroll-cells-down')
    bind('zk', 'scroll-cells-up')
    bind('zl', 'scroll-cells-right')

    # Search
    bind('/', 'search-col')
    bind('?', 'searchr-col')
    bind('n', 'search-next')
    bind('N', 'searchr-next')
    bind('g/', 'search-cols')
    bind('g?', 'searchr-cols')
    bind('z/', 'search-expr')
    bind('z?', 'searchr-expr')
    bind('*', 'search-cell-next')
    bind('#', 'search-cell-prev')

    # Editing
    bind('i', 'edit-cell')
    bind('a', 'edit-cell')
    bind('cw', 'change-cell')
    bind('o', 'add-row')
    bind('O', 'add-row-above')
    bind('x', 'cut-cell')
    bind('p', 'paste-after')
    bind('P', 'paste-before')
    bind('gp', 'paste-cell')
    bind('gP', 'setcol-clipboard')
    bind('u', 'undo-last', B)
    bind('<C-r>', 'redo-last', B)
    bind('.', 'repeat-input', B)
    bind('<C-a>', 'increment-cell')
    bind('<C-x>', 'decrement-cell')
    bind('U', 'undo-last-quit', B)
    bind('Q', 'macro-record')

    bind('cv', 'setcol-input')
    bind('c=', 'setcol-expr')
    bind('cs', 'setcol-regex-subst')
    bind('cS', 'setcol-regex-subst-all')
    bind('cf', 'setcol-fill')
    bind('ci', 'setcol-incr')
    bind('cc', 'rename-col')
    bind('ce', 'sysedit-cell')

    # Operators: d / y + noun (doubled = row, w = cell, v = selected, c = column)
    bind('dd', 'cut-row')
    bind('dw', 'cut-cell')
    bind('dv', 'cut-selected')
    bind('dc', 'hide-col')
    bind('du', 'hide-uniform-cols')
    bind('yy', 'copy-row')
    bind('yw', 'copy-cell')
    bind('yv', 'copy-selected')
    bind('yc', 'copy-cells')
    bind('"+yy', 'syscopy-row')
    bind('"+yw', 'syscopy-cell')
    bind('"+yv', 'syscopy-selected')
    bind('"+yc', 'syscopy-cells')
    bind('"+yn', 'syscopy-colname')
    bind('"+p', 'syspaste-cells')
    bind('"_dd', 'delete-row')
    bind('"_dw', 'delete-cell')
    bind('"_dv', 'delete-selected')
    bind('"_x', 'delete-cell')

    # Selection
    bind('vv', 'stoggle-row')
    bind('<C-v>', 'stoggle-row')
    bind('va', 'select-rows')
    bind('vn', 'unselect-rows')
    bind('vi', 'stoggle-rows')
    bind('vG', 'select-after')
    bind('vgg', 'select-before')
    bind('v)', 'select-to-next-selected')
    bind('v(', 'select-to-prev-selected')
    bind('v*', 'select-equal-cell')
    bind('vr', 'select-equal-row')
    bind('vd', 'select-duplicate-rows')
    bind('v/', 'select-col-regex')
    bind('vg/', 'select-cols-regex')
    bind('v=', 'select-expr')
    bind('VV', 'unselect-row')
    bind('VG', 'unselect-after')
    bind('Vgg', 'unselect-before')
    bind('V/', 'unselect-col-regex')
    bind('Vg/', 'unselect-cols-regex')
    bind('V=', 'unselect-expr')

    # Columns
    bind('K', 'key-col')
    bind('=', 'addcol-expr')
    bind('+', 'aggregate-col')
    bind('[', 'sort-asc')
    bind(']', 'sort-desc')
    bind('g[', 'sort-keys-asc')
    bind('g]', 'sort-keys-desc')
    bind('z[', 'sort-asc-change')
    bind('z]', 'sort-desc-change')
    bind('gz[', 'sort-keys-asc-add')
    bind('gz]', 'sort-keys-desc-add')
    bind('<', 'setcol-precision-less')
    bind('>', 'setcol-precision-more')
    bind('_', 'resize-col-max')
    bind('g_', 'resize-cols-max')
    bind('z_', 'resize-col-input')
    bind('zo', 'expand-col')
    bind('zc', 'contract-col')
    bind('zO', 'expand-col-depth')
    bind('zC', 'contract-col-depth')
    bind('zr', 'expand-cols')
    bind('zm', 'contract-cols')
    bind('zR', 'expand-cols-depth')
    bind('zM', 'contract-cols-depth')
    bind('zE', 'unhide-cols')
    bind('<A-h>', 'slide-left')
    bind('<A-j>', 'slide-down')
    bind('<A-k>', 'slide-up')
    bind('<A-l>', 'slide-right')

    # Command line, windows, quitting
    bind(':', 'exec-longname', B)
    bind('<C-w>s', 'splitwin-half', B)
    bind('<C-w>v', 'splitwin-half', B)
    bind('<C-w>w', 'splitwin-swap', B)
    bind('<C-w><C-w>', 'splitwin-swap', B)
    bind('<C-w>x', 'splitwin-swap-pane', B)
    bind('<C-w>o', 'splitwin-close', B)
    bind('<C-w>c', 'splitwin-close', B)
    bind('<C-w>q', 'splitwin-close', B)
    bind('q', 'quit-sheet', B)
    bind('ZQ', 'quit-all', B)
    bind('ZZ', 'quit-all', B)

    # Leader
    bind('<leader>f', 'freq-col')
    bind('<leader>F', 'freq-keys')
    bind('<leader>p', 'pivot')
    bind('<leader>M', 'melt')
    bind('<leader>T', 'transpose')
    bind('<leader>j', 'join-sheets-top2')
    bind('<leader>J', 'join-sheets-all')
    bind('<leader>g', 'plot-column')
    bind('<leader>G', 'plot-numerics')
    bind('<leader>i', 'describe-sheet')
    bind('<leader>I', 'describe-all', B)
    bind('<leader>c', 'columns-sheet')
    bind('<leader>C', 'columns-all', B)
    bind('<leader>s', 'sheets-stack', B)
    bind('<leader>S', 'sheets-all', B)
    bind('<leader>o', 'options-global', B)
    bind('<leader>O', 'options-sheet', B)
    bind('<leader>e', 'open-file', B)
    bind('<leader>n', 'open-new', B)
    bind('<leader>r', 'reload-sheet', B)
    # Writes the sheet as displayed (hidden columns are left out) over its
    # source file without asking. <C-s> still prompts for a filename.
    bind('<leader>w', 'save-sheet-really', B)
    bind('<leader>W', 'save-all', B)
    bind('<leader>q', 'quit-all', B)
    bind('<leader>l', 'cmdlog-sheet', B)
    bind('<leader>L', 'cmdlog-all', B)
    bind('<leader>h', 'help-commands', B)
    bind('<leader>H', 'help-commands-all', B)
    bind('<leader>d', 'dup-selected')
    bind('<leader>D', 'dup-rows')
    bind('<leader>m', 'macro-sheet')
    bind('<leader>k', 'search-keys')
    bind('<leader>v', 'toggle-multiline')
    bind('<leader>b', 'sidebar-toggle', B)
    bind('<leader>/', 'highlight-clear')
    bind('<leader>E', 'error-recent', B)
    bind('<leader>x', 'pyobj-expr', B)
    bind('<leader>X', 'exec-python', B)
    bind('<leader>!', 'exec-shell', B)

    bind('<leader>ti', 'type-int')
    bind('<leader>tf', 'type-float')
    bind('<leader>tF', 'type-floatsi')
    bind('<leader>tc', 'type-currency')
    bind('<leader>ts', 'type-string')
    bind('<leader>td', 'type-date')
    bind('<leader>tD', 'type-datetime')
    bind('<leader>ta', 'type-any')
    bind('<leader>tl', 'type-len')

    bind('<leader>a=', 'addcol-expr')
    bind('<leader>an', 'addcol-new')
    bind('<leader>ai', 'addcol-incr')
    bind('<leader>as', 'addcol-split')
    bind('<leader>ac', 'addcol-capture')
    bind('<leader>ar', 'addcol-regex-subst')
    bind('<leader>aw', 'addcol-window')
    bind('<leader>a!', 'addcol-shell')
    bind('<leader>af', 'freeze-col')

    # Sheet types whose own single-key bindings would otherwise be lost to the
    # d/v prefixes.
    bind('dd', 'unset-option', 'OptionsSheet')
    bind('i', 'edit-option', 'OptionsSheet')
    bind('dd', 'delete-plugin', 'PluginsSheet')
    bind('dd', 'term-process', 'ProcessesSheet')
    bind('dv', 'term-selected', 'ProcessesSheet')
    bind('dd', 'delete-cursor', 'Canvas')
    bind('dd', 'delete-cursor', 'TextCanvas')
    for _cls in ('Plotter', 'PyobjSheet', 'XmlSheet'):
        bind('<leader>v', 'visibility', _cls)

    _register_prefixes()
    return _sequences


_keymap = _setup(LEADER)  # the bound key sequences, handy for debugging
