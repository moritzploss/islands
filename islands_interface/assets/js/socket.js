// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import { Socket } from 'phoenix';
import uuid from 'uuid/v4';

const socket = new Socket('/socket', { params: { token: window.userToken } });

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect()

const createChannel = (socket, subtopic, screenName, topic = 'game') => {
  const channel = socket.channel(
    [topic, subtopic].join(':'),
    { screen_name: screenName },
  );
  channel.on('player_added', (reply) => console.log('Player added!', reply))
  channel.on('subscribers', (reply) => console.log('These players joined:', reply))
  channel.on('player_guessed_coordinate', (reply) => console.log('Player guessed coordinate:', reply))
  return channel;
};

// use these functions to play the game

const joinChannel = (channel) => channel
  .join()
  .receive('ok', (reply) => console.log(`Successfully joined '${channel.topic}':`, reply))
  .receive('error', (reply) => console.log(`Unable to join '${channel.topic}':`, reply));

const startNewGame = (channel) => channel
  .push('new_game')
  .receive('ok', (reply) => console.log('Started new game:', reply))
  .receive('error', (reply) => console.log('Could not start new game:', reply));

const addPlayer = (channel, playerName) => channel
  .push('add_player', playerName)
  .receive('error', (reply) => console.log(`Unable to add new player ${playerName}:`, reply));

const positionIsland = (channel, player, type, row, col) => channel
  .push('position_island', { player, type, row, col })
  .receive('ok', (reply) => console.log('Island positioned:', reply))
  .receive('error', (reply) => console.log('Unable to position island:', reply));

const setIslands = (channel, player) => channel
  .push('set_islands', { player })
  .receive('ok', (reply) => console.log('Here is the board:', reply))
  .receive('error', (reply) => console.log('Unable to set islands:', reply));

const guessCoordinate = (channel, player, row, col) => channel
  .push('guess_coordinate', { player, row, col })
  .receive('error', (reply) => console.log('Unable to guess a coordinate:', reply));


// here's a complete example game that will play automatically once you load
// the page. check your browser's console for the output.

const channel = createChannel(socket, uuid(), 'Mo');

joinChannel(channel);
startNewGame(channel);
addPlayer(channel, 'Another Player');

const islandCoordinates = [[1, 1], [7, 1], [4, 1], [1, 4], [4, 4]]
const islandTypes = ['atoll', 'dot', 'l_shape', 's_shape', 'square']

islandCoordinates.forEach(([row, col], index) => {
  positionIsland(channel, "player1", islandTypes[index], row, col);
  positionIsland(channel, "player2", islandTypes[index], row, col);
});

setIslands(channel, 'player1');
setIslands(channel, 'player2');

const winningGuesses = [
  // atoll
  { col: 1, row: 1 },
  { col: 1, row: 3 },
  { col: 2, row: 1 },
  { col: 2, row: 2 },
  { col: 2, row: 3 },
  
  // dot
  { col: 1, row: 7 },

  // l_shape
  { col: 1, row: 4 },
  { col: 1, row: 5 },
  { col: 1, row: 6 },
  { col: 2, row: 6 },

  // s_shape
  { col: 4, row: 2 },
  { col: 5, row: 1 },
  { col: 5, row: 2 },
  { col: 6, row: 1 },

  // square
  { col: 4, row: 4 },
  { col: 4, row: 5 },
  { col: 5, row: 4 },
  { col: 5, row: 5 },
]

winningGuesses.forEach(({ row, col }) => {
  guessCoordinate(channel, 'player1', row, col);
  guessCoordinate(channel, 'player2', row, col);
});

export default socket;
