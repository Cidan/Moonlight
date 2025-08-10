local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class const
local const = moonlight:NewClass("const")

const.BANK_BAGS = {
  [Enum.BagIndex.Characterbanktab] = Enum.BagIndex.Characterbanktab,
  [Enum.BagIndex.CharacterBankTab_1] = Enum.BagIndex.CharacterBankTab_1,
  [Enum.BagIndex.CharacterBankTab_2] = Enum.BagIndex.CharacterBankTab_2,
  [Enum.BagIndex.CharacterBankTab_3] = Enum.BagIndex.CharacterBankTab_3,
  [Enum.BagIndex.CharacterBankTab_4] = Enum.BagIndex.CharacterBankTab_4,
  [Enum.BagIndex.CharacterBankTab_5] = Enum.BagIndex.CharacterBankTab_5,
  [Enum.BagIndex.CharacterBankTab_6] = Enum.BagIndex.CharacterBankTab_6,
}

const.BANK_ONLY_BAGS = {
  [Enum.BagIndex.CharacterBankTab_1] = Enum.BagIndex.CharacterBankTab_1,
  [Enum.BagIndex.CharacterBankTab_2] = Enum.BagIndex.CharacterBankTab_2,
  [Enum.BagIndex.CharacterBankTab_3] = Enum.BagIndex.CharacterBankTab_3,
  [Enum.BagIndex.CharacterBankTab_4] = Enum.BagIndex.CharacterBankTab_4,
  [Enum.BagIndex.CharacterBankTab_5] = Enum.BagIndex.CharacterBankTab_5,
  [Enum.BagIndex.CharacterBankTab_6] = Enum.BagIndex.CharacterBankTab_6,
}

const.BANK_ONLY_BAGS_LIST = {
  Enum.BagIndex.CharacterBankTab_1,
  Enum.BagIndex.CharacterBankTab_2,
  Enum.BagIndex.CharacterBankTab_3,
  Enum.BagIndex.CharacterBankTab_4,
  Enum.BagIndex.CharacterBankTab_5,
  Enum.BagIndex.CharacterBankTab_6,
}

const.ACCOUNT_BANK_BAGS = {
  [Enum.BagIndex.AccountBankTab_1] = Enum.BagIndex.AccountBankTab_1,
  [Enum.BagIndex.AccountBankTab_2] = Enum.BagIndex.AccountBankTab_2,
  [Enum.BagIndex.AccountBankTab_3] = Enum.BagIndex.AccountBankTab_3,
  [Enum.BagIndex.AccountBankTab_4] = Enum.BagIndex.AccountBankTab_4,
  [Enum.BagIndex.AccountBankTab_5] = Enum.BagIndex.AccountBankTab_5,
}

const.BACKPACK_BAGS = {
  [Enum.BagIndex.Backpack] = Enum.BagIndex.Backpack,
  [Enum.BagIndex.Bag_1] = Enum.BagIndex.Bag_1,
  [Enum.BagIndex.Bag_2] = Enum.BagIndex.Bag_2,
  [Enum.BagIndex.Bag_3] = Enum.BagIndex.Bag_3,
  [Enum.BagIndex.Bag_4] = Enum.BagIndex.Bag_4,
  [Enum.BagIndex.ReagentBag] = Enum.BagIndex.ReagentBag,
}

const.BACKPACK_ONLY_BAGS = {
  [Enum.BagIndex.Bag_1] = Enum.BagIndex.Bag_1,
  [Enum.BagIndex.Bag_2] = Enum.BagIndex.Bag_2,
  [Enum.BagIndex.Bag_3] = Enum.BagIndex.Bag_3,
  [Enum.BagIndex.Bag_4] = Enum.BagIndex.Bag_4,
  [Enum.BagIndex.ReagentBag] = Enum.BagIndex.ReagentBag,
}

const.BACKPACK_ONLY_BAGS_LIST = {
  Enum.BagIndex.Bag_1,
  Enum.BagIndex.Bag_2,
  Enum.BagIndex.Bag_3,
  Enum.BagIndex.Bag_4,
  Enum.BagIndex.ReagentBag,
}

const.BACKPACK_ONLY_REAGENT_BAGS = {
  [Enum.BagIndex.ReagentBag] = Enum.BagIndex.ReagentBag,
}

---@type table<Enum.PlayerInteractionType, boolean>
const.EVENTS_THAT_OPEN_BACKPACK = {
  [Enum.PlayerInteractionType.TradePartner] = true,
  [Enum.PlayerInteractionType.Banker] = true,
  [Enum.PlayerInteractionType.Merchant] = true,
  [Enum.PlayerInteractionType.MailInfo] = true,
  [Enum.PlayerInteractionType.Auctioneer] = true,
  [Enum.PlayerInteractionType.GuildBanker] = true,
  [Enum.PlayerInteractionType.VoidStorageBanker] = true,
  [Enum.PlayerInteractionType.ScrappingMachine] = true,
  [Enum.PlayerInteractionType.ItemUpgrade] = true,
  [Enum.PlayerInteractionType.AccountBanker] = true
}

---@enum BindingScope  -- similar. but distinct from ItemBind
const.BINDING_SCOPE = {
  UNKNOWN = -1,
  NONBINDING = 0,
  BOUND = 1,
  BOE = 2,
  BOU = 3,
  QUEST = 4,
  SOULBOUND = 5,
  REFUNDABLE = 6,
  ACCOUNT = 7,
  BNET = 8,
  WUE = 9,
}
