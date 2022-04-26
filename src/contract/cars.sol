// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract CarPark{
    struct Car{
        address payable owner;
        string name;
        string description;
        string image;
        uint amount;
        uint likes;
        uint dislikes;
        bool isSold;
    }

    uint carLength = 0;

    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    mapping(uint256=>Car) internal cars;

    function addCar(
        string memory _name,
        string memory _description,
        string memory _image,
        uint _amount
    )public{
        cars[carLength] = Car(
            payable(msg.sender),
            _name,
            _description,
            _image,
            _amount,
            0,
            0,
            false
        );
        carLength++;
    }

    function getCar(uint _index)public view returns(
        address payable,
        string memory,
        string memory,
        string memory,
        uint,
        uint,
        uint,
        bool
    ){
        Car storage car = cars[_index];
        return (
            car.owner,
            car.name,
            car.description,
            car.image,
            car.amount,
            car.likes,
            car.dislikes,
            car.isSold
        );
    }

    function likeCar(uint index)public{
        cars[index].likes++;
    }

    function dislikeCar(uint index)public{
        cars[index].dislikes++;
    }

    function buyCar(uint index)public payable{
        require(
             IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                cars[index].owner,
                cars[index].amount
            ),
            "Transaction could not be performed"
        );
        cars[index].isSold = true;
        cars[index].owner = payable(msg.sender);
    }

    function sellCar(uint _index)public {
        require(cars[_index].owner == msg.sender, "Only owners can sell car");
        cars[_index].isSold = false;
    }

    function getCarLength() public view returns(uint){
        return carLength;
    }
}