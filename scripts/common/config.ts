const CONFIG: Record<string, Record<string, string | any>> =  {
    "LITE_BRIDGE": {
        "80001": "0x818c4144dC4b6aa66422C7DCf5977B75EcE834eB",
        "5": "0x818c4144dC4b6aa66422C7DCf5977B75EcE834eB",
        "137": "0xE9C50782d354b1f83c7c56c50C5230873B608F0F",
        "1": "0xE9C50782d354b1f83c7c56c50C5230873B608F0F"
    },
    "MOCK_VAULT": {
        "80001": "0x8cab79f95690532972cda4f67d14520f9f492cbc",
        "5": "0x6518B17D0A54455d347F2dAABcC9992f31F5a8Cb",
        "137": "0xE9C50782d354b1f83c7c56c50C5230873B608F0F",
        "1": "0xE9C50782d354b1f83c7c56c50C5230873B608F0F"
    },
    "WETH_ADDRESS": {
        "1": "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
        "5": "0xb4fbf271143f4fbf7b91a5ded31805e42b2208d6",
        "137": "0x7ceb23fd6bc0add59e62ac25578270cff1b9f619",
        "80001": "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa"
    },
    "PROXY_ADMIN": {
        "80001": "0xeAE2289A1040Ae322466c346a73A0a81366FfBC3",
        "5": "0xeAE2289A1040Ae322466c346a73A0a81366FfBC3",
        "137": "0xE9C50782d354b1f83c7c56c50C5230873B608F0F",
        "1": "0xE9C50782d354b1f83c7c56c50C5230873B608F0F"
    },
    "LITE_BRIDGE_CONSTUCTOR_ARGS": {
        "1": {
            "rootChainManagerProxy": "0x37D26DC2890b35924b40574BAc10552794771997",
            "fxRoot": "0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2",
            "weth": "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
            "steth": "0xae7ab96520de3a18e5e111b5eaab095312d7fe84",
            "1inch": "0x1111111254fb6c44bAC0beD2854e76F90643097d"
        },
        "5": {
            "rootChainManagerProxy": "0xBbD7cBFA79faee899Eaf900F13C9065bF03B1A74",
            "fxRoot": "0x3d1d3E34f7fB6D26245E6640E1c50710eFFf15bA",
            "weth": "0xb4fbf271143f4fbf7b91a5ded31805e42b2208d6",
            "steth": "0x2DD6530F136D2B56330792D46aF959D9EA62E276",
            "1inch": "0x1111111254fb6c44bAC0beD2854e76F90643097d"
        },
        "137": {
            "fxChild": "0x8397259c983751DAf40400790063935a11afa28a"
        },
        "80001": {
            "fxChild": "0xCf73231F28B7331BBe3124B907840A94851f9f11"
        }
    }
}

export default CONFIG