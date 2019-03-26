#!/usr/bin/env bash

CLASS_NAME1="com.java.example.MyFirstExample"
CLASS_NAME2="com.java.example.MySecondExample"
CLASS_NAME3="com.java.example.App"
echo "Class Name1: ${CLASS_NAME1}"
echo "Class Name2: ${CLASS_NAME2}"
echo "Class Name3: ${CLASS_NAME3}"


echo "JAR_FILE: ${JAR_FILE}"

cd /opt
ls

java -cp /opt/${JAR_FILE} ${CLASS_NAME1}
java -cp /opt/${JAR_FILE} ${CLASS_NAME2}
java -cp /opt/${JAR_FILE} ${CLASS_NAME3}
