#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU (){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo -e "Welcome to My Salon, how can I help you?\n"
  SERVICES=$($PSQL "SELECT service_id, name from services order by service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID

  #Get service
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id from services where service_id = $SERVICE_ID")

  # if input is not one of the selections
  if [[ -z $SERVICE_ID_SELECTED ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    #Ask for phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    #Check if record exists
    CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone = '$CUSTOMER_PHONE'")
    #if customer_name doesn't exist
    if [[ -z $CUSTOMER_ID ]]
    then
    #get new customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
    #Insert name
      INSERT_NAME_RESULT=$($PSQL "INSERT INTO customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      #Pull customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone = '$CUSTOMER_PHONE'")
    fi
    CUSTOMER_NAME=$($PSQL "SELECT name from customers where customer_id = '$CUSTOMER_ID'")
    #Ask for the time of the service
    echo -e "\nWhat time would you like your cut,$CUSTOMER_NAME?"
    read SERVICE_TIME
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    SERVICE_NAME=$($PSQL "SELECT name from services where service_id = $SERVICE_ID_SELECTED")
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME.\n"
  fi
}
MAIN_MENU