#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ My salon ~~~~"

SERVICES() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWelcome to my salon. How may I help you?"
  
  echo -e "\n$($PSQL "SELECT service_id, name FROM services ORDER BY service_id" | sed -E 's/ \|/)/')"
  
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    SERVICES "\nI could not find that service. What would you like today?"
  else
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE

    if [[ -z $($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'") ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    CUSTOMER_NAME_RESULT=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME_RESULT?"
    read SERVICE_TIME

    CUSTOMER_ID_TO_INSERT=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID_TO_INSERT, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME_RESULT."
  fi
}

SERVICES