// SPDX-License-Identifier: MIT
/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 * @dev jrcalleac
 * _Available since v3.1._
 */
pragma solidity 0.8.0;

import "./ERC1155/ERC1155.sol";
import "./utils/ERC1155Holder.sol";
import "./utils/Ownable.sol";


contract TOKENFactory is ERC1155, ERC1155Holder, Ownable {
    
    constructor( uint _native_token_supply, uint _trade_fee) ERC1155("test")  {
        trade_fee=_trade_fee;
        address2state[msg.sender]=true;
        _mint(owner(), 0, _native_token_supply, Deploydata);
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC1155Receiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // declare our event here
    bytes Deploydata;
    uint fee=1;
    uint id=0;
    uint native_token_supply;
    uint trade_fee;
    uint sale_ID;
    address factory_address;
    uint trade_price;
    uint trade_TOKEN_id;
    uint trade_amount;
    uint trade_fee_value;
    uint trade_pay_value;
    address trade_owner;
    uint addres_percentage;
    uint share_payment;
    uint owner_mint;
    uint contract_mint;
    uint  total_holders_supply;
    uint trade_supply;
    
    struct TOKEN {
        string name;
        uint market_price;
        uint total_supply;
        uint sell_percentage;
        address owner_address;
        bytes data;
    }
    
    TOKEN[] public TOKEN;
    mapping(uint => address[]) public holder_list;
    mapping(uint =>uint) holder_list_length;
    mapping(address=>uint) address2totalfeesPaid;
    mapping (address => bool) address2state;
    mapping (uint => uint) TOKENID2price;
    mapping (address => uint) balance;
    mapping (uint => uint) public TOKENID2sell_supply;
    
    function buyTOKEN(uint _TOKEN_ID, uint _native_value) public{
        require(_native_value>0,"buy value must be positive");
        trade_amount=_native_value/TOKENID2price[_TOKEN_ID];
        require(TOKENID2sell_supply[_TOKEN_ID]-trade_amount>0,"not enough supply to sell, try less");
        trade_fee_value=_native_value*trade_fee/100;
        trade_pay_value=_native_value-trade_fee_value;
        trade_owner=TOKEN[_TOKEN_ID-1].owner_address;
        trade_supply=TOKEN[_TOKEN_ID-1].total_supply;
        //safeTransferFrom(msg.sender, address(this), 0, trade_fee_value , Deploydata);
        for (uint i=0; i<holder_list_length[_TOKEN_ID]; i++){
             share_payment=trade_fee_value*balanceOf(holder_list[_TOKEN_ID][i],_TOKEN_ID);
             safeTransferFrom(msg.sender, holder_list[_TOKEN_ID][i], 0, share_payment/trade_supply , Deploydata);
        }
        safeTransferFrom(msg.sender, trade_owner, 0, trade_pay_value , Deploydata);
        //TOKEN_ID2totalSelled[_TOKEN_id]=TOKEN_ID2totalSelled[trade_TOKEN_id]+trade_amount;
        _safeTransferFrom(address(this),  msg.sender, _TOKEN_ID, trade_amount , Deploydata);
        TOKENID2sell_supply[_TOKEN_ID]=TOKENID2sell_supply[_TOKEN_ID]-trade_amount;
        holder_list_length[_TOKEN_ID]++;
        holder_list[_TOKEN_ID].push(msg.sender);
    }
    

    function set_fee(uint _new_fee) public onlyOwner{
        fee=_new_fee;
    }

    function add_publisher_owner(address _address) public onlyOwner {
        address2state[_address]=true;
    }
    
    function _createTOKEN(string memory _name, uint _market_price, uint _total_supply, uint _sell_percentage, address _owner_address) private {
        id++;
        TOKEN.push(TOKEN(_name,_market_price, _total_supply, _sell_percentage, _owner_address, Deploydata));
        TOKENID2price[id]=_market_price/_total_supply;
        // and fire it here
        contract_mint=_total_supply*_sell_percentage/100;
        owner_mint=_total_supply-contract_mint;
        holder_list[id].push(address(this));
        holder_list[id].push(_owner_address);
        holder_list_length[id]=2;
        TOKENID2sell_supply[id]=contract_mint;
        _mint(_owner_address, id, owner_mint, Deploydata);
        _mint(address(this), id, contract_mint, Deploydata);
    }

    function createUniqueTOKEN(string memory _name, uint _market_price, uint _TOKEN_Supply, uint _sell_percentage,  address _owner_address) public {
        require(_market_price>0 && _TOKEN_Supply>0 && _sell_percentage>0,"market price, total supply and sell percentage must be positive");
        require(address2state[msg.sender]==true,"address must be  partner");
        _createTOKEN(_name, _market_price, _TOKEN_Supply, _sell_percentage, _owner_address);
    }
    
    function get_contract_profit() public onlyOwner{
        _safeTransferFrom(address(this), owner(), 0, balanceOf(address(this),0) , Deploydata);
    }
    
    function mint_native(uint _value_mint) public onlyOwner{
         _mint(owner(), 0,_value_mint, Deploydata);
    }
    
    function airdrop(uint _TOKEN_ID, uint _TOKEN_value, address _user ) public onlyOwner{
        require(_TOKEN_value>0,"buy value must be positive");
        require(TOKENID2sell_supply[_TOKEN_ID]-_TOKEN_value>0,"not enough supply to sell, try less");
        _safeTransferFrom(address(this),  _user, _TOKEN_ID, _TOKEN_value , Deploydata);
        TOKENID2sell_supply[_TOKEN_ID]=TOKENID2sell_supply[_TOKEN_ID]-_TOKEN_value;
        holder_list_length[_TOKEN_ID]++;
        holder_list[_TOKEN_ID].push(_user);
    }
    
     function update_market_price( uint _TOKEN_ID, uint _market_price) public onlyOwner{
        TOKEN[_TOKEN_ID-1].market_price= _market_price;
        TOKENID2price[_TOKEN_ID]=_market_price/TOKEN[_TOKEN_ID-1].total_supply;
        
    }
    
     function update_total_supply( uint _TOKEN_ID, uint _additional_supply) public onlyOwner{
         require (_additional_supply>0, "Additional Supply must be positive");
        _mint(address(this), _TOKEN_ID, _additional_supply, Deploydata);
        TOKEN[_TOKEN_ID-1].total_supply= TOKEN[_TOKEN_ID-1].total_supply+_additional_supply;
        TOKENID2price[_TOKEN_ID]=TOKEN[_TOKEN_ID-1].market_price/TOKEN[_TOKEN_ID-1].total_supply;
    }
    
}