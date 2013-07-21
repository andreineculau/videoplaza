_ = require 'lodash'

# Dynamic programming solution
# Will probably perform fastest out of the 3 on large number of campaigns
# but it maybe not be optimal depending on the goal
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
  {
    availableImpressions
    campaigns
  } = context

  for campaign in campaigns
    continue  unless availableImpressions - campaign.impressions > 0
    combination.totalImpressions += campaign.impressions
    combination.totalRevenue += campaign.revenue
    combination.campaigns.push campaign

    newContext = {
      availableImpressions: availableImpressions - campaign.impressions
      campaigns
    }
    subSolution = module.exports {context: newContext, goal}

    combination.totalImpressions += subSolution.totalImpressions
    combination.totalRevenue += subSolution.totalRevenue
    combination.campaigns = combination.campaigns.concat subSolution.campaigns

    if goal.isBetter context, solution, combination
      solution = _.cloneDeep combination
      canExit = goal.canExit context, solution  if goal.canExit?
      return  if canExit
  solution

module.exports = _.memoize module.exports
