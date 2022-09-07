// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 { 
    function transferFrom(
        address from,
        address to,
        uint256 amountoftoken
    ) external returns(bool);

    function transfer(address to, uint256 amount) external returns (bool) ;
    function balanceOf(address account) external returns (uint256);
}

contract Ether_Wallet{
    /// @dev ETHER WALLET that allow you to send and receive money/tokens from others FINISH 🤑
    address owner;
    uint256 totalEth;

    //////CONSTRUCTOR INTIALISE OWNER TO MSG.SENDER////////
    constructor(){
        owner = msg.sender;
    }

    ////////////////CUSTOM ERRORS/////////////////////

    /// less than zero
    error ZeroEth();
    /// only owner
    error OwnerOnly();
    /// not enough eth
    error NotEnoughEth();
    
    ////////////////EVENTS//////////////////////////
    event receivedeth(address indexed  sender, uint amount);
    event withdraw(address indexed  to, uint amount);
    event tokenbals(address caller, uint bal);
    event lost(uint amount);


    function receiveth() external payable  {
        require(msg.sender != address(this));
        if(msg.value > 0){
            revert ZeroEth();
        }
        totalEth = totalEth + msg.value;
        emit receivedeth(msg.sender, msg.value);
    }

    /// @dev the owner can send money to his address or others wih this function
    //// @param it takes in the amount of the owner wants to send 
    //// @param it takes in the address of the owner wants to send 

    function sendOut(uint256 _amount, address _to) external{
        require(_to != address(0));
        if(msg.sender != owner){
            revert OwnerOnly();
        }
        if(_amount > totalEth){
            revert NotEnoughEth();
        }
        totalEth = totalEth - _amount;
        (bool sent,) = payable(_to).call{value:_amount}("");
        require(sent, "failed");
        emit withdraw(_to , _amount);
    }

    /// @dev withdraw lost eths

    function withdrawLostfunds() external  {
        if(msg.sender != owner){
            revert OwnerOnly();
        }
        uint lostEth = address(this).balance - totalEth;
        (bool sent,) = payable(msg.sender).call{value:lostEth}("");
        require(sent, "failed");
        emit lost(lostEth);
    }

    function recievetokens(IERC20 tokenaddress, uint amount) external {
        require(msg.sender != address(0));
        if(amount > 0){
            revert ZeroEth();
        }
        bool sent = IERC20(tokenaddress).transferFrom(msg.sender,address(this), amount);
        require(sent, "failed");
        emit receivedeth(msg.sender, amount);
    }

    /// @dev the owner can send tokens to his address or others wih this function
    //// @param it takes in the amount of the owner wants to send 
    //// @param it takes in the address of the owner wants to send 
    //// @param it takes in the address of the token contract 

    function sendOutTokens(IERC20 tokenaddress, uint amount , address _to) external {
        require(msg.sender != address(this));
        if(msg.sender != owner){
            revert OwnerOnly();
        }
        uint tokenbal =  IERC20(tokenaddress).balanceOf(msg.sender);
        if(amount > tokenbal){
            revert NotEnoughEth();
        }
        bool sent = IERC20(tokenaddress).transfer(_to, amount);
        require(sent, "failed");
         emit withdraw(_to , amount);
        
    }

    function tokenBal(IERC20 tokenaddress) external  returns(uint){
        uint tokenbal =  IERC20(tokenaddress).balanceOf(msg.sender);
        emit tokenbals(msg.sender, tokenbal);
        return tokenbal;
    }

    function ethBal() external  view returns(uint){
        uint ethbal = address(this).balance;
        return ethbal;
    }

    /// @dev get lost tokens 

    function withdrawotherTokens(IERC20 otherAddress) external  {
        if(msg.sender != owner){
            revert OwnerOnly();
        }  
        uint256 otherTokenAmount  = otherAddress.balanceOf(address(this));

        bool sent = otherAddress.transfer(owner,otherTokenAmount);
        require(sent, "failed");
        emit lost(otherTokenAmount);
    }  

    receive() external  payable {}
}  


