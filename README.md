# Erlang REST API with Cowboy, JSX and MongoDB

This is a simple REST API written in Erlang using the Cowboy HTTP server and JSX for JSON parsing. Data is stored in MongoDB (via Docker).

## Features

- `POST /registration` - Register user
- `POST /login` - Login user
- `GET /user/:id` - Get user
- `POST /user` - Create user
- `PUT /user/:id` - Update user
- `DELETE /user/:id` - Delete user

## Setup

### 1. Start MongoDB

```bash
docker-compose up -d
```

### 2. Compile & Run

```bash
rebar3 compile
erl -pa _build/default/lib/*/ebin -s myapp_app start
```

## Notes

- MongoDB is accessed using the [mongodb-erlang](https://github.com/comtihon/mongodb-erlang) driver.
- Uses `myappdb.users` collection with JSON-like documents.
- Passwords are stored in plaintext for demo purposes.