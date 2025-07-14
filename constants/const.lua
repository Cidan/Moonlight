local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class const
local const = moonlight:NewClass("const")

const.BANK_BAGS = {
  [Enum.BagIndex.Bank] = Enum.BagIndex.Bank,
  [Enum.BagIndex.BankBag_1] = Enum.BagIndex.BankBag_1,
  [Enum.BagIndex.BankBag_2] = Enum.BagIndex.BankBag_2,
  [Enum.BagIndex.BankBag_3] = Enum.BagIndex.BankBag_3,
  [Enum.BagIndex.BankBag_4] = Enum.BagIndex.BankBag_4,
  [Enum.BagIndex.BankBag_5] = Enum.BagIndex.BankBag_5,
  [Enum.BagIndex.BankBag_6] = Enum.BagIndex.BankBag_6,
  [Enum.BagIndex.BankBag_7] = Enum.BagIndex.BankBag_7,
}

const.BANK_ONLY_BAGS = {
  [Enum.BagIndex.BankBag_1] = Enum.BagIndex.BankBag_1,
  [Enum.BagIndex.BankBag_2] = Enum.BagIndex.BankBag_2,
  [Enum.BagIndex.BankBag_3] = Enum.BagIndex.BankBag_3,
  [Enum.BagIndex.BankBag_4] = Enum.BagIndex.BankBag_4,
  [Enum.BagIndex.BankBag_5] = Enum.BagIndex.BankBag_5,
  [Enum.BagIndex.BankBag_6] = Enum.BagIndex.BankBag_6,
  [Enum.BagIndex.BankBag_7] = Enum.BagIndex.BankBag_7,
}

const.BANK_ONLY_BAGS_LIST = {
  Enum.BagIndex.BankBag_1,
  Enum.BagIndex.BankBag_2,
  Enum.BagIndex.BankBag_3,
  Enum.BagIndex.BankBag_4,
  Enum.BagIndex.BankBag_5,
  Enum.BagIndex.BankBag_6,
  Enum.BagIndex.BankBag_7,
}

const.REAGENTBANK_BAGS = {
  [Enum.BagIndex.Reagentbank] = Enum.BagIndex.Reagentbank,
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