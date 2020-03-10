// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import { Socket } from "phoenix";

const socket = new Socket("/socket", { params: { token: window.userToken } });

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

  return channel;
};

const joinChannel = (channel) => channel
  .join()
  .receive('ok', (reply) => console.log(`Successfully joined '${channel.topic}'`, reply))
  .receive('error', (reply) => console.log(`Unable to join '${channel.topic}'`, reply));

const startNewGame = (channel) => channel
  .push('new_game')
  .receive('ok', (reply) => console.log('started new game', reply))
  .receive('error', (reply) => console.log('could not start new game', reply));

const addPlayer = (channel, playerName) => channel
  .push('add_player', playerName)
  .receive('error', (reply) => console.log(`Unable to add new player ${playerName}`, reply));

const channel = createChannel(socket, 'mo', 'Mo');
joinChannel(channel);

export default socket;
