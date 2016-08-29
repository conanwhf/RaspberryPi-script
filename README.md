# RaspberryPi-script
树莓派相关配置&脚本，适用于rpi2B及3B硬件。

## rpi-backup
备份系统成一个可烧录的image，详细说明参见：http://conanwhf.github.io/2016/08/25/rpi-cloneimg/


## rpi-clone
一个超好用的备份工具，感谢开发者！
来源：https://github.com/billw2/rpi-clone

## build-编译脚本
- build-toolchain.sh，在debian的系统中编译交叉编译工具的脚本
- crossng_config，交叉编译工具编译配置文件，适用于rpi2B和rpi3B
- kernel_config，内核配置，来源于官方
- kernel.sh，内核编译脚本，跑在树莓派上
- linux-mk.sh，内核编译脚本，跑在PC上，交叉编译

## setup-配置脚本
参考初始化配置运行顺序：network.sh-> init.sh-> dev-mod.sh
- dev-mod.sh，一些开发用模块的装载和配置脚本，包括语音输出，开发环境，Airmon工具，Swift环境等
- init.sh，初始配置，包括系统更新，vi & SSH配置，中文支持，USB供电修改，Samba支持等
- interfaces,tightvncserver,vimrc，脚本运行所需对应的配置文件

## sensor
一些外部传感器获取状态的Demo，Python写成，rpi2B测试通过
- libSetup.sh，开发包环境配置脚本，包括I2C,GPIO,UART,Bluetooth等
- air_qu.py，空气质量传感器，Uart协议
- bmp180.py，BMP180气压传感器，I2C
- dht11.py，温度湿度传感器，GPIO
- pcf8591.py，数模转换+照度传感，I2C
- sample.py，各种协议操作的demo
