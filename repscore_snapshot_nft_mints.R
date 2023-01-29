#' This query identifies Snapshot activity and NFT projects minted for specific
#' set of ~2,000 addresses for talentDAO's reputation score purposes.

# get your own API Key for free at: https://sdk.flipsidecrypto.xyz/shroomdk
api_key <- readLines("api_key.txt")

library(shroomDK)

# the 2,000 addresses csv
# grab only the the user_did and swap did:etho: for 0x to make them EVM addresses
addresses <- read.csv("DAO_Activity_Drop_campaign_id_16.csv", row.names = NULL)
addresses <- gsub("did:etho:", replacement = "0x", addresses$user_did, fixed = TRUE)

alist <- paste0(tolower(unique(addresses)), collapse = "','")


#Snapshot activity
snapshot_query <- {
  "
SELECT
voter,
proposal_id,
proposal_title,
voting_power,
space_id
FROM
ethereum.core.ez_snapshot
WHERE
ethereum.core.ez_snapshot.voter IN ('ADDRESSLIST') 
AND PROPOSAL_END_TIME <= '2023-01-28'
  "
}
# swap parameters
snapshot_query <- gsub('ADDRESSLIST', replacement = alist, x = snapshot_query)

snapshots <- shroomDK::auto_paginate_query(snapshot_query, api_key = api_key)
#NFT projects minted
nftmint_query <- {
"
SELECT
nft_address,
project_name,
nft_to_address,
mint_price_eth,
nft_count
FROM
ethereum.core.ez_nft_mints
WHERE
ethereum.core.ez_nft_mints.nft_to_address IN ('ADDRESSLIST') 
AND BLOCK_NUMBER <= 16515000
"
}


nftmint_query <- gsub('ADDRESSLIST', replacement = alist, x = nftmint_query)

nftmints <- shroomDK::auto_paginate_query(nftmint_query, api_key = api_key)

write.csv(snapshots, file = "votes_by_voter.csv", row.names = FALSE)
write.csv(nftmints, file = "nft_mints_by_TO_ADDRESS.csv", row.names = FALSE)
