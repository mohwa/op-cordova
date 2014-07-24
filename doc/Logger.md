# Logger

Logger is initialized just before SDK initialization. You can change any of the
logger settings by modifying any of the following in the `settings` object:

```
/*** Logger settings ***/

// if this is set to false there will be *no logging* regardless
// change this to true before application initialization to enable logger
isLoggerEnabled: true,

// the log levels are set in the native bridge layer
// choose from: [none, basic, detail, debug, trace, insane]
logLevelForApplication: 'trace',
logLevelForServices: 'trace',
logLevelForServicesWire: 'debug',
logLevelForServicesIce: 'trace',
logLevelForServicesTurn: 'trace',
logLevelForServicesRudp: 'debug',
logLevelForServicesHttp: 'debug',
logLevelForServicesMls: 'trace',
logLevelForServicesTcp: 'trace',
logLevelForServicesTransport: 'debug',
logLevelForCore: 'trace',
logLevelForStackMessage: 'trace',
logLevelForStack: 'trace',
logLevelForWebRTC: 'detail',
logLevelForZsLib: 'trace',
logLevelForSDK: 'trace',
logLevelForZsLibSocket: 'debug',
logLevelForSDK: 'trace',
logLevelForMedia: 'detail',
logLevelForJavaScript: 'trace',

isLoggerColorized: true,
isOutgoingTelnetLoggerEnabled: true,
isTelnetLoggerEnabled: false,
isStandardLoggerEnabled: true,
telnetPortForLogger: '59999',
defaultOutgoingTelnetServer: 'tcp-logger-v1-rel-lespaul-i.hcs.io:8055',
archiveOutgoingTelnetLoggerServer: 'tcp-logger-v1-beta-1-i.hcs.io:8055',
archiveTelnetLoggerServer: '59999',
'localTelnetLoggerPort': 59999,
isOutgoingTelnetColorized: true,
```

> If you change any of the logger settings *after* SDK has been initialized,
> call `OP.refreshLogger` to restart logger with the new settings.
