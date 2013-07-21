_ = require 'lodash'

# Driven by #unique campaigns, and then revenue

module.exports =
  name: __filename

  preOptimization: (context) ->
    context.campaigns = _.sortBy context.campaigns, 'impressions'

  isBetter: (context, solution, combination) ->
    noOverdraft = combination.totalImpressions < context.availableImpressions
    return false  unless noOverdraft
    combinationTotalUniqueCampaigns = _.uniq(_.pluck(combination.campaigns, 'id')).length
    solutionTotalUniqueCampaigns = _.uniq(_.pluck(solution.campaigns, 'id')).length
    diffUniqueCampaigns = combinationTotalUniqueCampaigns - solutionTotalUniqueCampaigns
    maximizeUniqueCampaigns = diffUniqueCampaigns > 0
    return maximizeUniqueCampaigns  if maximizeUniqueCampaigns
    tryMaximizeRevenue = diffUniqueCampaigns is 0
    return tryMaximizeRevenue  unless tryMaximizeRevenue
    maximizeRevenue = combination.totalRevenue > solution.totalRevenue
    maximizeRevenue

  canExit: (context, solution) ->
    maximizeImpressions = solution.totalImpressions is context.availableImpressions
    return maximizeImpressions  unless maximizeImpressions
    solutionTotalUniqueCampaigns = _.uniq(_.pluck(solution.campaigns, 'id')).length
    maximizeUniqueCampaigns = solutionTotalUniqueCampaigns is context.campaigns.length
    maximizeUniqueCampaigns
