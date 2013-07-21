_ = require 'lodash'

# Driven by revenue, and then #impressions

module.exports =
  name: __filename

  preOptimization: (context) ->
    context.campaigns = _.sortBy context.campaigns, (campaign) ->
      -(campaign.revenue / campaign.impressions)

  isBetter: (context, solution, combination) ->
    noOverdraft = combination.totalImpressions < context.availableImpressions
    return false  unless noOverdraft
    diffRevenue = combination.totalRevenue - solution.totalRevenue
    maximizeRevenue = diffRevenue > 0
    return maximizeRevenue  if maximizeRevenue
    tryMaximizeImpressions = diffRevenue is 0
    return tryMaximizeImpressions  unless tryMaximizeImpressions
    maximizeImpressions = combination.totalImpressions > solution.totalImpressions
    maximizeImpressions
