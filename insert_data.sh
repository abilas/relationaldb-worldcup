#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Empty all rows in the tables
echo $($PSQL "TRUNCATE teams, games")

# read csv, set delimiter to ',' and map to column headers
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # find team_id or insert new if not exist into 'teams'
  if [[ $YEAR != "year" ]]
  then
  # get team_id for winner and opponent
    W_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    O_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # if winner not found
    if [[ -z $W_TEAM_ID ]]
    then
      # add new team
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      # get new winner id
      W_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi
    # if opponent not found
    if [[ -z $O_TEAM_ID ]]
    then
      # add new team
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      # get new opponent id
      O_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # add game record to 'games'
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, winner_id, opponent_id, winner_goals, opponent_goals, round) VALUES($YEAR, $W_TEAM_ID, $O_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS, '$ROUND')")
  fi

done
