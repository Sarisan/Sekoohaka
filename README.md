# Sekoohaka

Telegram Image Board Bot written in Z Shell (zsh)

Search posts, pools and tags on various booru-like Image Boards,  
Authorize to expand limits and access private favorites,  
View post information, tags, get original file,  
Do MD5 hash lookup to find post by a hash,  
Reverse search image with SauceNAO,  
Create and save inline shortcuts

## Requirements

### Commands

BusyBox is a hard-coded dependency and cannot be replaced with alternatives!

* zsh
* busybox
* curl
* jq
* recode

For distribution specific installation commands follow [command-not-found](https://command-not-found.com/).

### BusyBox functions

* base64
* cut
* find
* grep
* head
* ls
* sed
* sha1sum
* sleep
* tail
* tar

## Deployment

Usage: `./bot.zsh [options] [token]`

For better performance, it is recommended to use a locally deployed [Telegram Bot API](https://github.com/tdlib/telegram-bot-api) server.

### Available options

```
Options:
  -h            Show help information
  -a <addr>     Telegram Bot API address, default: api.telegram.org
  -o            Allow SauceNAO with unknown Telegram Bot API instance
  -l            Use local Telegram Bot API, address: 127.0.0.1:8081
  -r <num>      Inline results limit, max: 50, default: 10
  -g <num>      Shortcuts storage limit, max: 10000, default: 500
  -m <mode>     Cache mode, default: normal
  -t <secs>     Cache expiration time, max: 1000, default: 300 secs
  -s <secs>     Sleep duration time, max: 100, default: 10 secs
  -c            Do not clear cache automatically
  -q            Do not print logs
  -i <secs>     Telegram Bot API connetion timeout, max: 5, default: 5 secs
  -e <secs>     Image Boards API connetion timeout, max: 5, default: 5 secs
  -f <secs>     Connrefused timeout, max: 2, default: none
  -n <addr>     Proxy server for Telegram Bot API
  -x <addr>     Proxy server for Image Boards/SauceNAO API
  -k <key>      SauceNAO API key for public use

Cache modes:
  none          No cache reuse
  normal        Reuse inline results and posts cache
  advanced      Extract posts cache from inline results
```

## Supported Image Boards

* [Safebooru](https://safebooru.donmai.us/)
* [Danbooru](https://danbooru.donmai.us/)
* [Idol Complex](https://www.idolcomplex.com/)
* [Sankaku Channel](https://www.sankakucomplex.com/)
* [Konachan](https://konachan.com/)
* [Yandere](https://yande.re/)

## Donation

If you want to support this bot development you can donate any amount of these cryptocurrencies

| Currency | Address |
| :---: | :---: |
| BTC | `bc1qqr8yryvx43y6p3kg7y2cw32w6tv748el7k38ff` |
| ETH | `0x8993D744dF7183e112E2A4489991890f6a143104` |
| BNB | `0x8993D744dF7183e112E2A4489991890f6a143104` |
| TON | `UQBdoPQq3akozSLiWqt6x2Rizv0TrxHzRjczoztFN-LMCwGO` |
