#!/bin/bash
####
#### Troy Watson 2016 - This script will query ldap for FirstName LastName and gengerate a nagios contact based off the domain information available
#### https://github.com/trwatson

LDAP_USER="user@domain"
LDAP_PASS="password"
LDAP_HOST="dc01.mycompany.com"
LDAP_BASE="OU=myorg,DC=mycompany,DC=com"
while read PERSON;
do
FULL_NAME=$PERSON
NICKNAME=$(echo "$FULL_NAME" | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
PAGER_SUB="name=${FULL_NAME} PAGER"
USER_SUB="name=${FULL_NAME}"
PAGER_LDAP_CMD=$(ldapsearch -LLL -H ldap://${LDAP_HOST} -x -D "$LDAP_USER" -w "$LDAP_PASS" -b $LDAP_BASE -s sub "${PAGER_SUB}" mail | grep ^mail)
USER_LDAP_CMD=$(ldapsearch -LLL  -H ldap://${X_LDAP_HOST} -x -D "$LDAP_USER" -w "$LDAP_PASS" -b $LDAP_BASE -s sub "${USER_SUB}" mail| grep ^mail)
PAGER_EMAIL=$(echo $PAGER_LDAP_CMD | awk '{print $2}')
USER_NAME=$(echo $USER_LDAP_CMD | awk '{print $2}' | awk -F@ '{print $1}')
if [ -z "$PAGER_EMAIL" ]
  then PAGER_EMAIL="NO PAGER FOUND"
fi
if [ -z "$USER_NAME" ]
then
  echo "\nUser: $FULL_NAME NOT FOUND\n";
  continue
fi
contact="
define contact {
        contact_name                    "$USER_NAME"_phone
        use                             generic-contact
        alias                           "$FULL_NAME" Phone
        service_notification_period     24x7
        host_notification_period        24x7
        service_notification_options    u,c,r
        host_notification_options       d,u,r
        email                           "$PAGER_EMAIL"
}
define contact {
        contact_name                    "$USER_NAME"_email
        use                             generic-contact
        alias                           "$FULL_NAME" Email
        service_notification_period     24x7
        host_notification_period        24x7
        service_notification_options    u,c,r
        host_notification_options       d,u,r
        email                           "$USER_NAME"@xactware.com
}
"
echo "$contact"
done < $1

