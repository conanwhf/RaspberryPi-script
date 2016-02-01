#!/usr/bin/python
# -*- coding: utf-8 -*-
import serial
import time
import smbus
import RPi.GPIO as GPIO

i2c_addr=0x48
i2c_cmd=0xAB

gpio_pin=17


def showdata(arg):
    #print('data length=', len(arg))
    result = ''
    for i in arg:
        st = '%02X'%ord(i)
        result += st+' '
    print(result)


def serial_test():
    print("start serial test")
    ser = serial.Serial('/dev/ttyAMA0', 9600, timeout=1)
    loop = 5
    while loop>0:
        # 获得接收缓冲区字符
        #count = ser.inWaiting()
        # 读取内容
        data = ser.read(5)
        showdata(data)
        # 清空接收缓冲区
        #ser.flushInput()
        loop = loop-1
    ser.close()
    print("serial test done!")


def i2c_test(addr):
    print("start i2c test for addr=%x" %addr )
    data=0x0f
    cmd=0xAB
    loop = 5
    # 打开 /dviev/i2c-1  
    bus = smbus.SMBus(1)          
    while loop>0: 
        bus.write_byte(addr, data)
        data = bus.read_byte(addr) 
    	#@bus.write_byte_data(addr, cmd, data)
    	#data = bus.read_byte_data(addr, cmd)
    	print(data)
        loop = loop-1
    print("i2c test done!")


def gpio_test(pin):
    print("start gpio test for pin=bcm%d" %pin)
    GPIO.setmode(GPIO.BCM)
    # 读取GPIO
    GPIO.setup(pin, GPIO.IN)
    value = GPIO.input(pin)
    print("before set, pin=%d" %value)
    # 改变GPIO输出
    GPIO.setup(pin, GPIO.OUT)
    GPIO.output(pin, ~value)
    print("now pin=%d" %GPIO.input(pin))
    GPIO.cleanup()
    print("GPIO test done")


serial_test()
i2c_test(i2c_addr)
gpio_test(gpio_pin)
