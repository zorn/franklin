```
$ mix phx.gen.auth Accounts User users --binary-id --web Admin --hashing-lib argon2
```

## TODO:

- rename `log_in` to `sign_in` in the exposed urls (and maybe in the code if it is not too hard)
- Add a site setting to disable registration.
