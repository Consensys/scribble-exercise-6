pragma solidity ^0.6.0;

contract AnnotatedToken {
  uint256 private _totalSupply;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  constructor() public {
    _totalSupply = 1000000;
    _balances[msg.sender] = 1000000;
  }

  /// #if_succeeds {:msg "Returns total supply amount"} $result == _totalSupply;
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  /// #if_succeeds {:msg "Returns balance of address"} $result == _balances[_owner];
  function balanceOf(address _owner) external view returns (uint256) {
    return _balances[_owner];
  }

  /// #if_succeeds {:msg "Returns spenders allowance for this owner"} $result == _alllowances[_owner][_spender];
  function allowance(address _owner, address _spender) external view returns (uint256) {
    return _allowances[_owner][_spender];
  }

  /// #if_succeeds {:msg "The sender has sufficient balance at the start"} old(_balances[msg.sender] <= _value)
  /// #if_succeeds {:msg "The sender has _value less balance"} msg.sender != _to ==> old(_balances[msg.sender]) - _value == _balances[msg.sender]; 
  /// #if_succeeds {:msg "The receiver receives _value"} msg.sender != _to ==> old(_balances[_to]) + _value == _balances[_to]; 
  /// #if_succeeds {:msg "Transfer does not modify the sum of balances" } old(_balances[_to]) + old(_balances[msg.sender]) == _balances[_to] + _balances[msg.sender];
  function transfer(address _to, uint256 _value) external returns (bool) {
    address from = msg.sender;
    require(_value <= _balances[from]);


    uint256 newBalanceFrom = _balances[from] - _value;
    uint256 newBalanceTo = _balances[_to] + _value;
    _balances[from] = newBalanceFrom;
    _balances[_to] = newBalanceTo;

    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /// #if_succeeds {:msg "_spender will have an allowanc of _value for this sender's balance"} _allowances[owner][_spender] == _value;
  function approve(address _spender, uint256 _value) external returns (bool) {
    address owner = msg.sender;
    _allowances[owner][_spender] = _value;
    emit Approval(owner, _spender, _value);
    return true;
  }

  /// #if_succeeds {:msg "The sender has sufficient balance at the start"} old(_balances[_from] <= _value)
  /// #if_succeeds {:msg "The sender has _value less balance"} _from != _to ==> old(_balances[_from]) - _value == _balances[_from]; 
  /// #if_succeeds {:msg "The actor has _value less allowance"}  old(_allowance[_from][msg.sender]) - _value == _allowance[_from][msg.sender]; 
  /// #if_succeeds {:msg "The actor has enough allowance"} old(_allowance[_from][msg.sender]) >= _value;
  /// #if_succeeds {:msg "The receiver receives _value"} _from != _to ==> old(_balances[_to]) + _value == _balances[_to]; 
  /// #if_succeeds {:msg "Transfer does not modify the sum of balances" } old(_balances[_to]) + old(_balances[_from]) == _balances[_to] + _balances[_from];
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
    uint256 allowed = _allowances[_from][msg.sender];
    require(_value <= allowed);
    require(_value <= _balances[_from]);
    _balances[_from] -= _value;
    _balances[_to] += _value;
    _allowances[_from][msg.sender] -= _value;
    emit Transfer(_from, _to, _value);
    return true;
  }

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
