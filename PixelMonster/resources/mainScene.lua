-- Create our scene
local scene = director:createScene()

-- Setup resources
function scene:setUp(event)
  dbg.print("mainScene - scene:setUp")
  
  -- Create the grass background sprite
  self.backgroundSprite = director:createSprite({
    x = 0,
    y = 0,
    source = Resources.Animations.BackgroundHome})
  
  local textGap = 10
  
  -- Create the statisticss label
  self.statisticsLabel = director:createLabel({
    hAlignment="center",
    font=Resources.Fonts.HomeWhite,
    --color=color.black,
    text="SCORES"})
  self.statisticsLabel.y = director.displayHeight - 135
  function self.statisticsLabel:blinkNotify(event)
    if event.phase == "ended" then
      moveToGameScene(Resources.Scenes.Statistic)
    end
  end
  initButton(self.statisticsLabel, true, true)
  
--  -- Create the community label
--  self.communityLabel = director:createLabel({
--    hAlignment="center",
--    font=Resources.Fonts.HomeWhite,
--    text="COMMUNITY"})
--  self.communityLabel.y = self.statisticsLabel.y -  self.communityLabel.hText
--  function self.communityLabel:blinkNotify(event)
--    if event.phase == "ended" then
--      moveToGameScene(Resources.Scenes.Community)
--    end
--  end
--  initButton(self.communityLabel, true, true)
  
  -- Create the settings label
  self.settingsLabel = director:createLabel({
    hAlignment="center",
    font=Resources.Fonts.HomeWhite,
    color=color.black,
    text="SETTINGS"})
  self.settingsLabel.y = self.statisticsLabel.y - self.settingsLabel.hText - textGap
  function self.settingsLabel:blinkNotify(event)
    if event.phase == "ended" then
      moveToGameScene(Resources.Scenes.Setting)
    end
  end
  initButton(self.settingsLabel, true, true)
  
  -- Create the play label
  self.playLabel = director:createLabel({
    hAlignment="center",
    font=Resources.Fonts.HomeWhite,
    color=Resources.Colors.Blue,
    text="PLAY"})
  self.playLabel.y = self.settingsLabel.y - self.playLabel.hText - textGap
  function self.playLabel:blinkNotify(event)
    if event.phase == "ended" then
      moveToGameScene(Resources.Scenes.Play)
    end
  end
  initButton(self.playLabel, true, true)
  
  -- Create the help label
--  self.helpLabel = director:createLabel({
--    hAlignment="center",
--    font=Resources.Fonts.HomeWhite,
--    color=color.black,
--    text="TUTORIAL"})
--  self.helpLabel.y = self.playLabel.y - self.helpLabel.hText - textGap
--  function self.helpLabel:blinkNotify(event)
--    if event.phase == "ended" then
--      moveToGameScene(Resources.Scenes.Tutorial)
--    end
--  end
--  initButton(self.helpLabel, true, true)
  
  -- Create the exit sprite
  self.exitSprite = director:createLabel({
    hAlignment="center",
    font=Resources.Fonts.HomeWhite,
    text="EXIT"})
  self.exitSprite.y = self.playLabel.y - self.exitSprite.hText - textGap
  createBackSprite(true, nil, nil, self.exitSprite)
  
  -- Create the help label
  self.aboutLabel = director:createLabel({
    hAlignment="center",
    font=Resources.Fonts.HomeWhiteLink,
    color=Resources.Colors.Blue,
    text="www.botheadgames.com"})
  self.aboutLabel.y = self.exitSprite.y - self.aboutLabel.hText - textGap - 10
--  function self.aboutLabel:blinkNotify(event)
--    if event.phase == "ended" then
--      if browser:isAvailable() then
--        browser:launchURL(Resources.About.Website, false)
--      end
--    end
--  end
--  initButton(self.aboutLabel, true, true)
  
  dbg.print("mainScene - scene:setUp - complete")
end

-- Create the tear down scene event that
-- we will use to cleanup our scenese resources
function scene:tearDown(event)
  dbg.print("mainScene - scene:tearDown")
  
  -- Cleanup all the timers on this scene
  tearDownTimers(self.timers)
  
  -- Clear out the globals created by this scene
  self.backgroundSprite = tearDownSprite(self.backgroundSprite)
  self.playLabel = tearDownSprite(self.playLabel)
  --self.helpLabel = tearDownSprite(self.helpLabel)
  self.settingsLabel = tearDownSprite(self.settingsLabel)
  self.statisticsLabel = tearDownSprite(self.statisticsLabel)
  --self.communityLabel = tearDownSprite(self.communityLabel)
  self.exitSprite = tearDownBackSprite(self.exitSprite)
  self.aboutLabel = tearDownBackSprite(self.aboutLabel)
  self:releaseResources()
  dbg.print("mainScene - scene:tearDown - complete")
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
