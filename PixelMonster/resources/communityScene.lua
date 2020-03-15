-- Create our scene
local scene = director:createScene()

-- Scoreloop handler
local function scoreloopHandler(event)
  -- Handle the user result submission
  if event.phase == "userResultSubmit" then
    if event.success == false then
      scene:updateState("Failed", true)
    else
      scene:updateState("Refreshing", false)
    end
  -- Handle the user rank request
  elseif event.phase == "userRankRequest" then
    if event.success == true then
      if event.player ~= nil and event.player ~= "" then
        scene.user = event.player
      end
      scene:updateState("Success", true, true,
        event.result, event.minorResult, event.level, event.rank)
    else
      scene:updateState("Failed", true)
    end
  end
end

-- Setup resources
function scene:setUp(event)
  dbg.print("communityScene - scene:setUp")
  -- Initialize or use the current values
  self.score = self.score or 0
  self.time = self.time or 0
  self.level = self.level or 0
  self.rank = self.rank or 0
  self.user = self.user or "USERNAME"
  
  -- Create the grass background sprite
  self.backgroundSprite = director:createSprite({
    x = 0,
    y = 0,
    source = Resources.Animations.BackgroundCommunity})
  
  -- Create the exit sprite
  self.exitSprite = director:createLabel({
    hAlignment="center",
    font=Resources.Fonts.HomeWhite,
    color=Resources.Colors.Blue,
    text="BACK"})
  self.exitSprite.y = 25
  createBackSprite(false, Resources.Scenes.Main, nil, self.exitSprite)
  
  -- Create the user label
  self.userLabel = director:createLabel({
      hAlignment="center",
      y = 210,
      font=Resources.Fonts.HomeWhite,
      color=Resources.Colors.Blue,
      text=self.user
    })
  
  -- Create the current game labels
  self.currentGameLabel = director:createLabel({
      hAlignment="center",
      y = 175,
      font=Resources.Fonts.HomeWhite,
      text="LEADERBOARD GAME"
    })
  self.currentScoreLabel = director:createLabel({
      x = 75,
      y = self.currentGameLabel.y - self.currentGameLabel.hText - 10,
      font=Resources.Fonts.HomeWhite,
      color=color.black,
      text="SCORE: "
    })
  self.currentScoreStateLabel = director:createLabel({
      x = self.currentScoreLabel.x + self.currentScoreLabel.wText,
      y = self.currentGameLabel.y - self.currentGameLabel.hText - 10,
      font=Resources.Fonts.HomeWhite,
      text=self.score
    })
  self.currentTimeLabel = director:createLabel({
      x = self.currentScoreLabel.xText,
      y = self.currentScoreLabel.y - self.currentScoreLabel.hText,
      font=Resources.Fonts.HomeWhite,
      color=color.black,
      text="TIME: "
    })
  self.currentTimeStateLabel = director:createLabel({
      x = self.currentTimeLabel.x + self.currentTimeLabel.wText,
      y = self.currentScoreLabel.y - self.currentScoreLabel.hText,
      font=Resources.Fonts.HomeWhite,
      text=self.time
    })
  self.currentLevelLabel = director:createLabel({
      x = 280,
      y = self.currentScoreLabel.y,
      font=Resources.Fonts.HomeWhite,
      color=color.black,
      text="LEVEL: "
    })
  self.currentLevelStateLabel = director:createLabel({
      x = self.currentLevelLabel.x + self.currentLevelLabel.wText,
      y = self.currentLevelLabel.y,
      font=Resources.Fonts.HomeWhite,
      text=self.level
    })
  self.currentRankLabel = director:createLabel({
      x = self.currentLevelLabel.xText,
      y = self.currentLevelLabel.y - self.currentLevelLabel.hText,
      font=Resources.Fonts.HomeWhite,
      color=color.black,
      text="RANK: "
    })
  self.currentRankStateLabel = director:createLabel({
      x = self.currentRankLabel.x + self.currentRankLabel.wText,
      y = self.currentRankLabel.y,
      font=Resources.Fonts.HomeWhite,
      text=self.rank
    })
  
  -- Create the submit label
  self.submitLabel = director:createLabel({
      x = 235,
      y = 55,
      font=Resources.Fonts.HomeWhite,
      text="SUBMIT"
    })
  function self.submitLabel:blinkNotify(event)
    if event.phase == "ended" then
      scene:updateState("Submitting", false)
      scores:submit(
        Resources.UserData.TopScore,
        Resources.UserData.TopTime,
        Resources.UserData.TopLevel)
    end
  end
  initButton(self.submitLabel, false)
  
  -- Create the leaders label
  self.leadersLabel = director:createLabel({
      x = 35,
      y = self.submitLabel.y,
      font=Resources.Fonts.HomeWhite,
      text="LEADERBOARD",
    })
  function self.leadersLabel:blinkNotify(event)
    if event.phase == "ended" then
      moveToGameScene(Resources.Scenes.Leadboard)
    end
  end
  initButton(self.leadersLabel, true, true)
  
  -- Create the refresh label
  self.refreshLabel = director:createLabel({
      x = 345,
      y = self.submitLabel.y,
      font=Resources.Fonts.HomeWhite,
      text="REFRESH"
    })
  function self.refreshLabel:blinkNotify(event)
    if event.phase == "ended" then
      scene:updateState("Refreshing", false)
      scores:refresh()
    end
  end
  initButton(self.refreshLabel, false)
  
  -- Create the scoreloop sprite
  self.scoreloopSprite = createScoreloopSprite()
  self.scoreloopSprite.y = self.exitSprite.y + (self.exitSprite.hText/2) - (self.scoreloopSprite.h/2)
  self.scoreloopSprite.x = director.displayWidth - self.scoreloopSprite.w - 35
  
  -- Create the status label
  self.statusLabel = director:createLabel({
      hAlignment="center",
      vAlignment="bottom",
      font=Resources.Fonts.Medium,
      text="Refreshing",
      alpha = 0
    })
  
  -- Update the state
  self:updateState("Refreshing")
  
  -- Hook into scoreloop and refresh
  system:addEventListener("scoreloop", scoreloopHandler)
  
  -- Update our state based on what
  -- is currently going on in the scores
  if scores.submitting == true then
    scene:updateState("Submitting", false)
  else
    scene:updateState("Refreshing", false)
    if scores.refreshing == false then
      scores:refresh()
    end
  end
  
  dbg.print("communityScene - scene:setUp - complete")
