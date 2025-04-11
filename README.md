# Sekoohaka

Telegram Image Board Bot written in POSIX Shell (dash)

## Features

* Authorization
* Inline pools search
* Inline posts search
* Inline tags search
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
* cp
* cut
* date
* find
* grep
* ls
* mkdir
* rm
* sed
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
  -a <addr>     Telegram Bot API address, default: api.telegram.org
  -l            Use local Telegram Bot API, address: 127.0.0.1:8081
  -r <num>      Inline results limit, max: 50, default: 10
  -g <num>      Shortcuts storage limit, max: 10000, default: 100
  -m <mode>     Caching mode, default: normal
  -t <secs>     Caching time, max: 1000, default: 300 secs
  -s <secs>     Sleeping time, max: 100, default: 10 secs
  -c            Clear cache automatically
  -q            Do not print logs
  -u            Collect debug dumps
  -i <secs>     Telegram Bot API connetion timeout, max: 10, default: 10 secs
  -e <secs>     Image Boards API connetion timeout, max: 10, default: 5 secs
  -d <secs>     Head request connetion timeout, max: 10, default: 2 secs
  -n <addr>     Proxy server for Telegram Bot API
  -x <addr>     Proxy server for Image Boards API

Caching modes:
  none          No caching
  normal        Cache inline results and posts
  advanced      Extract posts cache from inline results

Supported Image Boards:
  Danbooru              (https://danbooru.donmai.us/)
  Gelbooru              (https://gelbooru.com/)
  Idol Complex          (https://idol.sankakucomplex.com/)
  Konachan.com          (https://konachan.com/)
  Sankaku Channel       (https://chan.sankakucomplex.com/)
  yande.re              (https://yande.re/)
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
* `donate` - Send donation details

### Commands

* `/help` - Send help message
* `/authorize [b] [login] [key]` - Authorize to Image Board
* `/original [b] [id]` - Get original file of post
* `/post [b] [id]` - Get infromation of post
* `/short [query]` - Create inline shortcut
* `/shorts` - Manage saved shortcuts
* `/stop` - Remove all user data
* `/donate` - Send donation details

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

## Donation

If you want to support this bot development you can donate any amount of these cryptocurrencies

| Currency | Address |
| :---: | :---: |
| BTC | `bc1qqr8yryvx43y6p3kg7y2cw32w6tv748el7k38ff` |
| ETH | `0x8993D744dF7183e112E2A4489991890f6a143104` |
| BNB | `0x8993D744dF7183e112E2A4489991890f6a143104` |
| TON | `UQBdoPQq3akozSLiWqt6x2Rizv0TrxHzRjczoztFN-LMCwGO` |
