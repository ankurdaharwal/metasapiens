import React, { useEffect, useState } from 'react';
import { ethers } from 'ethers';
import './App.css';
import twitterLogo from './assets/twitter-logo.svg';

// Components
import SelectCharacter from './Components/SelectCharacter';
import Arena from './Components/Arena';
import LoadingIndicator from './Components/LoadingIndicator';

import metaSapiens from './utils/MetaSapiens.json';

// Constants
import { CONTRACT_ADDRESS, transformCharacterData } from './constants';
const TWITTER_HANDLE = 'An1cu12';
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;


const App = () => {

// State
const [currentAccount, setCurrentAccount] = useState(null);

/*
 * Right under current account, setup this new state property
 */
const [characterNFT, setCharacterNFT] = useState(null);

const [isLoading, setIsLoading] = useState(false);

  // Actions
  const checkIfWalletIsConnected = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        console.log('Make sure you have MetaMask!');
        return;
      } else {
        console.log('We have the ethereum object', ethereum);
      }

      const accounts = await ethereum.request({ method: 'eth_accounts' });

      if (accounts.length !== 0) {
        const account = accounts[0];
        console.log('Found an authorized account:', account);
        setCurrentAccount(account);
      } else {
        console.log('No authorized account found');
      }
    } catch (error) {
      console.log(error);
    }
  };

  /*
   * Implement your connectWallet method here
   */
  const connectWalletAction = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        alert('Get MetaMask!');
        return;
      }

      /*
       * Fancy method to request access to account.
       */
      const accounts = await ethereum.request({
        method: 'eth_requestAccounts',
      });

      /*
       * Boom! This should print out public address once we authorize Metamask.
       */
      console.log('Connected', accounts[0]);
      setCurrentAccount(accounts[0]);
    } catch (error) {
      console.log(error);
    }
  };

  // Render Methods
const renderContent = () => {

  if (isLoading) {
    return <LoadingIndicator />;
  }
  
  /*
   * Scenario #1
   */
  if (!currentAccount) {
    return (
      <div className="connect-wallet-container">
        <video width="320" height="240" autoPlay>
          <source src="https://i.imgur.com/MfuSeoA.mp4" type="video/mp4" />
          Your browser does not support the video tag.
        </video>
        <button
          className="cta-button connect-wallet-button"
          onClick={connectWalletAction}
        >
          Connect Wallet To Get Started
        </button>
      </div>
    );
    /*
     * Scenario #2
     */
  } else if (currentAccount && !characterNFT) {
    return <SelectCharacter setCharacterNFT={setCharacterNFT} />;
  } else if (currentAccount && characterNFT) {
  return <Arena characterNFT={characterNFT} />;
}
};

  useEffect(() => {
    setIsLoading(true);
    checkIfWalletIsConnected();
  }, []);

  /*
 * Add this useEffect right under the other useEffect where you are calling checkIfWalletIsConnected
 */
useEffect(() => {
  /*
   * The function we will call that interacts with out smart contract
   */
  const fetchNFTMetadata = async () => {
    console.log('Checking for Character NFT on address:', currentAccount);

    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const gameContract = new ethers.Contract(
      CONTRACT_ADDRESS,
      metaSapiens.abi,
      signer
    );

    const userNFT = await gameContract.checkIfUserHasNFT();
    if (userNFT.name) {
      console.log('User has character NFT');
      setCharacterNFT(transformCharacterData(userNFT));
      setIsLoading(false);
    };

  if (characterNFT?.name) {
    console.log('User has character NFT');
    setCharacterNFT(transformCharacterData(characterNFT));
  } else {
    console.log('No character NFT found!');
  }
};

  /*
   * We only want to run this, if we have a connected wallet
   */
  if (currentAccount) {
    console.log('CurrentAccount:', currentAccount);
    fetchNFTMetadata();
    setIsLoading(false);
  }
}, [currentAccount]);

  return (
  <div className="App">
    <div className="container">
      <div className="header-container">
        <p className="header gradient-text">⚔️ MetaSapiens ⚔️</p>
        <p className="sub-text">Team up to protect the Metaverse!</p>
        {/* This is where our button and image code used to be!
         *	Remember we moved it into the render method.
         */}
        {renderContent()}
      </div>
      <div className="footer-container">
        <img alt="Ankur's Twitter" className="twitter-logo" src={twitterLogo} />
        <a
          className="footer-text"
          href={TWITTER_LINK}
          target="_blank"
          rel="noreferrer"
        >{`Built by @${TWITTER_HANDLE}`}</a>
      </div>
    </div>
  </div>
);
};

export default App;