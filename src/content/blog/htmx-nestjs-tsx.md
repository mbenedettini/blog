---
title: HTMX + AlpineJS + NestJS + TSX boilerplate / to-do app
author: Mariano Benedettini
pubDatetime: 2024-10-21
hero: 
description: A simple todo app built with HTMX + AlpineJS, NestJS and TSX server side rendering.
tags:
  - htmx
  - alpinejs
  - nestjs
  - tsx
  - typescript
---

# Introduction

Given the hype that [HTMX](https://htmx.org/) has been experiencing lately, I
thought I'd give it a try and build a simple todo app using it.

The main constraint in my mind was keep on using Javascript on server side,
ideally Typescript given that is the language I've been using the most lately
and recently I became more into it thanks to the
[Execute Program](https://www.executeprogram.com/courses/everyday-typescript)
courses.

## Tech decisions

### Why HTMX?

I've been the maintainer of very intrincate Webpack config files, hard to
upgrade and modify or to deal with huge bundle sizes.

I know that some newer tools like Vite tend to help solve those issues but the
main problem persists: we are still delivering a whole load of Javascript to the
client even if we only need a small part of it.

HTMX brings a new old way of thinking web applications: HTML on steroids plus a
no-build approach. The examples I've seen so far are very promising but it seems
that there are still complex apps to be seen that have been built with it.

We even have some good writes for instance from
[Gumroad](https://htmx.org/essays/why-gumroad-didnt-choose-htmx/) where they
explain why they didn't choose HTMX for their product.

## Frontend... app?

I used [AlpineJS](https://alpinejs.dev/) to handle client side state and DOM
manipulation. I found it very intuitive and easy to use and capable of handling
pretty complex interactions although time will say if it is the right choice for
a relatively complex frontend app. I installed it using `pnpm` and referenced it
with a `<script>` tag in the `index.html` file.

Given that I'm also lately using TailwindCSS (and TailwindUI components) I
needed a little build process for which I used concurrently to run it in
parallel with the NestJS server:

```json title="package.json"
"tailwind:dev": "tailwindcss -i ./assets/index.css -o ./assets/dist/index.css --watch",
"start:dev": "concurrently -n tailwind,nest \"pnpm run tailwind:dev\" \"pnpm run nest:dev\"",
"nest:dev": "nest start --watch",
```

The generated `dist/index.css` file is then referenced from `layouts/base.tsx`:

```js title="layouts/base.tsx" lang="tsx"
export default function BaseLayout({ children }: Html.PropsWithChildren) {
  return (
    <>
      {"<!doctype html>"}
      <html lang="en" class="h-full bg-white">
        <head>
          <meta charset="UTF-8" />
          <meta
            name="viewport"
            content="width=device-width, initial-scale=1.0"
          />
          <title>Todo</title>
          <script src="/htmx.org/dist/htmx.min.js" />
          <script defer src="/alpinejs/dist/cdn.min.js" />
          <link
            rel="stylesheet"
            type="text/css"
            href="/assets/fonts/inter/inter.css"
          />
          <link
            rel="stylesheet"
            type="text/css"
            href="/assets/dist/index.css"
          />
        </head>
        <body class="h-full bg-gray-100 p-16">{children}</body>
      </html>
    </>
  );
}
```

### Backend

For small or personal projects opinionated Backend frameworks are the best
choice but this time I've decided to use [NestJS](https://nestjs.com/) given its
popularity and [Drizzle ORM](https://drizzle.dev/) with a SQLite database.

The tricky part was to find a way to use TSX with HTMX since I think that JSX
makes it easy to think in terms of components and it also is a welcome sign for
React developers.

## Server side markup

I couldn't find any reliable solution to use TSX on the server side so I ended
up creating a simple adapter that makes use of
[KitaJS](https://github.com/kitajs/html) to render the components.

The adapter itself is located in
[kita-views.tsx](https://github.com/mbenedettini/nestjs-tsx-htmx-todo-app/blob/main/src/kita-views.tsx)
and can be easily simplified to be used in an Express application by stripping
the NestJS decorators and other specifics.

Allows the usage of a default layout for a whole NestJS controller and
overriding it for specific routes:

```typescript
@Controller("todos")
@DefaultLayout("layouts/base")
export class TodosController {
  // will render views/index.tsx using layouts/base.tsx as layout
  @Get("/")
  @Render("index")
  async index() {
    const todos = await this.todosService.getTodos();
    return { todos };
  }

  // will render views/new-todos.tsx using layouts/new.tsx as layout
  @Get("/new")
  @Render("new-todos")
  async create() {
    return { todos, layout: "layouts/new" };
  }
}
```

The other end of this approach is a few lines in the
[NestJS main file](https://github.com/mbenedettini/nestjs-tsx-htmx-todo-app/blob/main/src/main.ts#L17)
to hook up the adapter. Note that we are using `.js` as extension since NestJS
expects transpiled modules but you can use `.tsx` if you are using `ts-node` or
`tsx` to run the application.
