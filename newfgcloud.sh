#!/usr/bin/env bash
RED_COLOR="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
FUCHSIA="\033[0;35m"
echo "export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
sleep 2
echo -e "
 ${GREEN} 1.对接ssr节点
 ${GREEN} 2.对接ehco隧道
 ${GREEN} 3.删除防火墙
 ${GREEN} 4.杀掉端口
 ${GREEN} 5.管理ssr后端
 ${GREEN} 6.安装内核
 ${GREEN} 7.查看ehco端口
 "
read -p "输入选项:" dNum
if [ "$dNum" = "1" ];then
if [[ "$EUID" -ne 0 ]]; then
    echo "false"
  else
    echo "true"
  fi
if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
    
     if [[ $release = "ubuntu" || $release = "debian" ]]; then
    PM='apt'
  elif [[ $release = "centos" ]]; then
    PM='yum'
  else
    exit 1
  fi
  # PM='apt'
  if [ $PM = 'apt' ] ; then
    apt-get update -y
    apt-get install vim curl git wget zip unzip python3 python3-pip git -y
elif [ $PM = 'yum' ]; then
    yum update -y
    yum install vim curl git wget zip unzip python3 python3-pip git -y
fi
pip3 install --upgrade pip
echo -e
cd
echo -e
git clone https://github.com/zhj18/fgcloud.git
echo -e
cd fgcloud
pip3 install -r requirements.txt
sleep 5
cp apiconfig.py userapiconfig.py && cp config.json user-config.json
echo -e
echo -e "
 ${GREEN} 1.web
 ${GREEN} 2.db
 "
 read -p "输入你要的对接方式:" aNum
if [ "$aNum" = "1" ];then
read -p "请输入网站域名(末尾不要有/,列如www.baidu.com):" webapi1
sleep 1
sed -i '16s/123456/'${webapi1}'/' userapiconfig.py
read -p "请输入网站mukey:" key
 echo "网站mukey为：${key}"
 sleep 1
 sed -i '17s/123/'${key}'/' userapiconfig.py
 read -p "请输入节点序号:" node
 echo "节点序号为：${node}"
 sleep 1
 sed -i '2s/0/'${node}'/' userapiconfig.py
 elif [ "$aNum" = "2" ] ;then
 sed -i '14s/modwebapi/glzjinmod/' userapiconfig.py
 read -p "请输入数据库地址:" ip
 echo "数据库地址为：${ip}"
 sleep 1
 sed -i '23s/127.0.0.1/'${ip}'/' userapiconfig.py
 read -p "请输入数据库用户名:" user
 echo "数据库用户名为：${user}"
 sleep 1
 sed -i '25s/ss/'${user}'/' userapiconfig.py
 read -p "请输入数据库名:" db
 echo "数据库名为：${db}"
 sleep 1
 sed -i '27s/shadowsocks/'${db}'/' userapiconfig.py
 read -p "请输入数据库密码:" passwd
 echo "数据库密码为：${passwd}"
 sleep 1
 sed -i '26s/ss/'${passwd}'/' userapiconfig.py
 read -p "请输入节点序号:" node
 echo "节点序号为：${node}"
 sleep 1
 sed -i '2s/0/'${node}'/' userapiconfig.py
  else
            echo "你他妈是猪吗，就两个数字给你选，你都选错，滚！！！"
            fi
 echo "是否为nat对接"
 echo -e "
 ${GREEN} 1.是
 ${GREEN} 2.否
 "
 read -p "请输入选项:" cNum
if [ "$cNum" = "1" ];then
read -p "请输入nat端口:" natport
sed -i '4s/22783/'${natport}'/' user-config.json
else
echo "不做改变"
            fi
