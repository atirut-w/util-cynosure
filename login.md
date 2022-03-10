# `login`
This program is used to log in to a system. The format for the `passwd` file is exactly the same as your standard `passwd` file. The password hash(SHA-512) is stored in the second field of a user entry.

# Example accounts
These two root and non-root accounts are provided for testing purposes.
```
root:8cd824c700eb0c125fff40c8c185d14c5dfe7f32814afac079ba7c20d93bc3c082193243c420fed22ef2474fbb85880e7bc1ca772150a1f759f8ddebca77711f:0:0:Root account:/:/bin/sh.lua
test:9ece086e9bac491fac5c1d1046ca11d737b92a2b2ebd93f005d7b710110c0a678288166e7fbe796883a4f2e9b3ca9f484f521d0ce464345cc1aec96779149c14:1:1:Test account:/home/test:/bin/sh.lua
```

Login details:
- `root`
  - Password: `root`
- `test`
  - Password: `test`
