#!/usr/bin/env bash

CLASS_NAME="com.java.example.MyFirstExample"
echo "Class Name: ${CLASS_NAME}"
echo "JAR_FILE: ${JAR_FILE}"

cd /opt
ls

java -cp /opt/${JAR_FILE} ${CLASS_NAME}
