![Islands Engine](https://github.com/moritzploss/islands/workflows/Islands%20Engine/badge.svg) ![Islands Interface](https://github.com/moritzploss/islands/workflows/Islands%20Interface/badge.svg)
# Islands

This repo contains an implementation of *Islands*, a classic boardgame similar to (but more pacifistic than) *Battleship*. The project was built based on the book
*Functional Web Development with Elixir, OTP, and Phoenix* by Lance Halvorsen.

The game logic is contained in the `islands_engine` directory; the `Phoenix` app
can be found inside `islands_interface`. Follow the steps below to get the
project up and running. 

## Getting Started

### Basic Setup

The following assumes that you have a working installation of `Elixir`
(including `mix`) and `Node.js` (including `npm`).

Install the `Phoenix` archive:

    mix archive.install hex phx_new 1.4.15

### Islands Engine (Game Logic)

Inside the `islands_engine` directory, install the `Elixir` dependencies:

    mix deps.get

Compile the project:

    mix compile

Run the tests:

    mix test --cover

Format the code:

    mix format

Run the linter:

    mix credo --strict --all

### Islands Interface (Phoenix App)

Inside the `islands_interface` directory, install the dependencies:

    mix deps.get
    cd assets && npm install

Then start the `Phoenix` app on `localhost:4000`:

    mix phx.server

Run the app inside `IEx`:

    iex -S mix phx.server

Visualize the dependency tree:

    mix deps.tree

## Working with `IEx`

Start an `IEx` session inside any of the project directories with the
respective `Application` loaded:

    iex -S mix

Recompile the project from within `IEx`:

    recompile()

## Useful Links

- Credo Style Guide: https://github.com/rrrene/elixir-style-guide
