#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\n"
  fi
  AVAILABLE_SERVICES=$($PSQL "select * from services")
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo -e "\nSorry, we don't have any services right now."
  else
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME 
    do
      echo "$SERVICE_ID) $NAME"
    done
  fi
  TAKE_APPOINTMENT
}

TAKE_APPOINTMENT() {
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_MENU "That is not a valid service number."
  else
    AVAILABLE_SERVICE=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    if [[ -z $AVAILABLE_SERVICE ]]
    then
      SERVICE_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'") 
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      echo -e "\nWhat time would you like your $AVAILABLE_SERVICE, $CUSTOMER_NAME?"
      read SERVICE_TIME
      INSERT_APPOINTMENT=$($PSQL "insert into appointments (customer_id,service_id,time) values ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      echo -e "\nI have put you down for a $AVAILABLE_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

echo -e "\n~~~~~ MY SALON ~~~~~"

echo -e "\nWelcome to My Salon, how can I help you?"

AVAILABLE_SERVICES=$($PSQL "select * from services")
if [[ -z $AVAILABLE_SERVICES ]]
then
  echo -e "\nSorry, we don't have any services right now."
else
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME 
  do
    echo "$SERVICE_ID) $NAME"
  done
fi

TAKE_APPOINTMENT