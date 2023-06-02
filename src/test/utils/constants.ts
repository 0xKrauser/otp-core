import { BigNumber } from '@ethersproject/bignumber'
import { constants } from 'ethers'

const { AddressZero, MaxUint256, One, Two, Zero } = constants

export const ADDRESS_ZERO = AddressZero
export const EMPTY_BYTES = '0x'
export const MAX_UINT_256 = MaxUint256
export const ONE = One
export const TWO = Two
export const THREE = BigNumber.from(3)
export const ZERO = Zero
export const MAX_INT_256 = '0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'
export const MIN_INT_256 = '-0x8000000000000000000000000000000000000000000000000000000000000000'
export const ONE_DAY_IN_SECONDS = BigNumber.from(60 * 60 * 24)
export const ONE_HOUR_IN_SECONDS = BigNumber.from(60 * 60)
export const ONE_WEEK_IN_SECONDS = BigNumber.from(60 * 60 * 24 * 7)
export const ONE_YEAR_IN_SECONDS = BigNumber.from(31557600)

export const PRECISE_UNIT = constants.WeiPerEther
export const ETH_ADDRESS = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE'
export const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000'

export enum Results {
  nopoint = 0,
  lose = 1,
  lose_two = 2,
  lose_three = 3,
  point_two = 4,
  point_three = 5,
  point_four = 6,
  point_five = 7,
  win = 8,
  win_two = 9,
  win_three = 10,
  matches_previous = 11,
  matches_next = 12,
}
