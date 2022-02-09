var a = artifacts.require("A");
var b = artifacts.require("B");

module.exports = function(deployer){
  deployer.deploy(a);
  deployer.deploy(b);
}