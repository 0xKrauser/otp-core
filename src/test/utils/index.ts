import { BigNumberish } from 'ethers'
import { ethers } from 'hardhat'

export * from './constants'
// export * from "./helpers";
// export * from "./timeUtils";
export * from './unitUtils'
export * from './diceUtils'

export const parseUnits = function (number: string, units?: BigNumberish) {
  return ethers.utils.parseUnits(number, units || 18)
}
