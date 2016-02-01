#!/usr/bin/python
#-*- coding:utf-8 -*-
import time
import smbus

# BMP180 i2c address.
BMP180_I2C_ADDR           = 0x77
# Operating Modes
BMP180_ULTRALOWPOWER     = 0
BMP180_STANDARD          = 1
BMP180_HIGHRES           = 2
BMP180_ULTRAHIGHRES      = 3
# BMP085 Registers
BMP180_CAL_REGS_START    = 0xAA
BMP180_CAL_REGS_COUNT    = 11
BMP180_CONTROL_ADDR      = 0xF4
BMP180_RAWDATA_ADDR      = 0xF6
# Commands
BMP180_READ_TEMPCMD      = 0x2E
BMP180_READ_PRESSURECMD  = 0x34
#便于对应spec，留出ac[0] & b[0] 不用
bmp180_ac   = [-1, 8153,-1069,-14370,33272,26213,13876]      # AC1-AC6
bmp180_b    = [-1, 6515,37, 0,0,0,0,0]    # B1-B7
bmp180_x    = [-1, 0,0,0]            # X1-X3
bmp180_mb   = -32768
bmp180_mc   = -11786
bmp180_md   = 2081


bus = smbus.SMBus(1)


def bmp180_read(cmd):
    return bus.read_byte_data(BMP180_I2C_ADDR, cmd)

def bmp180_write(cmd, val):
    return bus.write_byte_data(BMP180_I2C_ADDR, cmd, val)

def bmp180_load_calibration():
    cal=[]
    for i in range(0,BMP180_CAL_REGS_COUNT):
        MSB = bmp180_read(BMP180_CAL_REGS_START+i*2)
        LSB = bmp180_read(BMP180_CAL_REGS_START+i*2+1)
        value = (MSB << 8) + LSB
        if i in {0, 1, 2, 6, 7, 8, 9, 10}:# signed short
            if value > 32767:value -= 65536
        cal.append(value)
    #print(cal)
    # fill the regs
    for i in range(1,6):
        bmp180_ac[i]=cal[i-1]
    bmp180_b[1] = cal[6]
    bmp180_b[2] = cal[7]
    bmp180_mb = cal[8]
    bmp180_mc = cal[9]
    bmp180_md = cal[10]
    #print(bmp180_ac, bmp180_b)


def bmp180_read_temperature():
    # for temperature
    bmp180_write(BMP180_CONTROL_ADDR, BMP180_READ_TEMPCMD)
    time.sleep(0.005)  # Wait 4.5(in fact is 5)ms
    MSB = bmp180_read(BMP180_RAWDATA_ADDR)
    LSB = bmp180_read(BMP180_RAWDATA_ADDR+1)
    ut = (MSB << 8) + LSB
    # Calculate it
    bmp180_x[1] = ((ut-bmp180_ac[6])*bmp180_ac[5])>>15
    bmp180_x[2] = (bmp180_mc <<11) / (bmp180_x[1]+bmp180_md)
    bmp180_b[5] = bmp180_x[1] + bmp180_x[2]
    t = (bmp180_b[5]+8) >>4
    #print("IN temp: ut=%d, x1=%d, x2=%d, b5=%d, t=%d " %( ut, bmp180_x[1], bmp180_x[2], bmp180_b[5], t))
    return float(t/10.0)


def bmp180_read_pressure(oss):
    if bmp180_b[5]==0:  #没有调用温度计算过
        bmp180_read_temp()
    # for pressure
    bmp180_write(BMP180_CONTROL_ADDR, BMP180_READ_PRESSURECMD + (oss << 6))
    if oss == BMP180_ULTRALOWPOWER:
        time.sleep(0.005)
    elif oss == BMP180_STANDARD:
        time.sleep(0.008)
    elif oss == BMP180_HIGHRES:
        time.sleep(0.014)
    elif oss == BMP180_ULTRAHIGHRES:
        time.sleep(0.026)
    else:
        print("BMP180: error input for pressure oss")
    MSB = bmp180_read(BMP180_RAWDATA_ADDR)
    LSB = bmp180_read(BMP180_RAWDATA_ADDR+1)
    XLSB = bmp180_read(BMP180_RAWDATA_ADDR+2)
    up = ((MSB << 16) + (LSB << 8) + XLSB) >> (8 - oss)

    # Calculate it
    bmp180_b[6] = bmp180_b[5]-4000
    temp = bmp180_b[6]*bmp180_b[6]>>12
    bmp180_x[1] = (bmp180_b[2] * temp ) >> 11
    bmp180_x[2] = (bmp180_ac[2] * bmp180_b[6]) >> 11
    bmp180_x[3] = bmp180_x[1]+bmp180_x[2]
    bmp180_b[3] = (((bmp180_ac[1]*4 + bmp180_x[3])<<oss) +2) /4
    #print("round 1:  ", bmp180_b, bmp180_x)

    bmp180_x[1] = (bmp180_ac[3] * bmp180_b[6]) >> 13
    bmp180_x[2] = (bmp180_b[1] * temp ) >> 16
    bmp180_x[3] = (bmp180_x[1]+bmp180_x[2] +2 )>>2
    bmp180_b[4] = (bmp180_ac[4]* (bmp180_x[3]+32768)) >> 15
    bmp180_b[7] = (up - bmp180_b[3]) * (50000>>oss)
    #print("round 2:  ", bmp180_b, bmp180_x, "ac4=", bmp180_ac[4])

    if bmp180_b[7] < 0x80000000:
        p = bmp180_b[7]*2/bmp180_b[4]
    else:
        p = bmp180_b[7]/bmp180_b[4]*2
    bmp180_x[1] = (p>>8) * (p>>8)
    bmp180_x[1] = (bmp180_x[1]*3038) >>16
    bmp180_x[2] = (-7357*p) >>16
    p = p + ((bmp180_x[1] + bmp180_x[2] + 3791) >> 4)
    #print("round 3:  ", bmp180_b, bmp180_x)

    return p


def bmp180_read_altitude(sealevel_pa=101325.0):
    pressure = float(bmp180_read_pressure(BMP180_STANDARD))
    altitude = 44330.0 * (1.0 - pow(pressure / sealevel_pa, (1.0/5.255)))
    return altitude

def read_sealevel_pressure(altitude_m=0.0):
    pressure = float(bmp180_read_pressure(BMP180_STANDARD))
    p0 = pressure / pow(1.0 - altitude_m/44330.0, 5.255)
    return p0


bmp180_load_calibration()
print("temp=%.1f, pressure=%dL, altitiude=%.2f" 
    %(bmp180_read_temperature(), bmp180_read_pressure(BMP180_STANDARD),bmp180_read_altitude()) )
