_ = require 'lodash'

# Brute force solution (maximize unique campaigns; more adequate for goal2)
module.exports = ({context, goal}) ->
  canExit = false
  solution =
    campaigns: []
    totalImpressions: 0
    totalRevenue: 0
  combination =
    campaigns: []
    totalImpressions: 0
    totalRevenue: 0

  # Ignore impossible campaigns
  context.campaigns = _.reject context.campaigns, (campaign) ->
    campaign.impressions > context.availableImpressions
  goal.preOptimization context  if goal.preOptimization?

  fun = (availableImpressions, index = 0) ->
    campaign = context.campaigns[index]
    return  unless campaign?
    # No overdraft
    max = Math.floor availableImpressions / campaign.impressions
    max = 0  if max < 0
    for multiplier in [0..max]
      combination.totalImpressions += campaign.impressions * multiplier
      combination.totalRevenue += campaign.revenue * multiplier
      combination.campaigns.push campaign  for multi in [1..multiplier]  if multiplier
      if goal.isBetter context, solution, combination
        solution = _.cloneDeep combination
        canExit = goal.canExit context, solution  if goal.canExit?
        return  if canExit
      canExit = fun availableImpressions - combination.totalImpressions, index + 1
      return  if canExit
      combination.totalImpressions -= campaign.impressions * multiplier
      combination.totalRevenue -= campaign.revenue * multiplier
      combination.campaigns.pop()  for multi in [1..multiplier]  if multiplier
    canExit
  fun context.availableImpressions
  solution
