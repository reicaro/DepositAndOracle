var erc = artifacts.require("ERC20");

module.exports = function(deployer){
  deployer.deploy(erc);
}