--dbg.print("main - starting...")
-- Enable debugging
-- NOTE: This is a ZeroBrane Studio hook that
-- should always be comments out when building
-- for a device.
--require("mobdebug").start()

-- Move to scene
-- NOTE: This normally would have gone in the utility
-- LUA file as a shared function, but we need it here
-- before we even load that LUA file...
function moveToGameScene(scene)
  if scene ~= nil and director:getCurrentScene() ~= scene then
    dbg.print("moving to scene " .. scene.name)
    director:moveToScene(scene, {transitionType="fade", transitionTime=0.5})  
  else
    dbg.print("moving to scene failed!")
  end
end

--If using [QUICK] DeferRenderingOnStart=1 in app.icf, you must call this
--when your first scene is ready to draw.
director:startRendering()

-- The loading scene that will temporarily
-- display while we are initlizing game resources.
local scene = director:createScene()

-- The initialize function
local function initializeTimeElapsed(event)  
  -- Load the resources
  dbg.print("main - loading resource file...")
  require("resources")
  
  -- Note that after we have created all the
  -- other scenes we have lost this scene as
  -- the current scene, so set this scene object
  -- back to the current scene so that when we
  -- move to the main scenen it will get its tear
  -- down event after the transition and cleanup.
  if director:getCurrentScene() ~= scene then
    director:setCurrentScene(scene)
  end
  
  -- Move to the main scene
  dbg.print("main - moving to main scene...")
  moveToGameScene(Resources.Scenes.Main)
  
  -- Clear this reference since we no longer
  -- need the loading scene.
  scene = nil
end

-- Setup resources
function scene:setUp(event)
  dbg.print("main - scene:setUp")
  
  -- Create the background sprite that
  -- displays the loading progress animation.
  local atlas = director:createAtlas({
      width = 480,
      height = 320,
      numFrames = 1,
      textureName = "textures/splash.png",
    })
  local anim = director:createAnimation({
      start = 1,
      count = 1,
      atlas = atlas,
    })
  self.backgroundSprite = director:createSprite({
      x = 0,
      y = 0,
      source = anim})
  
  -- Add timer to trigger initialize
  scene:addTimer(initializeTimeElapsed, 5, 1, 0)
  
  dbg.print("main - scene:setUp - complete")
end

-- Create the tear down scene event that
-- we will use to cleanup our scenese resources
function scene:tearDown(event)
  dbg.print("main - scene:tearDown")
  
  -- Clear out the globals created by this scene
  self.backgroundSprite = tearDownSprite(self.backgroundSprite)
  
  self:releaseResources()
  dbg.print("main - scene:tearDown - complete")
end

-- Add setup and teardown event handlers
scene:addEventListener({"setUp", "tearDown"}, scene)

-- Creating the loading scene set it to the
-- current scene, set the current scene back
-- to the global scene and then move to the
-- loading scene to force the correct events
-- for setup.
director:setCurrentScene(nil)

-- Now move back to our scene
moveToGameScene(scene)