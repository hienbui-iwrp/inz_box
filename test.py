import web3
import pydash as py_

def sign():
    SIGNER = ["0x0a0dF45777868AcE61cf05bea3C454D33315aA53", "a1a3605d9a4af5fa38d2c7cb7c410bf2bd8473722ef63e15b80322e62beff826"]
    InZBoxCampaignConfigured="0xc4Fe2565079209B15227d0335dED169F2D46744b"
    InZBoxItemCampaignNFT721="0x340CD54335C0c6102Ac593E26D658fB76636EA92"

    _web3 = web3.Web3()
    _encode = _web3.codec.encode_abi(
        [
            'address', # user_address
            'address', # contract creator
            'address' # collection address
        ],
        [
            SIGNER[0],
            InZBoxCampaignConfigured,
            InZBoxItemCampaignNFT721
        ]
    )
    print("_encode: ", _encode)
    print("_encode hex: ", _encode.hex())
    _digest = web3.Web3.solidityKeccak(['bytes'], [f'0x{_encode.hex()}'])
    print("_digest: ", _digest)
    _signed_message = _web3.eth.account.signHash(
        _digest,
        private_key=Config.AUTH_PRIVATE_KEY
    )

    print("_signed_message: ", _signed_message)

    return _signed_message.signature.hex(), _deadline