---
title: TypeScript's paths option in tsconfig.json could be evil
author: Mariano Benedettini
pubDatetime: 2024-11-05
hero: 
description: Using TypeScript's paths could be problematic in some scenarios.
tags:
  - typescript
---

Until not so long ago I was an avid user of TypeScript's `paths` feature, it
really helps to keep imports short and clean. Adding a paths option like this to
`tsconfig.json` is something that I guess most of us have done at some point:

```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

What I missed or naively overlooked was the fact that the plain JavaScript code
emitted does not get these aliases resolved. That means that if you are going to
consume your TypeScript code with paths from a plain JavaScript app you will
have to roll up your sleeves and do some extra work to make it work.

<br></br>

[tsconfig-paths](https://github.com/dividab/tsconfig-paths) is a popular
alternative to solve this. However, it works at runtime and relies on
`tsconfig.json`, making it not an option in the prior scenario I described: you
won't be able to have your TypeScript configuration available outside your
project.

Even in a monorepo project you would have to have all your path aliases in a
root `tsconfig.json` file, from which all workspaces import, for that to work
flawlessly, which is far from ideal in a large codebase.

<hr></hr>

For my particular case I ended up using
[tsc-alias](https://github.com/justkey007/tsc-alias) which works at build time
by replacing the aliases with the actual paths inline in the emitted JavaScript
code.

So my build and watch commands ended up looking like this:

```json
{
  "build": "tsc && tsc-alias",
  "watch": "concurrently \"tsc --watch\" \"tsc-alias --watch\""
}
```

`tsc-alias` works and works great, but I do think that it fixes the kind of
pitfall that drives people away from TypeScript: not the language itself but
potential issues with the tooling around the language.

I would definitely use `paths` again in projects that will never be consumed by
any other project, such as Frontend code. I think I'll think it twice in
packages such as schemas, database access, etc, that are likely to be actively
consumed by other projects.
