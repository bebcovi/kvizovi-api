# Kvizovi API [![travis](https://travis-ci.org/twin/kvizovi-api.svg)](https://travis-ci.org/twin/kvizovi-api)

## Setup

* `brew install postgres` (>= 9.4)
* `brew install elasticsearch` (>= 1.5)
* `brew install redis` (>= 2.8)
* `rbenv install 2.2.2; rbenv global 2.2.2`
* `gem install bundler; bundle install`
* `createdb kvizovi_development; bundle exec rake db:migrate`
* `gem install foreman`
* `gem install mailcatcher -v 0.5.12`
* `foreman start`

Now you have the API running on `localhost:3000`, and you can see sent emails
on `localhost:1080`.

### Migrating legacy database

* `heroku pg:pull DATABASE kvizovi_legacy --app kvizovi`
* Request for the `.env` file with credentials
* `bundle exec rake legacy:migrate`

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
* [**Errors**](#errors)

## Introduction

All requests should be sent and all responses are returned in the JSON format,
according to the [JSON API specification](http://jsonapi.org).

```http
POST /quizzes HTTP/1.1
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
GET /quizzes HTTP/1.1
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

See the [Errors](#errors) section for all errors than can occur.

In general you can retrieve resource relationships by passing in the `include`
query parameter:

```http
GET /quizzes/15?include=questions HTTP/1.1
Content-Type: application/json

{
  "data": {
    "type": "quizzes",
    "id": "15",
    "attributes": {
      "name": "Game of Thrones",
      "category": "movies"
    },
    "relationships": {
      "questions": {
        "data": [
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
        "kind": "choice",
        "title": "What is Ramsay Snow's family name?"
      }
    },
    {
      "type": "questions",
      "id": "17",
      "attributes": {
        "kind": "boolean",
        "title": "Daenerys locked all of her 3 dragons in the dungeon."
      }
    }
  ]
}
```

There is also a URL available for checking the connection to the server (e.g.
so that you can alert the user if they're offline):

```http
HEAD /heartbeat HTTP/1.1
```

## Users

| Attribute    | Type   | Description                               |
| ---------    | ----   | -----------                               |
| `id`         | string | unique identifier                         |
| `name`       | string | name that will be displayed for that user |
| `email`      | string | email address                             |
| `token`      | string | authorization token                       |
| `avatar`     | image  | profile image                             |
| `created_at` | time   | when the user has registered              |
| `updated_at` | time   | when the user was last updated            |

Users can have the following relationships included:

* `quizzes`
* `gameplays`
* `creator` (assignable)
* `players`

The "players"--"creator" relationship is a generalization of
"students"--"teacher".

### Creating users

```http
POST /account?include=creator HTTP/1.1
Content-Type: application/json

{
  "data": {
    "type": "users",
    "attributes": {
      "name": "Junky",
      "email": "janko.marohnic@gmail.com",
      "password": "secret"
    },
    "relationships": {
      "creator": {
        "data": {"type": "users", "id": "32"}
      }
    }
  }
}
```

To assign creators, you can use users' [typeahead endpoint](#user-typeahead).

If the user is successfully registered, a confirmation email will be sent
to their email address. The email will include a link to
`http://kvizovi.org/account/confirm?token=abc123`. When user visits that URL,
the appropriate request has to be made to the API:

```http
PATCH /account/confirm?token=abc123 HTTP/1.1
```

### Retrieving users

You can retrieve users with their username and password (login), using basic
authentication:

```http
GET /account HTTP/1.1
Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ
```

(This raises a `credentials_invalid` error if email or password were incorrect.)
You can also use token authentication (contained in users's "token" field):

```http
GET /account HTTP/1.1
Authorization: Token token="abc123"
```

#### Retreiving players

You can retrieve all players of a user:

```http
GET /account/players HTTP/1.1
Authorization: Token token="abc123"
```

#### User typeahead

```http
GET /account/typeahead?q=prelog&count=5 HTTP/1.1
```

### Updating users

When updating the password, the user has to provide the old password:

```http
PATCH /account HTTP/1.1
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
POST /account/password?email=janko.marohnic@gmail.com HTTP/1.1
```

(An `email_invalid` error will be raised if user with that email doesn't exist.)
This will send the password reset instructions to the user's email address.
The email will include a link to
`http://kvizovi.org/account/password?token=abc123`. When the user visits the
link and enters the new password, an API request needs to be made with
the password reset token included:

```http
PATCH /account/password?token=abc123 HTTP/1.1
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
DELETE /account HTTP/1.1
Authorization: Token token="abc123"
```

## Quizzes

| Attribute         | Type    | Description                                      |
| ---------         | ----    | -----------                                      |
| `id`              | string  | unique identifier                                |
| `name`            | string  | name that will be displayed                      |
| `category`        | string  | e.g. "books", "movies", "history", ...           |
| `active`          | boolean | whether the quiz is playable                     |
| `shuffle`         | boolean | whether questions should be shuffled             |
| `questions_count` | integer | how many questions does this quiz currently have |
| `image`           | image   | the image describing the quiz                    |
| `created_at`      | time    | when the quiz was created                        |
| `updated_at`      | time    | when the quiz was last updated                   |

Quizzes can have the following associations included:

* `questions`
* `creator`
* `gameplays`

### Retrieving quizzes

To return quizzes from a user, include users's token:

```http
GET /quizzes HTTP/1.1
Authorization: Token token="abc123"
```
```http
GET /quizzes/23 HTTP/1.1
Authorization: Token token="abc123"
```

To search all quizzes (e.g. for playing), just omit the authorization token:

```http
GET /quizzes?q=matrix HTTP/1.1
```
```http
GET /quizzes?category=movies HTTP/1.1
```
```http
GET /quizzes?page[number]=1&page[size]=10 HTTP/1.1
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
POST /quizzes HTTP/1.1
Authorization: Token token="abc123"
Content-Type: application/json

{
  "data": {
    "type": "quizzes",
    "attributes": {
      "name": "Game of Thrones",
      "category": "movies",
      "active": true,
    }
  }
}
```

### Updating quizzes

```http
PATCH /quizzes/1 HTTP/1.1
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
DELETE /quizzes/1 HTTP/1.1
Authorization: Token token="abc123"
```

This will delete the quiz and its associated questions.

## Questions

| Attribute    | Type    | Description                                    |
| ---------    | ------  | -----------                                    |
| `id`         | string  | unique identifier                              |
| `kind`       | string  | e.g. "boolean", "choice", ...                  |
| `title`      | string  | main statement of the question                 |
| `content`    | json    | kind-specific content (e.g. provided answers)  |
| `hint`       | string  | help for answering the question                |
| `position`   | integer | ordinal number of the question inside the quiz |
| `image`      | image   | artwork for the question                       |
| `created_at` | time    | when the question was created                  |
| `updated_at` | time    | when the question was last updated             |

Questions can have the following relationships included:

* `quiz`

### Retrieving questions

```http
GET /quizzes/12?include=questions HTTP/1.1
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
    "relationships": {
      "questions": {
        "data": [
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
        "kind": "choice",
        "title": "What is Ramsay Snow's family name?"
      }
    },
    {
      "type": "questions",
      "id": "17",
      "attributes": {
        "kind": "boolean",
        "title": "Daenerys locked all of her 3 dragons in the dungeon."
      }
    }
  ]
}
```

You can also retrieve questions directly:

```http
GET /quizzes/1/questions HTTP/1.1
Authorization: Token token="abc123"
```
```http
GET /quizzes/1/questions/54 HTTP/1.1
Authorization: Token token="abc123"
```

### Creating questions

```http
POST /quizzes HTTP/1.1
Authorization: Token token="abc123"
Content-Type: application/json

{
  "data": {
    "type": "quizzes",
    "attributes": {
      "name": "Game of Thrones",
      "category": "movies",
      "questions_attributes": [
        {"kind": "boolean", "title": "...", "content": {}, "hint": "...", "position": 1},
        {"kind": "choice", "title": "...", "content": {}, "hint": "...", "position": 2},
      ]
    }
  }
}
```

You can also create questions directly:

```http
POST /quizzes/1/questions HTTP/1.1
Authorization: Token token="abc123"
Content-Type: application/json

{
  "data": {
    "type": "questions",
    "attributes": {
      "kind": "choice",
      "title": "Stannis won the battle at Blackwater Bay.",
    }
  }
}
```

### Updating questions

```http
PATCH /quizzes/23 HTTP/1.1
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
PATCH /quizzes/23/questions/11 HTTP/1.1
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
DELETE /quizzes/23/questions/11 HTTP/1.1
Authorization: Token token="abc123"
```

## Gameplays

| Attribute       | Type    | Description                            |
| ---------       | ----    | -----------                            |
| `id`            | string  | unique identifier                      |
| `quiz_snapshot` | json    | snapshot of the played quiz            |
| `answers`       | json    | users' answers to the quiz             |
| `players_count` | integer | number of players that played the quiz |
| `started_at`    | time    | when the gameplay has started          |
| `finished_at`   | time    | when the gameplay has finished         |

Gameplays can have the following associations included:

* `players` (assignable)
* `quiz` (assignable)

### Saving gameplays

```http
POST /gameplays HTTP/1.1
Content-Type: application/json
Authorization: Token token="fg0d9sl"

{
  "data": {
    "type": "gameplays",
    "attributes": {
      "quiz_snapshot": {"name": "Game of Thrones", "questions": []},
      "answers": {},
      "started_at": "2015-05-03T21:17:30+02:00",
      "finished_at": "2015-05-03T21:20:30+02:00",
    },
    "relationships": {
      "quiz": {
        "data": {"type": "quizzes", "id": "32"}
      },
      "players": {
        "data": [
          {"type": "users", "id": "44"},
          {"type": "users", "id": "51"}
        ]
      }
    }
  }
}
```

### Retrieving gameplays

You can retrieve gameplays as a creator (returns gameplays of quizzes that
the user created, but only ones which were played by their "students") or as a
player (returns gameplays that the user played).

```http
GET /gameplays?as=player&quiz_id=44 HTTP/1.1
Authorization: Token token="abc123"
```

```http
GET /gameplays?as=creator&quiz_id=44 HTTP/1.1
Authorization: Token token="abc123"
```

```http
GET /gameplays?as=creator&page[number]=1&page[size]=10 HTTP/1.1
Authorization: Token token="abc123"
```

You can retrieve single gameplays and include associations:

```http
GET /gameplays/43?include=players,quiz HTTP/1.1
Authorization: Token token="abc123"
```

## Images

Users, quizzes and questions can all have images attached. You can assign an
uploaded file to fields of type `image`, and that field will be displayed as
a hash of sizes.

```http
PATCH /quizzes/34 HTTP/1.1
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
      "image": {
        "small": "http://example.org/attachments/store/fit/300/300",
        "medium": "http://example.org/attachments/store/fit/500/500",
        "large": "http://example.org/attachments/store/fit/800/800"
      }
    }
  }
}
```

The sizes have to be predefined for security reasons, but you can change them
in the source code for [users](/lib/kvizovi/mappers/user_mapper.rb),
[quizzes](/lib/kvizovi/mappers/quiz_mapper.rb) and
[questions](/lib/kvizovi/mappers/question_mapper.rb).

You can also pass an image as a URL, in this case `{"avatar_remote_url":
"http://example.com/image.jpg"}`.

To delete an image, send `{"avatar_remove": true}`.

### Direct upload

While the above scenario works, users will have to wait for the image to upload
after submitting the form. If you want to improve the user experience, you can
add "direct uploading". Direct uploading means that the image starts uploading
in the background the moment user selects it.

For direct uploading, send a file as `file` to the endpoint:

```http
POST /attachments/cache HTTP/1.1
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
PATCH /account HTTP/1.1
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
POST /contact HTTP/1.1
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

## Errors

User errors (the client should rescue these and display an apropriate message
to the user):

| Identifier            | Status | Description                                           |
| ----------            | ------ | -----------                                           |
| `credentials_invalid` | 401    | Incorrect email or password                           |
| `email_invalid`       | 401    | No user with that email address                       |
| `account_expired`     | 401    | Account hasn't been confirmed by email                |
| `resource_not_found`  | 404    | Raised when a requested resource wasn't found         |
| `validation_failed`   | 400    | Raised when the validation of the resource has failed |

Other errors:

| Identifier                     | Status | Description                                                                                   |
| ----------                     | ------ | -----------                                                                                   |
| `authorization_missing`        | 401    | No authorization credentials given                                                            |
| `token_missing`                | 401    | No authorization token given                                                                  |
| `token_invalid`                | 401    | No user with that token                                                                       |
| `confirmation_token_invalid`   | 401    | Confirmation token doesn't exist                                                              |
| `password_reset_token_invalid` | 401    | Password reset token doesn't exist                                                            |
| `param_missing`                | 400    | Raised when a parameter is missing from the request (either a query parameter, or a JSON key) |
| `page_not_found`               | 404    | Raised when the route wasn't recognized                                                       |
| `invalid_attribute`            | 400    | Raised when an unkown or forbidden resource attribute was included in the request             |
