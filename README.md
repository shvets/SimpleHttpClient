# SimpleHttpClient

Simple Swift HTTP client package.

    # Commands
    
```sh
swift package generate-xcodeproj
swift package init --type=executable
swift package init --type=library
swift package resolve
swift build
swift test -l
swift test -s <testname>
swift package show-dependencies
swift package show-dependencies --format json
swift -I .build/debug -L .build/debug -lSimpleHttpClient
./.build/debug/grabbook https://audioknigi.club/zeland-vadim-zhrica-itfat
./.build/debug/grabbook --boo http://audioboo.ru/umor/17092-heller-dzhozef-popravka-22.html
./.build/debug/grabbook --zvook http://bookzvuk.ru/zhizn-i-neobyichaynyie-priklyucheniya-soldata-ivana-chonkina-1-litso-neprikosnovennoe-vladimir-voynovich-audiokniga-onlayn/
```

    # Links
    
- https://tim.engineering/break-up-third-party-networking-urlsession
- https://mecid.github.io/2019/04/17/asynchronous-completion-handlers-with-result-type
- https://medium.com/better-programming/better-swift-codable-models-through-composition-a6b109b7e8c7
- https://www.swiftbysundell.com/posts/type-safe-identifiers-in-swift
- https://mecid.github.io/2019/05/22/storing-codable-structs-on-the-disk/
  