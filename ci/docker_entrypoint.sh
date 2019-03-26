#!/bin/bash

CLASS_NAME="com.java.example.MyFirstExample"
echo "Class Name: ${CLASS_NAME}"
echo "JAR_FILE: ${JAR_FILE}"

java -cp /opt/${JAR_FILE}.jar ${CLASS_NAME}
