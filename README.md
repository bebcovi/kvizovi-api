# Kvizovi API

## Table of contents

* [**Introduction**](#introduction)
* [**Users**](#users)
  - [Creating users](#creating-users)
  - [Retrieving users](#retrieving-users)
  - [Updating users](#updating-users)
  - [Deleting users](#deleting-users)
* [**Quizzes**](#quizzes)
  - [Creating quizzes](#creating-quizzes)
  - [Retrieving quizzes](#retrieving-quizzes)
  - [Updating quizzes](#updating-quizzes)
  - [Deleting quizzes](#deleting-quizzes)
* [**Questions**](#questions)
  - [Creating questions](#creating-questions)
  - [Retrieving questions](#retrieving-questions)
  - [Updating questions](#updating-questions)
* [**Gameplays**](#gameplays)
  - [Saving gameplays](#saving-gameplays)
  - [Retrieving gameplays](#retrieving-gameplays)
* [**Images**](#images)
  - [Direct upload](#direct-upload)
* [**Contact**](#contact)

## Introduction

All requests should be sent and all responses are returned in the JSON format,
according to the [JSON API specification](http://jsonapi.org).

```http
POST /quizzes
Content-Type: application/json

{
  "data": {
    "type": "quizzes",
    "id": "47",
    "attributes": {
      "name": "Game of Thrones",
      "category": "movies"
    }
  }
}
```

To make authorized requests, include user's token in the "Authorization"
header.

```http
GET /quizzes
Authorization: Token token="abc123"
```

If a request fails, the appropriate response status will be returned, often
following up with an error message:

```http
HTTP/1.1 401 Unauthorized
Content-Type: application/json

{
  "errors": [
    {
      "id": "token_missing",
      "title": "No authorization token given",
      "status": 401
    }
  ]
}
```

There is also a URL available for checking the connection to the server (e.g.
so that you can alert the user if they're offline):

```http
HEAD /heartbeat
```

## Users

| Attribute    | Type    |
| ---------    | ----    |
| `id`         | integer |
| `nickname`   | string  |
| `email`      | string  |
| `token`      | string  |
| `avatar`     | image   |
| `created_at` | time    |
| `updated_at` | time    |

Users can have the following associations included:

* `quizzes`
* `gameplays`

### Retrieving users

You can retrieve users with their username and password (login), using basic
authentication:

```http
GET /account
Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ
```

(This raises a `credentials_invalid` error if email or password were incorrect.)
You can also use token authentication:

```http
GET /account
Authorization: Token token="abc123"
```

### Creating users

```http
POST /account
Content-Type: application/json

{
  "data": {
    "type": "users",
    "attributes": {
      "nickname": "Junky",
      "email": "janko.marohnic@gmail.com",
      "password": "secret"
    }
  }
}
```

If the user is successfully registered, a confirmation email will be sent
to their email address. The email will include a link to
`http://kvizovi.org/account/confirm?token=abc123`. When user visits that URL,
the appropriate request has to be made to the API:

```http
PATCH /account/confirm?token=abc123
```

### Updating users

```http
PATCH /account
Authorization: Token token="abc123"
Content-Type: application/json

{
  "data": {
    "type": "users",
    "id": "3",
    "attributes": {
      "old_password": "secret",
      "password": "new secret"
    }
  }
}
```

#### Password reset

```http
POST /account/password?email=janko.marohnic@gmail.com
```

(An `email_invalid` error will be raised if user with that email doesn't exist.)
This will send the password reset instructions to the user's email address.
The email will include a link to
`http://kvizovi.org/account/password?token=abc123`. When the user visits the
link and enters the new password, an API request needs to be made with
the password reset token included:

```http
PATCH /account/password?token=abc123
Content-Type: application/json

{
  "data": {
    "type": "users",
    "id": "3",
    "attributes": {
      "password": "new secret"
    }
  }
}
```

### Deleting users

```http
DELETE /account
Authorization: Token token="abc123"
```

## Quizzes

| Attribute         | Type    |
| ---------         | ----    |
| `id`              | integer |
| `name`            | string  |
| `category`        | string  |
| `image`           | image   |
| `active`          | boolean |
| `questions_count` | integer |
| `created_at`      | time    |
| `updated_at`      | time    |

Quizzes can have the following associations included:

* `questions`
* `creator`
* `gameplays`

### Retrieving quizzes

To return quizzes from a user, include users's token:

```http
GET /quizzes
Authorization: Token token="abc123"
```
```http
GET /quizzes/23
Authorization: Token token="abc123"
```

To search all quizzes (e.g. for playing), just omit the authorization token:

```http
GET /quizzes?q=matrix
```
```http
GET /quizzes?category=movies
```
```http
GET /quizzes?page[number]=1&page[size]=10
```
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "data": [
    {"type": "quizzes", "id": "17", "attributes": {"title": "Game of Thrones"}},
    {"type": "quizzes", "id": "56", "attributes": {"title": "Sherlock"}}
  ]
}
```

### Creating quizzes

```http
POST /quizzes
Authorization: Token token="abc123"
Content-Type: application/json

{
  "data": {
    "type": "quizzes",
    "attributes": {
      "name": "Game of Thrones",
      "category": "movies"
    }
  }
}
```

### Updating quizzes

```http
PATCH /quizzes/1
Authorization: Token token="abc123"
Content-Type: application/json

{
  "data": {
    "type": "quizzes",
    "id": "1",
    "attributes": {
      "name": "Matrix"
    }
  }
}
```

### Deleting quizzes

```http
DELETE /quizzes/1
Authorization: Token token="abc123"
```

This will delete the quiz and its associated questions.

## Questions

| Attribute    | Type    |
| ---------    | ------  |
| `id`         | integer |
| `type`       | string  |
| `image`      | image   |
| `title`      | string  |
| `content`    | json    |
| `hint`       | string  |
| `position`   | integer |
| `created_at` | time    |
| `updated_at` | time    |

### Retrieving questions

```http
GET /quizzes/12?include=questions
```
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "data": {
    "type": "quizzes",
    "id": "12",
    "attributes": {
      "name": "Game of Thrones",
      "category": "movies"
    },
    "links": {
      "questions": {
        "linkage": [
          {"type": "questions", "id": "9"},
          {"type": "questions", "id": "17"}
        ]
      }
    }
  },
  "included": [
    {
      "type": "questions",
      "id": "9",
      "attributes": {
        "type": "choice",
        "title": "What is Ramsay Snow's family name?"
      }
    },
    {
      "type": "questions",
      "id": "17",
      "attributes": {
        "type": "boolean",
        "title": "Dranaerys locked all of her 3 dragons in the dungeon."
      }
    }
  ]
}
```

You can also retrieve questions directly:

```http
GET /quizzes/1/questions
Authorization: Token token="abc123"
```
```http
GET /quizzes/1/questions/54
Authorization: Token token="abc123"
```

### Creating questions

```http
POST /quizzes
Authorization: Token token="abc123"
Content-Type: application/json

{
  "data": {
    "type": "quizzes",
    "attributes": {
      "name": "Game of Thrones",
      "category": "movies",
      "questions_attributes": [
        {"type": "boolean", "title": "..."},
        {"type": "choice", "title": "..."}
      ]
    }
  }
}
```

You can also create questions directly:

```http
POST /quizzes/1/questions
Authorization: Token token="abc123"
Content-Type: application/json

{
  "data": {
    "type": "questions",
    "attributes": {
      "type": "choice"
      "title": "Stannis won the battle at Blackwater Bay.",
    }
  }
}
```

### Updating questions

```http
PATCH /quizzes/23
Authorization: Token token="abc123"
Content-Type: application/json

{
  "data": {
    "type": "quizzes",
    "id": "23",
    "attributes": {
      "questions_attributes": [
        {"title": "..."},
        {"id": "1", "title": "..."},
        {"id": "2", "_delete": true}
      ]
    }
  }
}
```

* If a question doesn't have an ID, it will be **created**.
* If a question does have an ID, it will be **updated**.
* If a question has an ID and `"_delete": true`, it will be **deleted**.

You can also update and delete questions directly:

```http
PATCH /quizzes/23/questions/11
Authorization: Token token="abc123"
Content-Type: application/json

{
  "data": {
    "type": "questions",
    "id": "11",
    "attributes": {
      "title": "..."
    }
  }
}
```
```http
DELETE /quizzes/23/questions/11
Authorization: Token token="abc123"
```

## Gameplays

| Attribute       | Type      |
| ---------       | ----      |
| `id`            | integer   |
| `quiz_snapshot` | json      |
| `answers`       | json      |
| `players_count` | integer   |
| `started_at`    | time      |
| `finished_at`   | time      |

Gameplays can have the following associations included:

* `players`
* `quiz`

### Saving gameplays

```http
POST /gameplays
Content-Type: application/json
Authorization: Token token="fg0d9sl"

{
  "data": {
    "type": "gameplays",
    "attributes": {
      "quiz_snapshot": {"name": "Game of Thrones", "questions": []},
      "answers": {},
      "start": "2015-05-03T21:17:30+02:00",
      "finish": "2015-05-03T21:20:30+02:00",
    }
    "links": {
      "quiz": {
        "linkage": {"type": "quizzes", "id": "32"}
      },
      "players": {
        "linkage": [
          {"type": "users", "id": "44"},
          {"type": "users", "id": "51"}
        ]
      }
    }
  }
}
```

### Retrieving gameplays

You can retrieve gameplays as a creator (returns all gameplays of quizzes that
the user created) or as a player (returns gameplays that user played).

```http
GET /gameplays?as=player&quiz_id=44
Authorization: Token token="abc123"
```

```http
GET /gameplays?as=creator&quiz_id=44
Authorization: Token token="abc123"
```

```http
GET /gameplays?as=creator&page[number]=1&page[size]=10
Authorization: Token token="abc123"
```

You can retrieve single gameplays and include associations:

```http
GET /gameplays/43?include=players,quiz
Authorization: Token token="abc123"
```

## Images

Users, quizzes and questions can all have images attached. When you send an
attached image (e.g. as `avatar`), the response will include the image URL
template:

```http
PATCH /quizzes/34
Authorization: Token token="abc123"
Content-Type: application/json

{
  "data": {
    "type": "quizzes",
    "attributes": {
      "image": "..."
    }
  }
}
```

```http
HTTP/1.1 200 OK
Content-Type: application/json
{
  "data": {
    "type": "quizzes",
    "id": "32",
    "attributes": {
      "image": "http://example.org/attachments/store/fit/{width}/{height}"
    }
  }
}
```

You only need to replace `{width}` and `{height}` with wanted dimensions.

*__Note__: First time you request an image URL, it will take some time to
process the request. So, to hide slow loading from the user, you could prefetch
the URLs (dimensions) you need in the background.*

You can also pass an image as a URL, just send `{"avatar_remote_url": "http://example.com/image.jpg"}`.

To delete an image, send `{"avatar_remove": true}`.

### Direct upload

While the above scenario works, users will have to wait for the image to upload
after submitting the form. If you want to improve the user experience, you can
add "direct uploading". Direct uploading means that the image starts uploading
in the background the moment user selects it.

For direct uploading, send a file as `file` to the endpoint:

```http
POST /attachments/cache
Content-Type: multipart/form-data
```
```http
HTTP/1.1 200 OK
Content-Type: application/json

{"id": "045m8u1tfjortr1peichiguhouc"}
```

Then, when the user submits the form, instead of the file simply send `{"id":
"..."}` as the `avatar`.

```http
PATCH /account
Authorization: Token token="abc123"
Content-Type: application/json

{
  "data": {
    "type": "users",
    "attributes": {
      "avatar": "{\"id\": \"045m8u1tfjortr1peichiguhouc\"}"
    }
  }
}
```

You can also choose an existing solution –
[refile.js](https://github.com/refile/refile/blob/master/app/assets/javascripts/refile.js).
This requires that you have the following HTML:

```html
<form action="/account" enctype="multipart/form-data" method="post">
  <input name="user[avatar]" type="hidden">
  <input name="user[avatar]" type="file" data-direct="true" data-as="file" data-url="http://api.kvizovi.org/attachments/cache">
</form>
```

One benefit of this existing solution is that it's pure JavaScript (no jQuery),
with good cross-browser compatibility. Another one is that the file input will
automatically receive an `uploading` class during uploading. Third, and most
important, you have the following events automatically dispatched:

* `upload:start`
* `upload:progress`
* `upload:complete`
  * `upload:success`
  * `upload:failure`

## Contact

```http
POST /contact
Content-Type: application/json

{
  "data": {
    "type": "emails",
    "attributes": {
      "from": "foo@bar.com",
      "body": "Hello, I have a problem..."
    }
  }
}
```
