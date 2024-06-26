#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

BEST_GAME=$($PSQL "select best_game from users where username = '$USERNAME'")
TOTAL_GAMES=$($PSQL "select total_games from users where username = '$USERNAME'")

if [[ -z $BEST_GAME ]]
then
  echo Welcome, $USERNAME! It looks like this is your first time here.
  INSERT_RESULT=$($PSQL "insert into users(username, best_game, total_games) values('$USERNAME', 0, 0)")
  TOTAL_GAMES=0
  BEST_GAME=0
else
  echo Welcome back, $USERNAME! You have played $TOTAL_GAMES games, and your best game took $BEST_GAME guesses.
fi

TARGET=$(( ( RANDOM % 1000 )  + 1 ))

echo Guess the secret number between 1 and 1000:
read GUESS

TOTAL_GUESSES=1

while [[ $GUESS != $TARGET ]]
do
  if ! [[ "$GUESS" =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
    read GUESS
    TOTAL_GUESSES=$((TOTAL_GUESSES + 1))
  else
    if [[ $GUESS > $TARGET ]]
    then
      echo "It's lower than that, guess again:"
      read GUESS
      TOTAL_GUESSES=$((TOTAL_GUESSES + 1))
    else
      echo "It's higher than that, guess again:"
      read GUESS
      TOTAL_GUESSES=$((TOTAL_GUESSES + 1))
    fi
  fi
done

echo You guessed it in $TOTAL_GUESSES tries. The secret number was $TARGET. Nice job!

TOTAL_GAMES=$((TOTAL_GAMES + 1))

if [[ $BEST_GAME = 0 ]] || [[ $BEST_GAME > $TOTAL_GUESSES ]]
then
  BEST_GAME=$TOTAL_GUESSES
fi

UPDATE_RESULT=$($PSQL "update users set best_game = $BEST_GAME, total_games = $TOTAL_GAMES where username = '$USERNAME'")

###
