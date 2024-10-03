# Sekoohaka

Telegram Image Board Bot written in POSIX Shell (dash)

## Features

* Authorization
* Inline pool search
* Inline post search
* Inline tag search
* Inline paging
* Inline autopaging
* Inline resuming
* Inline quick buttons
* Original file download
* Post information view
* Post tags view
* Inline shortcuts
* Inline shortcuts saving
* Inline shortcuts search

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
* stat
* tr

## Deployment

It is highly recommended to run it with an empty environment to avoid variable conflict: `env -i ./bot.sh` or `env -i PATH="${PATH}" ./bot.sh` for Termux.
For better performance, it is recommended to use a locally deployed [Telegram Bot API](https://github.com/tdlib/telegram-bot-api) server.

### Available options

```
Options:
  -h            Show help information
  -l            Same as -a 127.0.0.1:8081 -s 20971520
  -a <addr>     Telegram Bot API address, default: api.telegram.org
  -s <size>     Max file size allowed to send with URL, default: 10 MiB
  -r <num>      Inline results limit, max: 50, default: 10
  -g <num>      Shortcuts storage limit, default: 100
  -m <mode>     Caching mode, default: normal
  -t <secs>     Caching time, default: 300 secs
  -i <secs>     Telegram Bot API connetion timeout, default: 10 secs
  -e <secs>     Image Boards API connetion timeout, default: 5 secs
  -d <secs>     Head request connetion timeout, default: 2 secs
  -n <addr>     Proxy server for Telegram Bot API
  -x <addr>     Proxy server for Image Boards API

Caching modes:
  none          No caching
  normal        Cache inline results and posts
  advanced      Extract posts cache from inline results
```

## Usage

### Fields description

* `[command]` - Inline command
* `[b]` - Image Board
* `[page]` - Search page number
* `[options]` - Search options
* `[name]` - Search pool or tag name
* `[tags]` - Search tags
* `[query]` - Search query
* `[id]` - Post ID
* `[login]` - Image Board login or username
* `[key]` - Image Board API key or password

### Inline search

* `pools [b] [page] [options] [name]` - Pools search
* `posts [b] [page] [options] [tags]` - Posts search
* `tags [b] [page] [options] [name]` - Tags search
* `shorts [page] [options] [query]` - Shortcuts search

### Search options

* `a` - Enable autopaging (lpts)
* `m` - Show more metadata (p)
* `p` - Show gif/video as preview only (p)
* `q` - Add quick buttons (lpts)
* `r` - Reverse search order (s)
* `w` - Match full words only (s)

### Inline commands

* `help` - Send help message
* `original [b] [id]` - Get original file of post
* `post [b] [id]` - Get infromation of post
* `short [query]` - Create inline shortcut

### Commands

* `/help` - Send help message
* `/authorize [b] [login] [key]` - Authorize to Image Board
* `/original [b] [id]` - Get original file of post
* `/post [b] [id]` - Get infromation of post
* `/short [query]` - Create inline shortcut
* `/shorts` - Manage saved shortcuts
* `/stop` - Remove all user data

### Inline aliases

* `l` - `pools`
* `p` - `posts`
* `t` - `tags`
* `s` - `shorts`

### Inline examples

* `p d 1 -a rating:g`
* `t d *genshin*`
* `original d 4507929`
* `short p d -mq ringouulu`

### Supported Image Boards

* `d` - [Danbooru](https://danbooru.donmai.us/) (auth) (lpt)
* `g` - [Gelbooru](https://gelbooru.com/) (auth) (pt)
* `i` - [Idol Complex](https://idol.sankakucomplex.com/) (auth) (lpt)
* `k` - [Konachan.com](https://konachan.com/) (auth) (lpt)
* `s` - [Sankaku Channel](https://chan.sankakucomplex.com/) (auth) (lpt)
* `y` - [yande.re](https://yande.re/) (auth) (lpt)
