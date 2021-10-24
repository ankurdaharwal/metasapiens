/**
 *  Author  : Ankur Daharwal (@ankurdaharwal)
 *  Project : MetaSapiens
 *  Tags    : GameFi, NFT, Metaverse, Gaming
 *  File    : MetaSapiens.sol
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Helper we wrote to encode in Base64
import "./libraries/Base64.sol";

// Hardhat util for console output
import "hardhat/console.sol";

// MetaSapiens inherits from a standard ERC721 NFT contract
contract MetaSapiens is ERC721 {
  // sapien attributes struct
  struct SapienAttributes {
    uint256 sapienIndex;
    string name;
    string class;
    string imageURI;
    uint256 hp;
    uint256 maxHp;
    uint256 attackDamage;
  }

  struct BigBoss {
    string name;
    string imageURI;
    uint256 hp;
    uint256 maxHp;
    uint256 attackDamage;
  }

  // Contract events.
  event SapienNFTMinted(address sender, uint256 tokenId, uint256 sapienIndex);
  event AttackComplete(uint256 newBossHp, uint256 newPlayerHp);

  BigBoss public bigBoss;

  // The tokenId is the NFTs unique identifier, it's just a number that goes
  // 0, 1, 2, 3, etc.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // Sapiens struct array.
  SapienAttributes[] defaultSapiens;

  // We create a mapping from the nft's tokenId => Sapien's attributes.
  mapping(uint256 => SapienAttributes) public nftHolderAttributes;

  // A mapping from an address => the NFTs tokenId.
  // NFT token holder register for future reference.
  mapping(address => uint256) public nftHolders;

  constructor(
    string[] memory sapienNames,
    string[] memory classes,
    string[] memory sapienImageURIs,
    uint256[] memory sapienHp,
    uint256[] memory sapienAttackDmg,
    string memory bossName, // These new variables would be passed in via run.js or deploy.js.
    string memory bossImageURI,
    uint256 bossHp,
    uint256 bossAttackDamage
  ) ERC721("Sapiens", "SAPIEN") {
    // Initialize the boss. Save it to our global "bigBoss" state variable.
    bigBoss = BigBoss({
      name: bossName,
      imageURI: bossImageURI,
      hp: bossHp,
      maxHp: bossHp,
      attackDamage: bossAttackDamage
    });

    console.log(
      "Done initializing boss %s w/ HP %s, img %s",
      bigBoss.name,
      bigBoss.hp,
      bigBoss.imageURI
    );

    // Loop through all the sapiens, and save their values in our contract so
    // we can use them later when we mint our NFTs.
    for (uint256 i = 0; i < sapienNames.length; i++) {
      defaultSapiens.push(
        SapienAttributes({
          sapienIndex: i,
          name: sapienNames[i],
          class: classes[i],
          imageURI: sapienImageURIs[i],
          hp: sapienHp[i],
          maxHp: sapienHp[i],
          attackDamage: sapienAttackDmg[i]
        })
      );

      SapienAttributes memory c = defaultSapiens[i];
      console.log("\nInitializing Sapien\nName: %s\nType: %s", c.name, c.class);
      console.log(
        "HP: %s\nAttack Damage: %s\nImage: %s\n",
        c.hp,
        c.attackDamage,
        c.imageURI
      );
    }

    // increment tokenIds
    _tokenIds.increment();
  }

  // Users would be able to hit this function and get their NFT based on the
  // sapienId they send in!
  function mintSapienNFT(uint256 _sapienIndex) external {
    // Get current tokenId (starts at 1 since we incremented in the constructor).
    uint256 newItemId = _tokenIds.current();

    // The magical function! Assigns the tokenId to the caller's wallet address.
    _safeMint(msg.sender, newItemId);

    // We map the tokenId => their sapien attributes. More on this in
    // the lesson below.
    nftHolderAttributes[newItemId] = SapienAttributes({
      sapienIndex: _sapienIndex,
      name: defaultSapiens[_sapienIndex].name,
      class: defaultSapiens[_sapienIndex].class,
      imageURI: defaultSapiens[_sapienIndex].imageURI,
      hp: defaultSapiens[_sapienIndex].hp,
      maxHp: defaultSapiens[_sapienIndex].hp,
      attackDamage: defaultSapiens[_sapienIndex].attackDamage
    });

    console.log(
      "Minted Sapien NFT \nID: #%s\nIndex: %s",
      newItemId,
      _sapienIndex
    );

    // Keep an easy way to see who owns what NFT.
    nftHolders[msg.sender] = newItemId;

    // Increment the tokenId for the next person that uses it.
    _tokenIds.increment();

    // Emit mint event.
    emit SapienNFTMinted(msg.sender, newItemId, _sapienIndex);
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    override
    returns (string memory)
  {
    SapienAttributes memory sapienAttributes = nftHolderAttributes[_tokenId];

    string memory strHp = Strings.toString(sapienAttributes.hp);
    string memory strMaxHp = Strings.toString(sapienAttributes.maxHp);
    string memory strAttackDamage = Strings.toString(
      sapienAttributes.attackDamage
    );

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            sapienAttributes.name,
            " #",
            Strings.toString(_tokenId),
            '", "description": "This is a MetaSapiens NFT character!", "image": "',
            sapienAttributes.imageURI,
            '", "attributes": [ { "trait_type": "Class", "value": "',
            sapienAttributes.class,
            '"}, { "trait_type": "Health Points", "value": ',
            strHp,
            ', "max_value":',
            strMaxHp,
            '}, { "trait_type": "Attack Damage", "value": ',
            strAttackDamage,
            "} ]}"
          )
        )
      )
    );

    string memory output = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    return output;
  }

  function attackBoss() public {
    // Get the state of the player's NFT.
    uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
    SapienAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];

    console.log(
      "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
      player.name,
      player.hp,
      player.attackDamage
    );
    console.log(
      "Boss %s has %s HP and %s AD",
      bigBoss.name,
      bigBoss.hp,
      bigBoss.attackDamage
    );

    // Make sure the player has more than 0 HP.
    require(player.hp > 0, "Error: character must have HP to attack boss.");

    // Make sure the boss has more than 0 HP.
    require(bigBoss.hp > 0, "Error: boss must have HP to attack boss.");

    // Allow player to attack boss.
    if (bigBoss.hp < player.attackDamage) {
      bigBoss.hp = 0;
    } else {
      bigBoss.hp = bigBoss.hp - player.attackDamage;
    }

    // Allow boss to attack player.
    if (player.hp < bigBoss.attackDamage) {
      player.hp = 0;
    } else {
      player.hp = player.hp - bigBoss.attackDamage;
    }

    // Console for ease.
    console.log("Boss attacked player. New player hp: %s\n", player.hp);

    // Emit attack event.
    emit AttackComplete(bigBoss.hp, player.hp);
  }

  function checkIfUserHasNFT() public view returns (SapienAttributes memory) {
    // Get the tokenId of the user's character NFT
    uint256 userNftTokenId = nftHolders[msg.sender];
    // If the user has a tokenId in the map, return thier character.
    if (userNftTokenId > 0) {
      return nftHolderAttributes[userNftTokenId];
    }
    // Else, return an empty character.
    else {
      SapienAttributes memory emptyStruct;
      return emptyStruct;
    }
  }

  function getAllDefaultSapiens()
    public
    view
    returns (SapienAttributes[] memory)
  {
    return defaultSapiens;
  }

  function getBigBoss() public view returns (BigBoss memory) {
    return bigBoss;
  }
}
