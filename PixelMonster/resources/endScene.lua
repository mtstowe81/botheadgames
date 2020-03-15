-- Create our scene
local scene = director:createScene()

-- Setup resources
function scene:setUp(event)
  dbg.print("endScene - scene:setUp")
  
  -- Create the grass background sprite
  self.backgroundSprite = director:createSprite({
    x = 0,
    y = 0,
    source = Resources.Animations.BackgroundHome})
  
  -- Create the dead pixel sprites
  self.deadPixel1Sprite = director:createSprite({
    x = 0,
    y = 0,
    source = Resources.Animations.Monster})
  if self.won then
    self.deadPixel1Sprite:setFrame(Resources.Frames.Monster.Normal)
  else
    self.deadPixel1Sprite:setFrame(Resources.Frames.Monster.Hurt)
  end
  self.deadPixel1Sprite.x = director.displayCenterX - 185
  self.deadPixel1Sprite.y = director.displayCenterY - self.deadPixel1Sprite.h/2
  
  self.deadPixel2Sprite = director:createSprite({
    x = 0,
    y = 0,
    source = Resources.Animations.Monster})
  if self.won then
    self.deadPixel2Sprite:setFrame(Resources.Frames.Monster.Normal)
  else
    self.deadPixel2Sprite:setFrame(Resources.Frames.Monster.Hurt)
  end
  self.deadPixel2Sprite.x = director.displayCenterX + 125
  self.deadPixel2Sprite.y = self.deadPixel1Sprite.y
  
  -- If this is a top score then update our stats
  local topScore = isTopScore(Resources.UserData.LastScore, Resources.UserData.LastTime, Resources.UserData.LastLevel)
  if topScore == true then
    Resources.UserData.TopScore = Resources.UserData.LastScore
    Resources.UserData.TopTime = Resources.UserData.LastTime
    Resources.UserData.TopLevel = Resources.UserData.LastLevel
    saveUserData()
  end
  
  -- Create the game over label
  local gameOverText = "YOU LOSE!"
  if self.won then
    gameOverText = "YOU WIN!"
  end
  self.gaveOverLabel = director:createLabel({
    hAlignment="center",
    y = 180,
    font=Resources.Fonts.HomeWhite,
    text=gameOverText})

  -- Create last game stats
  self.lastGameScoreLabel = director:createLabel({
    x = self.gaveOverLabel.xText + 20,
    y = self.gaveOverLabel.y - 40,
    font=Resources.Fonts.HomeWhite,
    color=color.black,
    text="SCORE: "})
  if topScore == true then
    self.lastGameScoreLabel.y = self.lastGameScoreLabel.y + 10
  end
  self.lastGameScoreStateLabel = director:createLabel({
    x = self.lastGameScoreLabel.x + self.lastGameScoreLabel.wText,
    y = self.lastGameScoreLabel.y,
    font=Resources.Fonts.HomeWhite,
    text=Resources.UserData.LastScore})
  self.lastGameTimeLabel = director:createLabel({
    x = self.lastGameScoreLabel.x,
    y = self.lastGameScoreLabel.y - self.lastGameScoreLabel.hText,
    font=Resources.Fonts.HomeWhite,
    color=color.black,
    text="TIME: "})
  self.lastGameTimeStateLabel = director:createLabel({
    x = self.lastGameTimeLabel.x + self.lastGameTimeLabel.wText,
    y = self.lastGameTimeLabel.y,
    font=Resources.Fonts.HomeWhite,
    text=Resources.UserData.LastTime})
  self.lastGameLevelLabel = director:createLabel({
    x = self.lastGameTimeLabel.x,
    y = self.lastGameTimeLabel.y - self.lastGameTimeLabel.hText,
    font=Resources.Fonts.HomeWhite,
    color=color.black,
    text="LEVEL: "})
  self.lastGameLevelStateLabel = director:createLabel({
    x = self.lastGameLevelLabel.x + self.lastGameLevelLabel.wText,
    y = self.lastGameLevelLabel.y,
    font=Resources.Fonts.HomeWhite,
    text=Resources.UserData.LastLevel})

  if topScore == true then
    self.topGameLabel = director:createLabel({
      hAlignment="center",
      y = self.lastGameLevelStateLabel.y - self.gaveOverLabel.hText,
      font=Resources.Fonts.HomeWhite,
      text="NEW TOP GAME"})
  end
  
  -- Create the exit sprite
  self.exitSprite = director:createLabel({
    hAlignment="center",
    font=Resources.Fonts.HomeWhite,
    color=Resources.Colors.Blue,
    text="BACK"})
  self.exitSprite.y = 30
  createBackSprite(false, Resources.Scenes.Main, nil, self.exitSprite)
  
  -- Auto submit the top score
  -- at the end of a game.
  if Resources.UserData.EnableAutoSubmit == true then
    scores:submit(
      Resources.UserData.TopScore,
      Resources.UserData.TopTime,
      Resources.UserData.TopLevel)
  end
  
  dbg.print("endScene - scene:setUp - complete")
end

-- Create the tear down scene event that
-- we will use to cleanup our scenese resources
function scene:tearDown(event)
  dbg.print("endScene - scene:tearDown")
  
  -- Cleanup all the timers on this scene
  tearDownTimers(self.timers)
  
  -- Clear out the globals created by this scene
  self.backgroundSprite = tearDownSprite(self.backgroundSprite)
  self.deadPixel1Sprite = tearDownSprite(self.deadPixel1Sprite)
  self.deadPixel2Sprite = tearDownSprite(self.deadPixel2Sprite)
  self.gaveOverLabel = tearDownSprite(self.gaveOverLabel)
  self.lastGameScoreLabel = tearDownSprite(self.lastGameScoreLabel)
  self.lastGameScoreStateLabel = tearDownSprite(self.lastGameScoreStateLabel)
  self.lastGameTimeLabel = tearDownSprite(self.lastGameTimeLabel)
  self.lastGameTimeStateLabel = tearDownSprite(self.lastGameTimeStateLabel)
  self.lastGameLevelLabel = tearDownSprite(self.lastGameLevelLabel)
  self.topGameLabel = tearDownSprite(self.topGameLabel)
  self.lastGameLevelStateLabel = tearDownSprite(self.lastGameLevelStateLabel)
  self.exitSprite = tearDownBackSprite(self.exitSprite)
  self:releaseResources()
  dbg.print("endScene - scene:tearDown - complete")
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
