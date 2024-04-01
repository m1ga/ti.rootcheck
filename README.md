# Root check module for Titanium

Simple way to check for root on your device.
Uses https://github.com/scottyab/rootbeer

```js
import TiRootCheck from 'ti.rootcheck';
if (OS_ANDROID) {
  console.log(rootCheck.isRooted());
} else {
  console.log(rootCheck.isRooted);
}
```

## License

MIT

## Author

* Android: Michael Gangolf
* iOS: [Hans Knöchel](https://github.com/hansemannn)
