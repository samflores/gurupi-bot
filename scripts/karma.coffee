class KarmaCounter
  constructor: (robot) ->
    @brain = robot.brain

  karma_key: (username) ->
    "*#{username}-karma*"

  karma_for: (username) -> 
    karma = @brain.get(@karma_key(username)) 
    if !karma or !karma.hasOwnProperty('total') or !karma.hasOwnProperty('good') or !karma.hasOwnProperty('bad')
      karma = { total: 0, good: {}, bad: {} }
    karma

  set_karma_for: (username, value) -> 
    @brain.set @karma_key(username), value

  plural: (count) ->
    if count != 1 then 's' else ''

  add_karma: (kind, username, reason) ->
    reason = (reason || 'for no reason').trim()
    user_karma = @karma_for(username)
    user_karma.total += if kind == 'good' then 1 else -1
    user_karma[kind][reason] ||= 0
    user_karma[kind][reason] += 1
    @set_karma_for username, user_karma
    "@#{username} #{if kind == 'good' then 'got' else 'lost'} one karma point #{reason}"
    
  summary_for: (username) ->
    count = @karma_for(username).total
    "@#{username} has #{count} karma point#{@plural(count)}"
    
  points_by_reason_msg: (count, reason) ->
    "  * #{count} karma point#{@plural(count)} #{reason}\n"
    
  section_header: (username, kind) ->
    "#{if kind == 'good' then 'got' else 'lost'}:\n"
    
  partial_report: (username, kind, karma) ->
    message = ''
    for reason, count of karma
      message += @points_by_reason_msg(count, reason)
    message = @section_header(username, kind) + message unless message == ''
    message
    
  report_for: (username) ->
    user_karma = @karma_for(username)
    return "@#{username} has no karma" if user_karma.total == undefined
    message = """
    #{@summary_for(username)}
    #{@partial_report(username, 'good', user_karma.good)}
    #{@partial_report(username, 'bad', user_karma.bad)}
    """
    message.trim()

module.exports = (robot) ->
  robot.hear /\@([^-+ ]+)\+\+(.*)*/, (res) ->
    res.send new KarmaCounter(robot).add_karma('good', res.match[1], res.match[2])

  robot.hear /\@([^-+ ]+)\-\-(.*)*/, (res) ->
    res.send new KarmaCounter(robot).add_karma('bad', res.match[1], res.match[2])

  robot.hear /^!karma @([^-+ ]+)[^\w\d]*/, (res) ->
    res.send new KarmaCounter(robot).summary_for(res.match[1])

  robot.hear /^!!karma @([^-+ ]+)[^\w\d]*/, (res) ->
    res.send new KarmaCounter(robot).report_for(res.match[1])