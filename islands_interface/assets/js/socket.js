// use the functions in this file to play the game
console.log('check this file to see the corresponding code: islands_interface/assets/js/socket.js')

import { Socket } from 'phoenix';
import uuid from 'uuid/v4';

// create a socket

const socket = new Socket('/socket', { params: { token: window.userToken } });
socket.connect()

// create a channel for the game

const createChannel = (socket, subtopic, screenName, topic = 'game') => {
  const channel = socket.channel(
    [topic, subtopic].join(':'),
    { screen_name: screenName },
  );
  channel.on('player_added', (reply) => console.log('Player added!', reply))
  channel.on('subscribers', (reply) => console.log('These players joined:', reply))
  channel.on('player_guessed_coordinate', (reply) => {
    console.log('Player guessed coordinate:', reply);
    if (reply.result.win === 'win') console.log('Game over!');
  })
  return channel;
};

const channel = createChannel(socket, uuid(), 'Player 1 Name');

// use these functions to play the game

const joinChannel = (channel) => channel
  .join()
  .receive('ok', (reply) => console.log(`Successfully joined channel '${channel.topic}':`, reply))
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
  .receive('ok', (reply) => console.log(`${player} positioned island:`, reply))
  .receive('error', (reply) => console.log('Unable to position island:', reply));

const setIslands = (channel, player) => channel
  .push('set_islands', { player })
  .receive('ok', (reply) => console.log(`Here is ${player}'s board:`, reply))
  .receive('error', (reply) => console.log('Unable to set islands:', reply));

const guessCoordinate = (channel, player, row, col) => channel
  .push('guess_coordinate', { player, row, col })
  .receive('error', (reply) => console.log('Unable to guess a coordinate:', reply));


// here's a complete example game that will play automatically once you load
// the page. check your browser's console for the output.

joinChannel(channel);
startNewGame(channel);
addPlayer(channel, 'Player 2 Name');

const islandCoordinates = [[1, 1], [7, 1], [4, 1], [1, 4], [4, 4]];
const islandTypes = ['atoll', 'dot', 'l_shape', 's_shape', 'square'];

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
