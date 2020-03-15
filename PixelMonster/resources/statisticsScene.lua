-- Create our scene
local scene = director:createScene()

-- Setup resources
function scene:setUp(event)
  dbg.print("statisticsScene - scene:setUp")
  
  -- Create the grass background sprite
  self.backgroundSprite = director:createSprite({
    x = 0,
    y = 0,
    source = Resources.Animations.BackgroundScores})
  
  -- Create the title labels
  self.topGameLabel = director:createLabel({
    font=Resources.Fonts.HomeWhite,
    text="TOP GAME"})
  self.topGameLabel.x = 70
  self.topGameLabel.y = 185
  self.lastGameLabel = director:createLabel({
    font=Resources.Fonts.HomeWhite,
    text="LAST GAME"})
  self.lastGameLabel.x = 275
  self.lastGameLabel.y = self.topGameLabel.y
  
  local textGap = 5
  
  -- Create top game stats
  self.topGameScoreLabel = director:createLabel({
    x = self.topGameLabel.x,
    y = self.topGameLabel.y - 40,
    font=Resources.Fonts.HomeWhite,
    color=color.black,
    text="SCORE: "})
  self.topGameScoreStateLabel = director:createLabel({
    x = self.topGameScoreLabel.x + self.topGameScoreLabel.wText,
    y = self.topGameScoreLabel.y,
    font=Resources.Fonts.HomeWhite,
    text=Resources.UserData.TopScore})
  self.topGameTimeLabel = director:createLabel({
    x = self.topGameScoreLabel.x,
    y = self.topGameScoreLabel.y - self.topGameScoreLabel.hText - textGap,
    font=Resources.Fonts.HomeWhite,
    color=color.black,
    text="TIME: "})
  self.topGameTimeStateLabel = director:createLabel({
    x = self.topGameTimeLabel.x + self.topGameTimeLabel.wText,
    y = self.topGameTimeLabel.y,
    font=Resources.Fonts.HomeWhite,
    text=Resources.UserData.TopTime})
  self.topGameLevelLabel = director:createLabel({
    x = self.topGameTimeLabel.x,
    y = self.topGameTimeLabel.y - self.topGameTimeLabel.hText - textGap,
    font=Resources.Fonts.HomeWhite,
    color=color.black,
    text="LEVEL: "})
  self.topGameLevelStateLabel = director:createLabel({
    x = self.topGameLevelLabel.x + self.topGameLevelLabel.wText,
    y = self.topGameLevelLabel.y,
    font=Resources.Fonts.HomeWhite,
    text=Resources.UserData.TopLevel})

  -- Create last game stats
  self.lastGameScoreLabel = director:createLabel({
    x = self.lastGameLabel.x,
    y = self.lastGameLabel.y - 40,
    font=Resources.Fonts.HomeWhite,
    color=color.black,
    text="SCORE: "})
  self.lastGameScoreStateLabel = director:createLabel({
    x = self.lastGameScoreLabel.x + self.lastGameScoreLabel.wText,
    y = self.lastGameScoreLabel.y,
    font=Resources.Fonts.HomeWhite,
    text=Resources.UserData.LastScore})
  self.lastGameTimeLabel = director:createLabel({
    x = self.lastGameScoreLabel.x,
    y = self.lastGameScoreLabel.y - self.lastGameScoreLabel.hText - textGap,
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
    y = self.lastGameTimeLabel.y - self.lastGameTimeLabel.hText - textGap,
    font=Resources.Fonts.HomeWhite,
    color=color.black,
    text="LEVEL: "})
  self.lastGameLevelStateLabel = director:createLabel({
    x = self.lastGameLevelLabel.x + self.lastGameLevelLabel.wText,
    y = self.lastGameLevelLabel.y,
    font=Resources.Fonts.HomeWhite,
    text=Resources.UserData.LastLevel})

  -- Create the exit sprite
  self.exitSprite = director:createLabel({
    hAlignment="center",
    font=Resources.Fonts.HomeWhite,
    color=Resources.Colors.Blue,
    text="BACK"})
  self.exitSprite.y = 30
  createBackSprite(false, Resources.Scenes.Main, nil, self.exitSprite)
  
  dbg.print("statisticsScene - scene:setUp - complete")
end

-- Create the tear down scene event that
-- we will use to cleanup our scenese resources
function scene:tearDown(event)
  dbg.print("statisticsScene - scene:tearDown")
  
  -- Clear out the globals created by this scene
  self.backgroundSprite = tearDownSprite(self.backgroundSprite)
  self.exitSprite = tearDownBackSprite(self.exitSprite)
  self.topGameLabel = tearDownBackSprite(self.topGameLabel)
  self.lastGameLabel = tearDownBackSprite(self.lastGameLabel)
  self.topGameScoreLabel = tearDownBackSprite(self.topGameScoreLabel)
  self.topGameScoreStateLabel = tearDownBackSprite(self.topGameScoreStateLabel)
  self.topGameTimeLabel = tearDownBackSprite(self.topGameTimeLabel)
  self.topGameTimeStateLabel = tearDownBackSprite(self.topGameTimeStateLabel)
  self.topGameLevelLabel = tearDownBackSprite(self.topGameLevelLabel)
  self.topGameLevelStateLabel = tearDownBackSprite(self.topGameLevelStateLabel)
  self.lastGameScoreLabel = tearDownBackSprite(self.lastGameScoreLabel)
  self.lastGameScoreStateLabel = tearDownBackSprite(self.lastGameScoreStateLabel)
  self.lastGameTimeLabel = tearDownBackSprite(self.lastGameTimeLabel)
  self.lastGameTimeStateLabel = tearDownBackSprite(self.lastGameTimeStateLabel)
  self.lastGameLevelLabel = tearDownBackSprite(self.lastGameLevelLabel)
  self.lastGameLevelStateLabel = tearDownBackSprite(self.lastGameLevelStateLabel)
  self:releaseResources()
  dbg.print("statisticsScene - scene:tearDown - complete")
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
