![Islands Engine](https://github.com/moritzploss/islands/workflows/Islands%20Engine/badge.svg) ![Islands Interface](https://github.com/moritzploss/islands/workflows/Islands%20Interface/badge.svg)
# Islands

This repo contains an implementation of *Islands*, a classic boardgame similar to (but more pacifistic than) *Battleship*. The project was built based on the book
*Functional Web Development with Elixir, OTP, and Phoenix* by Lance Halvorsen.

The game logic is contained in the `islands_engine` directory; the `Phoenix` app 
can be found inside `islands_interface`. Follow the steps below to get the
project up and running.

## Play the Game

Follow the `Getting Started` guide below and start the `Phoenix` server. Then
go to `localhost:4000` and open your browser's console. You can see the
output of a complete game that was automatically played on page load.

Since the focus of this project was on learning `Elixir` and `Phoenix`, I didn't
bother to implement a visual representation of the game in `JavaScript`. However,
all functions and event listeners that are required to play the game have
been implemented; you can import them from here:
[`islands_interface/assets/js/socket.js`](islands_interface/assets/js/socket.js)

## Getting Started

### Basic Setup

The following assumes that you have a working installation of `Elixir`
(including `mix`) and `Node.js` (including `npm`).

### Islands Engine (Game Logic)

Inside the `islands_engine` directory, install the `Elixir` dependencies:

    mix deps.get

Compile the project:

    mix compile

### Islands Interface (Phoenix App)

Globally install the `Phoenix` archive:

    mix archive.install hex phx_new 1.4.15

Inside the `islands_interface` directory, install the dependencies:

    mix deps.get
    cd assets && npm install

Then start the `Phoenix` app on `localhost:4000`:

    mix phx.server

Run the app inside `IEx`:

    iex -S mix phx.server

### Useful `mix` Commands

After completing the steps outlined above, the following commands can be used 
both inside the `islands_engine` and the `islands_interface` directory.

Run the tests:

    mix test --cover

Format the code:

    mix format

Run the linter:

    mix credo --strict --all

Visualize the dependency tree:

    mix deps.tree

## Useful Links

- Credo Style Guide: https://github.com/rrrene/elixir-style-guide
