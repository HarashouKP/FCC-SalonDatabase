#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?" 

MAIN_MENU() {
  
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

#list of services
AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
do
    echo "$SERVICE_ID) $SERVICE_NAME"    
done


#fist prompt
read SERVICE_ID_SELECTED
SELECTED_SERVICE_RESULT=$($PSQL "SELECT service_id, name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
SELECTED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

#if no service
if [[ -z $SELECTED_SERVICE_RESULT ]] ;then
MAIN_MENU "I could not find that service. What would you like today?"

else
#fill customer info
echo -e "\nWhat's your phone number?\nFormat 000-000-0000"
read CUSTOMER_PHONE

#check old customer 
CHECK_CUSTOMER_RESULT=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")

  MAKE_APPOINTMENT(){
  CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME' AND phone='$CUSTOMER_PHONE' ")
  CUST_NAME=$($PSQL "SELECT name FROM customers WHERE name='$CUSTOMER_NAME'  AND phone='$CUSTOMER_PHONE' ")
  SER_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  ##FORMAT_TIME_APP=$( | sed 's/\s//g' -E)
  FORMAT_CUST_NAME_APP=$(echo $CUSTOMER_NAME | sed 's/\s//g' -E)
  FORMAT_SERVICE_NAME_APP=$(echo $SELECTED_SERVICE_NAME | sed 's/\s//g' -E)
  echo -e "\nWhat time would you like your $FORMAT_SERVICE_NAME_APP, $FORMAT_CUST_NAME_APP?"
  read SERVICE_TIME
  APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time,customer_id,service_id) VALUES('$SERVICE_TIME',$CUST_ID,$SER_ID)")
  echo -e "\nI have put you down for a $FORMAT_SERVICE_NAME_APP at $SERVICE_TIME, $FORMAT_CUST_NAME_APP."
  }

    #if don't have tele in DB
    if [[ -z $CHECK_CUSTOMER_RESULT ]] ;then
    #new customer insert
    echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
    NEW_CUSTOMER_LIST_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    MAKE_APPOINTMENT
    #have in DB
    else 
    MAKE_APPOINTMENT
    fi

fi


}

MAIN_MENU


