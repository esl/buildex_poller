# `buildex_poller`


## Running

```
REPLACE_OS_VARS=true HOSTNAME=$HOST COOKIE=foo _build/prod/rel/buildex_poller/bin/buildex_poller console
```

- This service polls GitHub repos for new tags
- if there are new tags it publishes a message to RabbitMQ using the connection/channels pool

![screen shot 2018-08-17 at 7 51 36 am](https://user-images.githubusercontent.com/1157892/44267068-71e83100-a1f2-11e8-8d73-2bc7a1914733.png)

