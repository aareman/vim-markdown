# Markdown for Neo/Vim

A complete environment to create Markdown files with great syntax highlighting and support for key 
productivity features in markdown.

This is a Fork of https://github.com/gabrielelana/vim-markdown which is a very lightweight project. 

Why another markdown plugin for vim? Frankly, why this fork? The answer is that I haven't loved other markdown 
options. The vim-pandoc is very good, but does a little too much for what I need, and the documentation is
challenging to work through. The PlasticBoy plugin is good as well, but also does too much and has way too 
many options for me. Finally, the reason for this fork is that this is a great plugin, but it needs some tweaking
and the structure is a bit brittle to customize. To this end, the goal of this fork is to refactor the original
plugin split out unneseccary bits, and add some key integreations with other vim plugins and unix tools. As part
of the refactor, all the keymaps will be split out into `<Plug>` s which is more vimonic, and allows for people
to use the parts of the plugin that they choose.

This is primarily for my personal use, but if anyone finds it useful, feel free to star it. If you find an 
issue, submit a PR or open an issue.

## TODO:

- [x] Table Manipulation (courtesy of [vim-table-mode](https://github.com/dhruvasagar/vim-table-mode))
- [x] Full syntax highlighting (except code blocks, though focus mode handles working on a block in its syntax environment)
- [x] Checklists
- [ ] export mode (via pandoc)
    - [ ] to pdf
    - [ ] to html
    - [ ] to bootstrap
    - [ ] to beamer
    - [ ] other
        - [ ] doc
        - [ ] powerpoint
    - [ ] configurable:
        - [ ] output location (default inline)
        - [ ] output filename (defualt same as current file)
        - [ ] mapping to open rendered output in pdf viewer
        - [ ] add new export types + commands
        - [ ] TODO: keep the export menu one dimensional if possible
- [x] make empty check items clear if at end of list
- [ ] make list items not clear unless at end of list with <cr>
- [x] fix list formatting numbers 1. & and checkboxes [ ] [x] 


## Features

- Strong support for the Markdown flavor implemented by GitHub: what you see in Vim is what you get on GitHub
- Complete syntax implementation: supports proper nesting of all elements in list items. This is the only plugin that is able to do that (and I believe it since it took me a *while* to make it right)
- Code blocks and pieces of Markdown in the current file can be edited in a separate buffer and synchronized back when you finish
    - Inside a Ruby fenced code block, `<Leader>e` opens a temporary buffer with the right file type
    - Select a range in visual mode and `<Leader>e` opens a temporary buffer with file type `markdown`. I call it *Focus Mode* because you can edit a portion of a Markdown file in isolation
    - Finally, on an empty line, `<Leader>e` asks for a file type and then opens a temporary buffer with that file type
    - When you leave the temporary buffer the content syncs back to the main file
    ![EditCodeBlock](https://github.com/gabrielelana/vim-markdown/raw/master/images/vim_markdown_edit_code_block.gif)
- Folding for: headers, code blocks and html blocks
- Format tables automatically (requires [`Tabular`](https://github.com/godlygeek/tabular) plugin)

## Installation

If you use [vim-plug](https://github.com/junegunn/vim-plug), add the following to your plugin section:

```vim
Plug 'aareman/vim-markdown'
```

## Dependencies

```vim
" Required (unless disabled, see configuration options)
Plug 'dhruvasagar/vim-table-mode'

" Recommended
Plug 'ferrine/md-img-paste.vim'
Plug 'vim-pandoc/vim-pandoc-syntax'
```

*note - all of the dependencies should be included before the main plugin in `vim-plug`*


## Documentation

This section will contain preliminary documentation until full documentation is written.

### Configuration

By default settings are enabled. To disable them, set the corresponding setting variable to true.

```vim
let  g:markdown_disable_folding             =   0
let  g:markdown_disable_motions             =   0
let  g:markdown_disable_spell_checking      =   0
let  g:markdown_disable_conceal             =   0
let  g:markdown_disable_table_mode          =   0
let  g:markdown_disable_pandoc_integration  =   0
let  g:markdown_disable_clear_empty_on_cr   =   0
```

### Optional Mappings

| Mode     | Mapping                                |
|----------|----------------------------------------|
| `normal` | `<Plug>(vim-markdown-toggle-checkbox)` |
| `normal` | `<Plug>(vim-markdown-edit-code-block)` |
| `visual` | `<Plug>(vim-markdown-edit-code-block)` |

### Motions

- `]]` start of the next header
- `[[` start of the previous header

### Tables

- vim table mode is enabled by default
- to toggle it off use `<leader>tm`
- see the table mode docs `:help vim-table-mode`

### Removed Features

- Jekyll Support

## Known Issues

- `formatlistpat` doesn't work for ordered lists
- `formatoptions` thinks that `*` in horizontal rules are list items
- checklists will auto insert a completed item when you press enter from a line with a completed item

If you use https://github.com/Yggdroot/indentLine I recommend setting the following in your vimrc

```vim
let g:indentLine_concealcursor=""
```

## Development

### Syntax Specs

Testing syntax highlighting can be tricky. Here I use the golden master pattern to at least avoid regressions. This is how it works: in `./rspec/features` you will find a bunch of `*.md` files, one for each syntactic element supported. For each of those files there's an HTML file. This file is created with the `:TOhtml` command and it's the reference (aka golden master) of the syntax highlight of the original file. Running `rspec` compares the current syntax highlighting of all the feature's files with the reference syntax highlighting. If you see something wrong when looking at some of the feature's files, you can fix it and then regenerate the golden master files with `GENERATE_GOLDEN_MASTER=1 rspec`

