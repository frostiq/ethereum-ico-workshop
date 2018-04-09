const Token = artifacts.require("./token/MyIcoToken")

module.exports = function(deployer, network, accounts) {
  deployer.deploy(Token)
};
