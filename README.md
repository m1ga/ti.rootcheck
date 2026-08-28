# Root check module for Titanium

Simple way to check for root (Android) / jailbreak (iOS) on your device.

* Android: uses https://github.com/scottyab/rootbeer
* iOS: checks for known jailbreak files (rootful and rootless `/var/jb`), injected tweak libraries,
  `DYLD_INSERT_LIBRARIES`, sandbox escapes (writing outside the container, `fork()`) and
  package manager URL schemes.

```js
import rootCheck from 'ti.rootcheck';
console.log(rootCheck.rooted); // true | false
```

## API

| Property | Type | Description |
|----------|------|-------------|
| `rooted` | `Boolean` (read-only) | `true` if the device is rooted / jailbroken. Always `false` on the iOS simulator. |

## iOS: URL scheme check

To let the module detect package managers via their URL schemes (`cydia://`, `sileo://`, ...)
the schemes have to be whitelisted in your `tiapp.xml`. Otherwise iOS always reports them as
not installed and only the remaining checks are used:

```xml
<ios>
  <plist>
    <dict>
      <key>LSApplicationQueriesSchemes</key>
      <array>
        <string>cydia</string>
        <string>sileo</string>
        <string>zbra</string>
        <string>undecimus</string>
        <string>filza</string>
      </array>
    </dict>
  </plist>
</ios>
```

## Requirements

* Titanium SDK 13.3.0.GA or later
* iOS 12+

## Build

```sh
# Android
cd android && ti build -p android --build-only

# iOS (macOS only)
cd ios && ti build -p ios --build-only
```

The module zip ends up in `<platform>/dist/`.

## License

MIT

## Author

* Android: Michael Gangolf
* iOS: [Hans Knöchel](https://github.com/hansemannn)
