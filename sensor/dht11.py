#!/usr/bin/python
# -*- coding: utf-8 -*-
import RPi.GPIO as GPIO
import time

DHT11_DATA_PIN = 23
DHT11_DATA_LEN = 5

def read_data():
    base=0
    data=[]
    # reset
    GPIO.setmode(GPIO.BCM)
    GPIO.setup( DHT11_DATA_PIN , GPIO.OUT)
    GPIO.output( DHT11_DATA_PIN , GPIO.LOW)
    time.sleep(0.03) # 必须大于18ms
    GPIO.setup( DHT11_DATA_PIN , GPIO.IN)
    while GPIO.input( DHT11_DATA_PIN ) == GPIO.HIGH:
        continue
    while GPIO.input( DHT11_DATA_PIN ) == GPIO.LOW:
        continue
    # 固定拉高80us，可用来做基准
    while GPIO.input( DHT11_DATA_PIN ) == GPIO.HIGH:
        base += 1
        continue
    base = base / 2
    # Get data
    while len(data)< DHT11_DATA_LEN*8:
        i = 0
        # 检测50us以上的低位
        while GPIO.input( DHT11_DATA_PIN ) == GPIO.LOW:
            continue
        # 此时电平为高，持续26-28us表示0，否则持续70us表示1
        while GPIO.input( DHT11_DATA_PIN ) == GPIO.HIGH:
            i += 1
            if i > 100: #最后一个数据也许不会拉低，手动判断
                break
        if i < base:
            data.append(0)
        else:
            data.append(1)
    print("DHT11 get data: ", data)
    return data


def cal(data):
    res=[]
    for i in range( DHT11_DATA_LEN ): # 5个数据分别为 湿度（整数，小数）；温度（整数，小数），校验
        res.append(0)
        for j in range(8):
            res[i] += data[i*8+j]<<(7-j)
    print("DHT11 res: ", res)
    if res[0]+res[2]!=res[4]:  # 数据校验
        print("DHT11: data check error!")
        return -1, -1
    else:
        print("humidity: %d, temperature: %d C" %(res[0], res[2]))
        return res[0],res[2]


for i in range(5):
    (h, t)=cal(read_data())
    if h>0:
        break
    time.sleep(0.1) 
GPIO.cleanup()