cd
cd fgcloud && chmod +x run.sh && ./run.sh
echo "已经对接完成！！!。"
sleep 2
cd
wget https://github.com/Ehco1996/ehco/releases/download/v1.0.4/ehco_1.0.4_linux_amd64 && mv ehco_1.0.4_linux_amd64 ehco && chmod +x ehco
echo -e "是否为节点上ws加密:
  ${GREEN}1.是(以后要直连或流量转发的节点)
  ${GREEN}2.是(直连nat节点套ws,要隧道中转请选3)
  ${GREEN}3.否(以后要套隧道中转的节点)
  "
  read -p "输入你的选项:" bNum
  if [ "$bNum" = "1" ];then
  read -p "请输入ssr公网ip:" ssrip
  read -p "请输入ssr公网端口:" ssrport1
  read -p "请输入节点机监听端口1:" ldport1
  nohup ./ehco -l 0.0.0.0:${ldport1} --lt mwss -r ${ssrip}:${ssrport1} --ur ${ssrip}:${ssrport1} >> /dev/null 2>&1 &
  sleep 1
  read -p "请输入节点机监听端口2:" ldport2
  read -p "请输入web_port端口(随便,但不可重复):" port3
  nohup ./ehco -l 0.0.0.0:${ldport2} -r wss://${ssrip}:${ldport1} --tt mwss --web_port ${port3} --ur ${ssrip}:${ldport1} >> /dev/null 2>&1 &
  echo "请把下面语句复制到节点地址:"
  echo "${ssrip};port=${ssrport1}#${ldport2}"
  elif [ "$bNum" = "2" ] ;then
  read -p "请输入nat节点公网ip:" natip
  read -p "请输入nat节点公网端口1:" natport1
  read -p "请输入nat公网监听端口2:" natport2
  nohup ./ehco -l 0.0.0.0:${natport2} --lt mwss -r ${natip}:${natport1} --ur ${natip}:${natport1} >> /dev/null 2>&1 &
  read -p "请输入nat公网监听端口3:" natport3
  read -p "请输入web_port端口(随便,但不可重复):" port3
  nohup ./ehco -l 0.0.0.0:${natport3} -r wss://${natip}:${natport2} --tt mwss --web_port ${port3} --ur ${natip}:${natport2} >> /dev/null 2>&1 &
  echo "请把下面语句复制到节点地址:"
  echo "${natport1};port=22783#${natport3}"
  else
  echo "不做改变..."
  fi
  echo "已结束"
  elif [ "$dNum" = "2" ] ;then
  echo -e "
 ${GREEN} 1.落地机
 ${GREEN} 2.中转机
 "
 read -p "输入你的选项:" eNum
 if [ "$eNum" = "1" ];then
  read -p "请输入ssr节点公网ip:" ssrip
  read -p "请输入ssr节点公网端口:" port1
  read -p "请输入落地机公网监听端口:" port2
  nohup ./ehco -l 0.0.0.0:${port2} --lt mwss -r ${ssrip}:${port1} --ur ${ssrip}:${port1} >> /dev/null 2>&1 &
  echo "落地机已设置完成，请去中转机执行此脚本，设置中转机"
  echo "落地机监听端口为:"
  echo ${port2}
  elif [ "$eNum" = "2" ] ;then
  echo -e "
 ${GREEN} 1.安装ehco(没安装过ehco)
 ${GREEN} 2.不安装ehco(安装过ehco)
 "
 read -p "输入你的选项:" fNum
  if [ "$fNum" = "1" ];then
  wget https://github.com/Ehco1996/ehco/releases/download/v1.0.4/ehco_1.0.4_linux_amd64 && mv ehco_1.0.4_linux_amd64 ehco && chmod +x ehco
  else
  echo "不做安装"
  fi
  read -p "请输入中转机公网ip:" natip
  read -p "请输入ssr节点公网ip:" ssrip1
  read -p "请输入落地机公网监听端口:" port1
  read -p "请输入中转机公网监听端口:" port2
  read -p "请输入web_port端口(随便,但不可重复):" port3
  nohup ./ehco -l 0.0.0.0:${port2} -r wss://${ssrip1}:${port1} --tt mwss --web_port ${port3} --ur ${ssrip1}:${port1} >> /dev/null 2>&1 &
  echo "中转机已设置完成"
  echo "下面语句请复制到节点地址:"
  echo "${ssrip1};server=${natip}|port=22783#${port2}"
  else
  echo "就两个选项，你都选错了，无可救药了"
  fi
  elif [ "$dNum" = "3" ] ;then
  if [[ "$EUID" -ne 0 ]]; then
    echo "false"
  else
    echo "true"
  fi
if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
    
     if [[ $release = "ubuntu" || $release = "debian" ]]; then
ufw disable
apt-get remove ufw
apt-get purge ufw
  elif [[ $release = "centos" ]]; then
  systemctl stop firewalld.service
  systemctl disable firewalld.service 
  else
    exit 1
  fi
  elif [ "$dNum" = "4" ] ;then
  if [[ "$EUID" -ne 0 ]]; then
    echo "false"
  else
    echo "true"
  fi
if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
    
     if [[ $release = "ubuntu" || $release = "debian" ]]; then
apt install net-tools
  elif [[ $release = "centos" ]]; then
  yum install net-tools
  else
    exit 1
  fi
   read -p "输入要杀掉的端口:" killport
kill -9 $(netstat -nlp | grep :${killport} | awk '{print $7}' | awk -F"/" '{ print $1 }')
echo "已杀死"
elif [ "$dNum" = "5" ] ;then
echo -e "
 ${GREEN} 1.更改ssr端口
 ${GREEN} 2.启动ssr
 ${GREEN} 3.停止ssr
 ${GREEN} 4.重启ssr
 "
 read -p "输入选项:" gNum
 if [ "$gNum" = "1" ] ;then
 cd
 cd fgcloud && chmod +x stop.sh && ./stop.sh
 read -p "请输入ssr旧端口:" oldport
 read -p "请输入ssr新端口:" newport
sed -i '4s/${oldport}/'${newport}'/' user-config.json
chmod +x run.sh && ./run.sh
echo "已更换完成，记得前端网站改端口哦！！！"
elif [ "$gNum" = "2" ] ;then
cd
cd fgcloud && chmod +x run.sh && ./run.sh
elif [ "$gNum" = "3" ] ;then
 cd
 cd fgcloud && chmod +x stop.sh && ./stop.sh
 else
 cd
 cd fgcloud
 chmod +x stop.sh && ./stop.sh
 chmod +x run.sh && ./run.sh
 fi
 elif [ "$dNum" = "6" ] ;then
 wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
 else
 ps -aux | grep ehco
 fi
