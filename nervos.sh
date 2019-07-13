#! /bin/bash

## This is Nervos install shell,version 0.0.1
## Writen by BearWo 2019-07-11

##https://github.com/nervosnetwork/ckb/releases/download/v0.15.6/ckb_v0.15.6_x86_64-unknown-linux-gnu.tar.gz
##https://github.com/nervosnetwork/ckb-cli/releases/download/v0.15.0/ckb-cli_v0.15.0_x86_64-unknown-linux-gnu.tar.gz

clear
echo "脚本执行首次时，非root用户需验证当前用户密码（已经验证过请忽略）"
targetPath="/var/tmp/nervos"
sudo mkdir -p $targetPath
sudo chmod 777 $targetPath


echo "注意：文件将被安装在：$targetPath下"
echo
echo "===================开始下载ckb相关文件===================="
echo
ckb="https://github.com/nervosnetwork/ckb/releases/download/"
ckbVersion="v0.15.6"
ckbFile="ckb_"$ckbVersion"_x86_64-unknown-linux-gnu"
ckbSuffix=".tar.gz"
ckbPath=$ckb$ckbVersion"/"$ckbFile$ckbSuffix

## 打扫卫生
sudo rm -rf $targetPath/*
sudo rm -rf /usr/local/bin/ckb
sudo rm -rf /usr/local/bin/ckb-cli
## 不删除源文件了，github下载太慢了，下一次就受够了~~~
# rm -rf $ckbFile$ckbSuffix

## 下载并安装ckb（download the ckb and redirect to bin）
if [ ! -f "$ckbFile$ckbSuffix" ]; then
wget -c $ckbPath
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
echo "接下来你需要手动配置ckb.toml文件，找到里面的'[block_assembler]'代码块，并替换其中的lock_args"
echo "能帮你的就在这了，去修改吧~"
echo "改好之后使用命令'ckb run'即可启动节点，再开一个终端，使用命令'ckb miner'来启动挖矿程序"
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
echo
echo "官方的钱包导入教程还没出来，所以现在我也不知道怎么导入！！！bye-bye"
flag=2
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





