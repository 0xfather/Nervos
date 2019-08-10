#! /bin/bash

## This is Nervos install shell,version 0.0.18
## Writen by BearWo 2019-08-10

#https://github.com/nervosnetwork/ckb/releases/download/v0.16.0/ckb_v0.16.0_x86_64-unknown-linux-gnu.tar.gz
#https://github.com/nervosnetwork/ckb/releases/download/v0.18.0/ckb_v0.18.0_x86_64-unknown-linux-gnu.tar.gz

clear
echo "脚本执行首次时，非root用户需验证当前用户密码（已经验证过请忽略）"
targetPath="/var/tmp/nervos"
sudo mkdir -p $targetPath
sudo chmod 777 $targetPath


echo "注意：文件将被安装在：$targetPath下"
echo
echo "===================开始下载ckb相关文件===================="
echo
##国内源没流量了，还得用国外源
ckb="https://github.com/nervosnetwork/ckb/releases/download/"
ckbVersion="v0.18.0"
ckbFile="ckb_"$ckbVersion"_x86_64-unknown-linux-gnu"
ckbSuffix=".tar.gz"
ckbPath=$ckb$ckbVersion"/"$ckbFile$ckbSuffix
##更改下载路径为国内源
#ckb="http://pukb0g8nl.bkt.clouddn.com/"
#ckbVersion="v0.16.0"
#ckbFile="ckb_"$ckbVersion"_x86_64-unknown-linux-gnu"
#ckbSuffix=".tar.gz"
#ckbPath=$ckb"/"$ckbFile$ckbSuffix

## 打扫卫生
sudo rm -rf $targetPath/*
sudo rm -rf /usr/local/bin/ckb
sudo rm -rf /usr/local/bin/ckb-cli
## 不删除源文件了，github下载太慢了，下一次就受够了~~~
# rm -rf $ckbFile$ckbSuffix

## 下载并安装ckb（download the ckb and redirect to bin）
if [ ! -f "$ckbFile$ckbSuffix" ]; then
wget -c $ckbPath --no-check-certificate
fi
tar -zxf $ckbFile$ckbSuffix -C $targetPath && \
cd $targetPath
echo
echo "==============ckb相关文件已下载并安装完成================"

sudo ln -snf "$targetPath/$ckbFile/ckb" /usr/local/bin/ckb
sudo ln -snf "$targetPath/$ckbFile/ckb-cli" /usr/local/bin/ckb-cli


createPrivkey(){
echo
read -p "请输入你的lock_arg信息:" args
cd $targetPath
ckb-cli account export --lock-arg $args --extended-privkey-path privkey
echo
}

createWallet(){
echo	
read -p "你将创建一个新钱包，在此过程中需要设定你的钱包密码，请按回车键继续……"
cd $targetPath
ckb-cli account new
echo "提示：这里的信息很重要，请记录下你的钱包地址和lock_arg参数信息，这将是你获取私钥的重要参数"
createPrivkey
}

restoreWalletByKey(){
echo
read -p "请输入你的第一行私钥（privkey）：" pk
read -p "请输入你的第二行私钥（privkey）：" wa
cd $targetPath
echo $pk > privkey
echo $wa >> privkey
cd $targetPath
ckb-cli account import --privkey-path privkey
echo
echo "钱包已恢复完成"
}

restoreWalletByFile(){
echo
echo "当前路径："
pwd
echo "当前路径文件列表："
ls -l
echo
echo "请输入你的private文件路径，如：/home/debian/privkey"
read -p "private文件路径:" args
while [ ! -f "$args" ]; do
	echo "输入的文件路径不对，请重新输入"
	read -p "private文件路径:" tp
	args=$tp
done
cd $targetPath
echo
echo "提示：请输入新的钱包密码："
ckb-cli account import --privkey-path $args
echo
echo "钱包已恢复完成"
}

showPrivkey(){
echo "您的私钥已生成，第一行为您的私钥，第二行为钱包链编码："
echo
cat $targetPath/privkey
echo
echo
read -p "提示：请尽快备份下来，这将是你的钱包唯一可用的找回信息，按回车键继续……"
}

installNode(){
echo
echo
echo "===================================黄金分割线==================================="
echo "测试网络节点部署中……"
echo
cd $targetPath
ckb init -C testnet --chain testnet 
echo
echo "测试网络节点已部署完成！"
echo
cd $targetPath/testnet
echo "当前路径："
pwd
echo "当前文件列表："
ls -l
## 启动节点（ckb run）
echo
echo
echo "节点程序已部署完成"
echo
echo
read -p "请输入你的lock_arg信息来配置你的同步节点：" args
echo "[block_assembler]" >>  ckb.toml
echo "code_hash = \"0x54811ce986d5c3e57eaafab22cdd080e32209e39590e204a99b32935f835a13c\"" >> ckb.toml
argsStr="0x"$args
echo "args = [ \"$argsStr\" ]" >> ckb.toml
echo
echo "节点已配置完成，节点同步将自动启动！请再打开一个终端，使用命令'ckb miner'来启动挖矿程序"
echo "正在启动节点同步……"
ckb run
echo
echo
echo
}



echo
## 创建或导入钱包（create or import your wallet）
flag=1
read -p "请选择钱包创建方式 : 1.创建一个新钱包  2.通过已有私钥导入钱包 ,请选择 1 或 2 : " a
if [ $a -eq 1 ]; then
	## 创建一个新钱包（create a new wallet）
	createWallet

	privkeyPath=$targetPath/privkey
	while [ ! -f "$privkeyPath" ]
	do
		echo "lock_args或密码错误，私钥生成失败，请重新生成"
		createPrivkey
	done
	showPrivkey
	if [ $flag -eq 1 ]; then
		## 部署ckb节点程序（run a ckb node）
		installNode
	fi

elif [ $a -eq 2 ]; then
	## 通过私钥导入钱包
	flag=2
	while [ $flag -eq 2 ]; do
		echo
		read -p "请选择恢复方式 : 1.通过钱包私钥字符串恢复  2.通过钱包私钥文件（privkey）恢复 ,请选择 1 或 2 : " b
		if [ $b -eq 1 ]; then
			restoreWalletByKey
			flag=1
		elif [ $b -eq 2 ]; then
			restoreWalletByFile
			flag=1
		else
			echo "输入的数字不对，只能输入1或2"
			flag=2
		fi
	done

	if [ $flag -eq 1 ]; then
		## 部署ckb节点程序（run a ckb node）
		installNode
	fi
	echo
	echo
	echo

else
	echo
	echo "你输入的什么啊！逗我玩呢？不干了！！！bye-bye"
	flag=2
	echo
	echo
	echo
fi