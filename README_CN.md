
## 概述
    
    将用户名称铸造成nft，让链上的名称具有唯一性，变成数字资产，并且可以在多个链之间使用。

## 如何实现

1. 在所有支持的链上发布名为NameNft的DApp，提供铸造nft的功能，一个nft为一个字符串，如zhaojie。
2. 通过NameNftDApp铸造nft时，为nft设置拥有权和使用权。
3. 一个nft的拥有权，只存在于唯一的一条链上，使用权可以在多个链上同时存在。
4. 在A链上持有nft拥有权的用户，可以在B链上将该名称授权给某个地址，此时nft在A链和B链上同时存在，使用权可以有多个，可以在多个链上进行授权。
5. 拥有权可以在不同的链上进行转移，但只能存在于一个链上。
6. 拥有权可以撤销使用权的权限。

## 最终目的
    通过一个字符串(用户名)铸造nft并且可以在多个链上使用，nft的持有者在多个条链上就具有了唯一的用户名。
    
## 运行项目
    
运行环境和axelar-local-gmp-examples一样   
 
    sudo npm i -g n
    sudo n v16.15.0
    
Clone this repo:

    git clone https://github.com/zhaojio/NameNft
    cd NameNft
    npm install
    
Check own private key.
    cp .env.example .env

运行本地测试环境
    node scripts/createLocal

编译和发布合约
    
    npm run build
    node scripts/deploy contracts/nft-name local
    
运行本地测试

    node scripts/deploy contracts/nft-name local
    
拷贝前端资源文件

    chmod +x copy.sh
    ./copy.sh

使用npm http-server运行前端页面
    
    npm install -g http-server
    cd frontend/release
    http-server

在浏览器中打开页面
   
   http://127.0.0.1:8080/
   
![image](https://github.com/zhaojio/NameNft/blob/main/frontend/name-nft-ui.png)
   
   
## 为什么有拥有权和使用权
    如果注册时只是将用户名在多个链同时铸造，由于时间差的问题，不能保证多个链上都能铸造成功，比如同时有2个地址在2个链上同时铸造，就会产生冲突。引入拥有权并只在一个链上存在之后，铸造时首先查询其他链上用户名是否存在，可以保证唯一性，但此时用户名只能存在于一个链上，可用性受限，因此需要再引入使用权的概念，即能保证唯一性又可以在更多的地方使用。

## 应用场景(假设)

1. 通过名称找到对应的用户。
2. 通过地址转账时通过名称确认用户身份，避免发生错误。
    例如：
    1. 第三方钱包app集成NameNftDapp，转账时通过名称找到对方地址。
    2. 第三方聊天app集成NameNftDapp，通过@xxxx找到某个用户。
    3. 第三方钱包app集成NameNftDapp，填写地址时提示该地址对应的名称，用于确认用户身份，避免发生错误。


