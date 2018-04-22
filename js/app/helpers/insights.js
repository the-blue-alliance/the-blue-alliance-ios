import { round } from './number';

export const highScoreString = (highScoreData) => {
  if (highScoreData.length != 3) {
    return highScoreData.join(' ')
  }
  return highScoreData[0] + ' in ' + highScoreData[2]
}

export const bonusStat = (bonusData) => {
  if (bonusData.length != 3) {
    return bonusData.join(' / ')
  }
  return bonusData[0] + ' / ' + bonusData[1] + ' = ' + round(bonusData[2]) + '%'
}
