![Tests](https://github.com/moritzploss/islands/workflows/Tests/badge.svg)

# Islands

This repo contains an implementation of *Islands*, a classic boardgame similar to (but more pacifistic than) *Battleship*.

The project was built based on the book
*Functional Web Development with Elixir, OTP, and Phoenix* by Lance Halvorsen. 

## Backend

### Getting Started

Install the `Elixir` dependencies:

    mix deps.get

Install the `Phoenix` archive:

    mix archive.install hex phx_new 1.4.15

Compile the project:

    mix compile

Run the tests:

    mix test --cover

Format the code:

    mix format

Run the linter:

    mix credo --strict --all

### Working with `iex`

Start an `iex` session inside the project:

    iex -S mix

Recompile the project from within `iex`:

    recompile()

## Useful Links

- Credo Style Guide: https://github.com/rrrene/elixir-style-guide