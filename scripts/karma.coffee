module.exports = (robot) ->
  robot.hear /\@([^-+ ]+)\+\+[^\w\d]*/, (res) ->
    username = res.match[1]
    karma_key = "*#{username}-karma*"
    user_karma = robot.brain.get(karma_key) * 1 or 0
    user_karma += 1
    res.send "@#{username} got one karma point"
    robot.brain.set karma_key, user_karma
  
  robot.hear /\@([^-+ ]+)\-\-[^\w\d]*/, (res) ->
    username = res.match[1]
    karma_key = "*#{username}-karma*"
    user_karma = robot.brain.get(karma_key) * 1 or 0
    user_karma -= 1
    res.send "@#{username} lost one karma point"
    robot.brain.set karma_key, user_karma

  robot.hear /!karma @([^-+ ]+)[^\w\d]*/, (res) ->
    username = res.match[1]
    karma_key = "*#{username}-karma*"
    user_karma = robot.brain.get(karma_key) * 1 or 0
    res.send "@#{username} has #{user_karma} karma points"
