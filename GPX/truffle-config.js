module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!
    
    networks: {
        "development": {
            network_id: 2,
            host: "localhost",
            port: 8545
        },
        "live": {
            network_id: 3,
            host: '13.250.50.145',
            port: 8545,
            gas: 600000,
            from: '0xfe767f199e679fe7b7615a7916d75e8b19eff3b3'
        }
    }


};
