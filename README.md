# Sekoohaka

Telegram Image Board Bot written in POSIX Shell (dash)

## Features

* Authorization
* Inline pool search
* Inline post search
* Inline tag search
* Inline paging
* Inline autopaging
* Inline resume
* Inline quick buttons
* Original file download
* Post information view
* Post tags view
* Inline shortcuts
* Inline shortcuts saving

## Requirements

### Commands

BusyBox is a hard-coded dependency and cannot be replaced with alternatives!

* dash
* busybox
* curl
* jq
* recode

For distribution specific installation commands follow [command-not-found](https://command-not-found.com/).

### BusyBox functions

* base64
* bc
* cat
* cut
* date
* find
* grep
* ls
* mkdir
* rm
* sed
* seq
* sha1sum
* sleep
* tr

## Deployment

It is highly recommended to run it with an empty environment to avoid variable conflict: `env -i ./bot.sh` or `env -i PATH="${PATH}" ./bot.sh` for Termux.
For better performance, it is recommended to use a locally deployed [Telegram Bot API](https://github.com/tdlib/telegram-bot-api) server.

### Available options

```
  -h            Show help information
  -l            Same as -a localhost:8081 -s 20971520
  -a <addr>     Telegram Bot API address, default: api.telegram.org
  -s <size>     Max file size allowed to send with URL, default: 10485760
  -p <addr>     Proxy address for external requests
```

## Usage

### Fields description

* `[command]` - Inline command
* `[b]` - Image board
* `[page]` - Search page number
* `[options]` - Search options
* `[name]` - Search pool or tag name
* `[tags]` - Search tags
* `[id]` - Post ID
* `[query]` - Inline query
* `[login]` - Image board login
* `[key]` - Image board API key or password

### Inline commands

* `help` - Send help message
* `l [b] [page] [options] [name]` - Pool search
* `p [b] [page] [options] [tags]` - Post search
* `t [b] [page] [options] [name]` - Tag search
* `original [b] [id]` - Get original file of post
* `post [b] [id]` - Get infromation of post
* `short [query]` - Create inline shortcut
* `shorts` - List saved inline shortcuts

### Search options

* `a` - Enable autopaging (lpt)
* `c` - Cache query results for 15 seconds (lpt)
* `m` - Show more metadata (p)
* `p` - Show gif/video as preview only (p)
* `q` - Add quick buttons (lpt)

### Commands

* `/help` - Send help message
* `/authorize [b] [login] [key]` - Authorize to image board
* `/original [b] [id]` - Get original file of post
* `/post [b] [id]` - Get infromation of post
* `/short [query]` - Create inline shortcut
* `/shorts` - Manage saved shortcuts
* `/stop` - Remove all user data

### Inline examples

* `p d -mq sakurada_shiro`
* `t d *genshin*`
* `original d 5080413`
* `short p d 1 -amq rating:g blue_archive`

### Supported image boards

* `d` - [Danbooru](https://danbooru.donmai.us/) (auth) (lpt)
* `g` - [Gelbooru](https://gelbooru.com/) (auth) (pt)
* `i` - [Idol Complex](https://idol.sankakucomplex.com/) (auth) (lpt)
* `k` - [Konachan.com](https://konachan.com/) (auth) (lpt)
* `s` - [Sankaku Channel](https://chan.sankakucomplex.com/) (auth) (lpt)
* `y` - [yande.re](https://yande.re/) (auth) (lpt)
