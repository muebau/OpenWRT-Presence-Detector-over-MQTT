#!/bin/sh

MQTT_HOST=`uci get presence.@presence[0].mqtthost`
MQTT_ID=`uci get presence.@presence[0].mqttid`
MQTT_USER=`uci get presence.@presence[0].mqttuser`
MQTT_PASS=`uci get presence.@presence[0].mqttpass`
MQTT_TOPIC=`uci get presence.@presence[0].mqtttopic`

iw event | \
while read LINE; do
    if echo $LINE | grep -q -E "(new|del) station"; then
        EVENT=`echo $LINE | awk '/(new|del) station/ {print $2}'`
        MAC=`echo $LINE | awk '/(new|del) station/ {print $4}'`
        INTERFACE=`echo $LINE | awk '/(new|del) station/ {print $1}' | awk -F: '{print $1}'`

        #echo "Mac: $MAC did $EVENT"
        mosquitto_pub -h ${MQTT_HOST} -i $MQTT_ID -u ${MQTT_USER} -P ${MQTT_PASS} -t "${MQTT_TOPIC}${MAC//:/-}/event" -m $EVENT@$INTERFACE
    fi
done