end

-- Update scene state
function scene:updateState(message, enable, update, score, time, level, rank)
  enable = enable or false
  update = update or false
  self.statusLabel.text = message
  
  if update == true then
    self:updateScores(score, time, level, rank)
  end
  
  if enable == true then
    self.refreshLabel.alpha = 1
    self.refreshLabel.isTouchable = true
  else
    self.refreshLabel.alpha = 0.5
    self.refreshLabel.isTouchable = false
  end
  
  -- Here we are checking if the community score is
  -- still a top score... if this returns true then
  -- the community score is higher than the local
  -- top score, so we do not want to enable this.
  local enableSubmit = isTopScore(self.score, self.time, self.level) == false
  
  if enableSubmit == true and enable == true then
    self.submitLabel.alpha = 1
    self.submitLabel.isTouchable = true
  else
    self.submitLabel.alpha = 0.5
    self.submitLabel.isTouchable = false
  end
end

-- Update the scores with scoreloop data
function scene:updateScores(score, time, level, rank)
  self.score = score or self.score
  self.time = time or self.time
  self.level = level or self.level
  self.rank = rank or self.rank
  self.userLabel.text = self.user
  self.currentScoreStateLabel.text = self.score
  self.currentTimeStateLabel.text = self.time
  self.currentLevelStateLabel.text = self.level
  self.currentRankStateLabel.text = self.rank
end

-- Create the tear down scene event that
-- we will use to cleanup our scenese resources
function scene:tearDown(event)
  dbg.print("communityScene - scene:tearDown")
  
  -- Cancel open scoreloop requests
  scores:cancel()
  
  -- Clear out the globals created by this scene
  system:removeEventListener("scoreloop", scoreloopHandler)
  self.backgroundSprite = tearDownSprite(self.backgroundSprite)
  self.submitLabel = tearDownSprite(self.submitLabel)
  self.refreshLabel = tearDownSprite(self.refreshLabel)
  self.statusLabel = tearDownSprite(self.statusLabel)
  self.leadersLabel = tearDownSprite(self.leadersLabel)
  self.userLabel = tearDownSprite(self.userLabel)
  self.currentGameLabel = tearDownSprite(self.currentGameLabel)
  self.currentScoreLabel = tearDownSprite(self.currentScoreLabel)
  self.currentScoreStateLabel = tearDownSprite(self.currentScoreStateLabel)
  self.currentTimeLabel = tearDownSprite(self.currentTimeLabel)
  self.currentTimeStateLabel = tearDownSprite(self.currentTimeStateLabel)
  self.currentLevelLabel = tearDownSprite(self.currentLevelLabel)
  self.currentLevelStateLabel = tearDownSprite(self.currentLevelStateLabel)
  self.currentRankLabel = tearDownSprite(self.currentRankLabel)
  self.currentRankStateLabel = tearDownSprite(self.currentRankStateLabel)
  self.exitSprite = tearDownBackSprite(self.exitSprite)
  self.scoreloopSprite = tearDownBackSprite(self.scoreloopSprite)
  self:releaseResources()
  dbg.print("communityScene - scene:tearDown - complete")
end

-- Pretransition event
function scene:exitPreTransition(event)
end

-- Post enter transition
function scene:enterPostTransition(event)
end

-- Add setup and teardown event handlers
scene:addEventListener({"setUp", "tearDown", "exitPreTransition", "enterPostTransition"}, scene)

-- Return the scene we created
return scene
