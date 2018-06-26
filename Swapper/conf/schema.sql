/*
 * SQL table defs
 */


CREATE TABLE px_invest_eth (
  `action` ENUM ('txlist', 'txlistinternal') DEFAULT 'txlist',
  `address` VARCHAR(64) NOT NULL,   -- Format likes: 0x74097c8c64decF0A7E99D99f85f3F6Bd021C35bf
  `timeStamp` datetime NOT NULL,
  `hash` VARCHAR(128) NOT NULL,     -- Tnx hash
  `blockNumber` INTEGER NOT NULL,
  `from` VARCHAR(64) NOT NULL,  
  `to` VARCHAR(64) NOT NULL,  
  `value` VARCHAR(64) NOT NULL,      -- Not null if tnx contains ethers
  `confirmations` INTEGER NOT NULL,  -- Need updates ? 

  `input` MediumText,
  PRIMARY KEY (`hash`),
  KEY(`timeStamp`)
  KEY(`from`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;