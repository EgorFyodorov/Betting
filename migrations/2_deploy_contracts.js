const Bet = artifacts.require("Bet");

module.exports = function (deployer, network, accounts) {
    const players = accounts.slice(0,3)
    const numPositions = 2;
    deployer.deploy(Bet, players, numPositions);
};
