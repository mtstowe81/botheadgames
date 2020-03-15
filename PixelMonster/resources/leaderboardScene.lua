-- Create our scene
local scene = director:createScene()

-- Setup resources
function scene:setUp(event)
  dbg.print("helpScene - scene:setUp")
  
  -- Create the grass background sprite
  self.backgroundSprite = director:createSprite({
    x = 0,
    y = 0,
    source = Resources.Animations.BackgroundLeadboard})
  
  -- Create the exit sprite
  self.exitSprite = director:createLabel({
    hAlignment="center",
    font=Resources.Fonts.HomeWhite,
    color=Resources.Colors.Blue,
    text="BACK"})
  self.exitSprite.y = 20
  createBackSprite(false, Resources.Scenes.Community, nil, self.exitSprite)
  
  -- Create the scoreloop sprite
  self.scoreloopSprite = createScoreloopSprite()
  self.scoreloopSprite.y = self.exitSprite.y + (self.exitSprite.hText/2) - (self.scoreloopSprite.h/2)
  self.scoreloopSprite.x = director.displayWidth - self.scoreloopSprite.w - 35
  
  dbg.print("statisticsScene - scene:setUp - complete")
end

-- Create the tear down scene event that
-- we will use to cleanup our scenese resources
function scene:tearDown(event)
  dbg.print("helpScene - scene:tearDown")
  
  -- Clear out the globals created by this scene
  self.backgroundSprite = tearDownSprite(self.backgroundSprite)
  self.exitSprite = tearDownBackSprite(self.exitSprite)
  self.scoreloopSprite = tearDownBackSprite(self.scoreloopSprite)
  self:releaseResources()
  dbg.print("tutorialScene - scene:tearDown - complete")
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
