#!/bin/sh

MQTT_HOST=`uci get presence.@presence[0].mqtthost`
MQTT_ID=`uci get presence.@presence[0].mqttid`
MQTT_USER=`uci get presence.@presence[0].mqttuser`
MQTT_PASS=`uci get presence.@presence[0].mqttpass`
MQTT_TOPIC=`uci get presence.@presence[0].mqtttopic`

for interface in `iw dev | grep Interface | cut -f 2 -s -d" "`
do
  # for each interface, get mac addresses of connected stations/clients
  maclist=`iw dev $interface station dump | grep Station | cut -f 2 -s -d" "`
  
  # for each mac address in that list...
  for mac in $maclist
  do
    mosquitto_pub -h ${MQTT_HOST} -i $MQTT_ID -u ${MQTT_USER} -P ${MQTT_PASS} -t "${MQTT_TOPIC}${mac//:/-}" -m $(date +%Y-%m-%dT%H:%M:%S.000%z)
    mosquitto_pub -h ${MQTT_HOST} -i $MQTT_ID -u ${MQTT_USER} -P ${MQTT_PASS} -t "${MQTT_TOPIC}${mac//:/-}/seconds" -m $(date +%s)
    mosquitto_pub -h ${MQTT_HOST} -i $MQTT_ID -u ${MQTT_USER} -P ${MQTT_PASS} -t "${MQTT_TOPIC}${mac//:/-}/detector" -m $MQTT_ID@$interface
  done
done
