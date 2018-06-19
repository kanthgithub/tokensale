var ParcelXToken = artifacts.require("ParcelXToken");

module.exports = function(deployer) {
  // deployer.deploy(ParcelXToken, ["0x627306090abab3a6e1400e9345bc60c78a8bef57", "0xf17f52151ebef6c7334fad080c5704d77216b732", "0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef"], 2);
  deployer.deploy(ParcelXToken, ["0xfe767F199e679fE7B7615A7916D75e8b19EFf3B3", "0x8BB8ed15FaB3E7d5F081fEFB433Cff76df6ebEFF", "0xe7b63545572ad7c8fa80fc35a4f97c4e54e72ff3"], 2);

};

