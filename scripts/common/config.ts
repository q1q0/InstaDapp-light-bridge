const MOCK_DEX: Record<string, string> = {
    "80001": "0xD20324CE7B7BFaec4342e0566B5E1Dc7721A4E1f",
    "5": "0xdfd92576d682a21331afb61b3ee09f0b4f7d05a8",
    "137": "",
    "1": "0x1111111254fb6c44bAC0beD2854e76F90643097d"
}


const CONFIG: Record<string, Record<string, string | any>> =  {
    "LITE_BRIDGE": {
        "80001": "0xdd6701bB025a5f738897670Ce01eA30F980EF2A2",
        "5": "0xdd6701bB025a5f738897670Ce01eA30F980EF2A2",
        "137": "0xE9C50782d354b1f83c7c56c50C5230873B608F0F",
        "1": "0xE9C50782d354b1f83c7c56c50C5230873B608F0F"
    },
    "MOCK_DEX": MOCK_DEX,
    "MOCK_VAULT_ETH": {
        "80001": "0x8cab79f95690532972cda4f67d14520f9f492cbc",
        "5": "0x6518B17D0A54455d347F2dAABcC9992f31F5a8Cb",
        "137": "",
        "1": ""
    },
    "MOCK_VAULT_TOKEN": {
        "80001": "0x58287d6B5F0766b7919F17efa79f8a44c35f1A11",
        "5": "0xae0eE80B1622c8Ee695AeA44055990aa494C6d10",
        "137": "",
        "1": ""
    },
    "WETH_ADDRESS": {
        "1": "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
        "5": "0xb4fbf271143f4fbf7b91a5ded31805e42b2208d6",
        "137": "0x7ceb23fd6bc0add59e62ac25578270cff1b9f619",
        "80001": "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa"
    },
    "STETH_ADDRESS": {
        "1": "0xae7ab96520de3a18e5e111b5eaab095312d7fe84",
        "5": "0x2DD6530F136D2B56330792D46aF959D9EA62E276",
        "137": "",
        "80001": ""
    },
    "TOKEN_ADDRESS": {
        "1": "",
        "5": "0x655F2166b0709cd575202630952D71E2bB0d61Af",
        "137": "",
        "80001": "0xfe4f5145f6e09952a5ba9e956ed0c25e3fa4c7f1"
    },
    "PROXY_ADMIN": {
        "80001": "0xeAE2289A1040Ae322466c346a73A0a81366FfBC3",
        "5": "0xeAE2289A1040Ae322466c346a73A0a81366FfBC3",
        "137": "",
        "1": ""
    },
    "OWNER": {
        "80001": "0xbEc0b65E5EC78cA9359Cd3f65F7fA3a33c8bFC40",
        "5": "0xbEc0b65E5EC78cA9359Cd3f65F7fA3a33c8bFC40",
        "137": "",
        "1": ""
    },
    "LITE_BRIDGE_CONSTUCTOR_ARGS": {
        "1": {
            "rootChainManagerProxy": "0x37D26DC2890b35924b40574BAc10552794771997",
            "fxRoot": "0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2",
            "weth": "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
            "steth": "0xae7ab96520de3a18e5e111b5eaab095312d7fe84",
            "1inch": MOCK_DEX["1"]
        },
        "5": {
            "rootChainManagerProxy": "0xA0c68C638235ee32657e8f720a23ceC1bFc77C77",
            "fxRoot": "0x3d1d3E34f7fB6D26245E6640E1c50710eFFf15bA",
            "weth": "0xb4fbf271143f4fbf7b91a5ded31805e42b2208d6",
            "steth": "0x2DD6530F136D2B56330792D46aF959D9EA62E276",
            "1inch": MOCK_DEX["5"]
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