#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if no argument is given
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# Determine if argument is atomic number (number) or symbol/name (text)
if [[ $1 =~ ^[0-9]+$ ]]; then
  CONDITION="atomic_number = $1"
else
  CONDITION="symbol = INITCAP('$1') OR name = INITCAP('$1')"
fi

# Query the element
ELEMENT=$($PSQL "
  SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p USING(atomic_number)
  JOIN types t USING(type_id)
  WHERE $CONDITION
")

# Check if element was found
if [[ -z $ELEMENT ]]; then
  echo "I could not find that element in the database."
  exit
fi

# Read values into variables
IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL <<< "$ELEMENT"

# Output the result
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
