#!/usr/bin/python
# -*- coding:utf-8 -*-
import smbus
import time

address = 0x48
A=[0x40, 0x41, 0x42, 0x43]
power=3.3

bus = smbus.SMBus(1)

def getData(i):
        bus.write_byte(address,A[i])
        value = bus.read_byte(address)
        value = bus.read_byte(address)
        print("A%d OUT: %3d, %1.3f, in %1.2fV power-%1.3f " %(i, value,value/255.0, power, value*power/255.0))
        time.sleep(.2)


while True:
        # 读取输出
        getData(0)
        getData(1)
        getData(2)
        getData(3)
        print
        time.sleep(1)
