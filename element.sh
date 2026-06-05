#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

INPUT_ARG=$1
if [[ $INPUT_ARG ]]
then
  #check input
  if [[ $INPUT_ARG =~ ^[0-9]+$ ]]
  then
    # If it is a number, query by atomic_number only
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$INPUT_ARG")
  else
    # If it is not a number, query by symbol or name
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$INPUT_ARG' OR name='$INPUT_ARG'")
  fi
  
  #check if ATOM not exsist
  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo "I could not find that element in the database."
  else
    while IFS=$'|' read -r SYMBOL NAME MASS MELT BOIL TYPE; 
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
    done < <($PSQL "SELECT symbol,name,atomic_mass,melting_point_celsius,boiling_point_celsius,type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
  fi
else
  echo "Please provide an element as an argument."
fi
