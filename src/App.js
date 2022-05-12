import { useState, useEffect } from "react";

import "./App.css";
import Web3 from "web3";
import { newKitFromWeb3 } from "@celo/contractkit";
import BigNumber from "bignumber.js";

import carAbi from "./contract/cars.abi.json";
import ierc20 from "./contract/ierc20.abi.json";
import Header from "./components/Header";
import Tabs from "./components/Tabs";

const ERC20_DECIMALS = 18;

const contractAddress = "0x17d866ce9f9D251E959Bf8Bef64fF2CF59D09eEe";
const cUSDContractAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1";

function App() {
  const [contract, setContract] = useState(null);
  const [address, setAddress] = useState(null);
  const [kit, setKit] = useState(null);
  const [balance, setBalance] = useState(null);
  const [cars, setCars] = useState([]);

  useEffect(() => {
    walletConnect();
  }, []);

  useEffect(() => {
    if (kit && address) {
      getBalance();
    }
  }, [kit, address]);

  useEffect(() => {
    if (contract) {
      getCars();
    }
  }, [contract]);

  const walletConnect = async () => {
    if (window.celo) {
      try {
        await window.celo.enable();
        const web3 = new Web3(window.celo);
        let kit = newKitFromWeb3(web3);

        const accounts = await kit.web3.eth.getAccounts();
        const user_address = accounts[0];

        kit.defaultAccount = user_address;

        await setAddress(user_address);
        await setKit(kit);
      } catch (error) {
        console.log(error);
      }
    } else {
      console.log("Error Occurred");
    }
  };

  const getBalance = async () => {
    try {
      const balance = await kit.getTotalBalance(address);
      const USDBalance = balance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2);
      const contract = new kit.web3.eth.Contract(carAbi, contractAddress);
      setContract(contract);
      setBalance(USDBalance);
    } catch (error) {
      console.log(error);
    }
  };

  const addCar = async (name, description, imageUrl, amount) => {
    try {
      await contract.methods
        .addCar(name, description, imageUrl, amount)
        .send({ from: address });
    } catch (error) {
      console.log(error);
    } finally {
      getCars();
    }
  };

  const getCars = async () => {
    try {
      const carLength = await contract.methods.getCarLength().call();
      const cars = [];
      for (let i = 0; i < carLength; i++) {
        const _cars = new Promise(async (resolve, reject) => {
          const car = await contract.methods.getCar(i).call();
          resolve({
            index: i,
            owner: car[0],
            name: car[1],
            description: car[2],
            imageUrl: car[3],
            amount: car[4],
            likes: car[5],
            dislikes: car[6],
            isSold: car[7],
          });
        });
        cars.push(_cars);
      }
      const _cars = await Promise.all(cars);
      console.log(_cars);
      setCars(_cars);
    } catch (error) {
      console.log(error);
    }
  };

  const likeCar = async (index) => {
    try {
      await contract.methods.likeCar(index).send({ from: address });
    } catch (error) {
      console.log(error);
    } finally {
      getCars();
    }
  };
  const dislikeCar = async (index) => {
    try {
      await contract.methods.dislikeCar(index).send({ from: address });
    } catch (error) {
      console.log(error);
    } finally {
      getCars();
    }
  };

  const buyCar = async (index) => {
    try {
      const cUSDContract = new kit.web3.eth.Contract(
        ierc20,
        cUSDContractAddress
      );
      const amount = new BigNumber(cars[index].amount)
        .shiftedBy(ERC20_DECIMALS)
        .toString();
      await cUSDContract.methods
        .approve(contractAddress, amount)
        .send({ from: address });
      await contract.methods.buyCar(index).send({ from: address });
    } catch (error) {
      console.log(error);
    } finally {
      getCars();
      getBalance();
    }
  };
  return (
    <>
      <div className="container py-3">
        <Header balance={balance} />
        <Tabs
          addCar={addCar}
          cars={cars}
          buyCar={buyCar}
          likeCar={likeCar}
          dislikeCar={dislikeCar}
          address={address}
        />
      </div>
    </>
  );
}

export default App;
