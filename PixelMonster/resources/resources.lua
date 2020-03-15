-- Global resources
dbg.print("resources - initializing...")
Resources = 
{
  -- Colors
  Colors =
  {
    Blue = quick.QColor:new(18,168,158),
    Red = quick.QColor:new(249,74,74),
    Orange = quick.QColor:new(247,148,30),
    Violet = quick.QColor:new(136,4,248),
  },
  
  -- Fonts
  Fonts =
  {
    PlayWhite = director:createFont("fonts/PlayWhite.fnt"),
    HomeWhite = director:createFont("fonts/HomeWhite.fnt"),
    HomeWhiteLink = director:createFont("fonts/HomeWhiteLink.fnt")
  },
  
  -- Videos
--  Videos =
--  {
--    Tutorial = "video/GameDemo.mp4"
--  },
  
  -- Atlases
  Atlases = 
  {
    Scoreloop = director:createAtlas("textures/sl_icon_badge_ldpi.png"),
    Explosion = director:createAtlas("textures/fire.png"),
    PegCircleLarge = director:createAtlas("textures/peg1.png"),
    PegCircleMedium = director:createAtlas("textures/peg2.png"),
    PegCircleSmall = director:createAtlas("textures/peg5.png"),
    PowerupBox = director:createAtlas("textures/powerupbox.png"),
    BackgroundLeadboard = director:createAtlas("textures/leaderboard.png"),
    BackgroundCommunity = director:createAtlas("textures/community.png"),
    BackgroundScores = director:createAtlas("textures/scores.png"),
    BackgroundSettings = director:createAtlas("textures/settings.png"),
    BackgroundHome = director:createAtlas("textures/homescreen.png"),
    BackgroundPlain = director:createAtlas("textures/backgroundplain.png"),
    BackgroundHelp = director:createAtlas("textures/help.png"),
    ClearPortal = director:createAtlas("textures/clearPortal.png"),
    Side = director:createAtlas("textures/border_side.png"),
    Top = director:createAtlas("textures/border_top.png"),
    LargePixel = director:createAtlas("textures/largepixel.png"),
    MediumPixel = director:createAtlas("textures/mediumpixel.png"),
    SmallPixel = director:createAtlas("textures/smallpixel.png"),
    HeavyPixel = director:createAtlas({
      width = 35,
      height = 35,
      numFrames = 2,
      textureName = "textures/heavy.png"}),
    Powerups = director:createAtlas({
      width = 25,
      height = 25,
      numFrames = 4,
      textureName = "textures/powerups.png"
    }),
    Monster = director:createAtlas({
      width = 60,
      height = 60,
      numFrames = 3,
      textureName = "textures/monster.png"
    }),
    PixelCannonTop = director:createAtlas({
      width = 76,
      height = 62,
      numFrames = 3,
      textureName = "textures/pixelcannontop.png"
    }),
    PixelBomb = director:createAtlas({
      width = 30,
      height = 30,
      numFrames = 2,
      textureName = "textures/bombpixel.png"
    }),
    ForcePixel = director:createAtlas({
      width = 30,
      height = 30,
      numFrames = 2,
      textureName = "textures/force.png"
    })
  },
  
  -- Frames
  Frames = 
  {
    Powerups = 
    {
      Clear = 1,
      Invincible = 2,
      Energy = 3,
      Sonic = 4
    },
    Monster = 
    {
      Normal = 1,
      Hurt = 2,
      Invincible = 3
    },
    PixelBomb = 
    {
      Normal = 1,
      Stunned = 2
    },
    ForcePixel = 
    {
      Normal = 1,
      Stunned = 2
    },
    HeavyPixel =
    {
      Normal = 1,
      Stunned = 2
    }
  },
  
  -- Points
  Points = 
  {
    LargePixel = 1,
    MediumPixel = 2,
    SmallPixel = 3,
    HeavyPixel = 4,
    ForcePixel = 5,
    PixelBomb = 6
  },
  
  -- Sounds
  Sounds = 
  {
    Soundtrack = "sounds/Theme.mp3",
    Point = "sounds/Point.raw",
    Level = "sounds/Level.raw",
    Silent = "sounds/Silent.raw",
    Hurt = "sounds/Hurt.raw",
    Powerup = "sounds/Powerup.raw",
  },
  
  -- User data
  UserData = 
  {
    TopScore = 0,
    TopTime = 0,
    TopLevel = 0,
    EnableSoundTrack = true,
    EnableSoundEffects = true,
    Wins = 0,
    Losses = 0,
    LastScore = 0,
    LastTime = 0,
    LastLevel = 0,
    EnableAutoSubmit = true,
    EnableNotifications = true,
    EnableHapticFeedback = true,
    ShowTutorial = true
  },
  
  -- Game data
  GameData = 
  {
    LevelDuration = 30,
    InitialLives = 3,
    SoundFrequency = 44100,
    PointsExtraLife = 50,
    MaxPixelMonsterPortal = 3,
    Version = "1.0",
    UserDataFile = "userdata",
    Invincible = false,
    MaxLevel = 21
  },
  
  -- Scoreloop data
  Scoreloop = 
  {
    GameID = "e21b47cd-c703-4c61-bd7d-0a7ff570eb34",
    GameSecret = "0ojqRb5cxVGpmhyU7odqw5XDBOf1nS2RXymmRfoOK+pBpZta2/ZWcg==",
    Currency = "AGV",
    Languages = "en"
  },
  
  -- Ads data
  Ads =
  {
    InneractiveID = "BotHeadGames_PixelMonster_Android",
    LeadBoltBannerID = "146049026",
    LeadBoltWallID = "521657180",
    LeadBoltAlertID = "633032934",
    
    --"The banner ads will fill the width of the screen (up to 1080 wide) with the following dimensions/ aspect ratio:
    --width 320 ~ 467: banner stretches to 100% with ratio 320:50
    --width 468 ~ 727: banner stretches to 100% with ratio 468:60
    --width 728 ~ 1079: banner stretches to 100% with ratio 728:90
    --width 1080 or more: banner stretches to 1080 with ration 728:90"
    BannerWidth = 250,
    BannerHeight = 50
  },
  
  About =
  {
    Website = "http://www.botheadgames.com"
  }
}

-- Animations
dbg.print("resources - loading animations...")
Resources.Animations = {}
Resources.Animations.ClearPortal = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.ClearPortal
})
Resources.Animations.Scoreloop = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.Scoreloop
})
Resources.Animations.PegCircleLarge = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.PegCircleLarge
})
Resources.Animations.PegCircleMedium = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.PegCircleMedium
})
Resources.Animations.PegCircleSmall = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.PegCircleSmall
})
Resources.Animations.Powerups = director:createAnimation({
  start = 1,
  count = 4,
  delay = 1/4,
  atlas = Resources.Atlases.Powerups
})
Resources.Animations.PowerupBox = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.PowerupBox
})
Resources.Animations.BackgroundCommunity = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.BackgroundCommunity
})
Resources.Animations.BackgroundLeadboard = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.BackgroundLeadboard
})
Resources.Animations.BackgroundScores = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.BackgroundScores
})
Resources.Animations.BackgroundSettings = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.BackgroundSettings
})
Resources.Animations.BackgroundHome = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.BackgroundHome
})
Resources.Animations.BackgroundPlain = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.BackgroundPlain
})
Resources.Animations.BackgroundHelp = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.BackgroundHelp
})
Resources.Animations.Side = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.Side
})
Resources.Animations.Top = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.Top
})
Resources.Animations.LargePixel = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.LargePixel
})
Resources.Animations.MediumPixel = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.MediumPixel
})
Resources.Animations.SmallPixel = director:createAnimation({
  start = 1,
  count = 1,
  atlas = Resources.Atlases.SmallPixel
})
Resources.Animations.HeavyPixel = director:createAnimation({
  start = 1,
  count = 2,
  atlas = Resources.Atlases.HeavyPixel
})
Resources.Animations.Monster = director:createAnimation({
  start = 1,
  count = 3,
  atlas = Resources.Atlases.Monster
})
Resources.Animations.PixelCannonTop = director:createAnimation({
  start = 1,
  count = 3,
  atlas = Resources.Atlases.PixelCannonTop
})
Resources.Animations.PixelBomb = director:createAnimation({
  start = 1,
  count = 2,
  atlas = Resources.Atlases.PixelBomb
})
Resources.Animations.ForcePixel = director:createAnimation({
  start = 1,
  count = 2,
  atlas = Resources.Atlases.ForcePixel
})

-- Load the utility and user data
dbg.print("resources - loading user data...")
require("utility")
loadUserData()

-- Load the sound
dbg.print("resources - loading sound...")
loadSound()

-- Play the silent sound to init the audio
-- subsystem, which sometimes flakes out
-- on the first sound you ask it to play.
playGameSound(Resources.Sounds.Silent)

-- Scenes
-- NOTE: Do this last always in the resource file
-- so that other resources we create in here do not
-- get randomly attached to other scenes.  These resources
-- will be temporarily associated with the loading scene
-- that we create in the main LUA file, but immediately
-- the references will be cleared out after we move to
-- the main scene...
dbg.print("resources - loading scenes...")
Resources.Scenes = {}
dbg.print("resources - loading main scene...")
Resources.Scenes.Main = require("mainScene")
dbg.print("resources - loading play scene...")
Resources.Scenes.Play = require("playScene")
dbg.print("resources - loading end scene...")
Resources.Scenes.End = require("endScene")
dbg.print("resources - loading statistics scene...")
Resources.Scenes.Statistic = require("statisticsScene")
dbg.print("resources - loading settings scene...")
Resources.Scenes.Setting = require("settingsScene")
--dbg.print("resources - loading community scene...")
--Resources.Scenes.Community = require("communityScene")
--dbg.print("resources - loading help scene...")
--Resources.Scenes.Help = require("helpScene")
dbg.print("resources - loading tutorial scene...")
Resources.Scenes.Tutorial = require("tutorialScene")
--dbg.print("resources - loading leaderboard scene...")
--Resources.Scenes.Leadboard = require("leaderboardScene")

dbg.print("resources - hooking into exit event...")
-- Hook into the exit event so that we handle exits
-- no matter how they are initiated...
local function exit()
  dbg.print("resources - handling exit event...")
  removeGameResources()
end
system:addEventListener("exit", exit)

dbg.print("resources - hooking into suspend event...")
-- Hook into the suspend event so that we handle when
-- the app is put into the background
local function suspend()
  dbg.print("resources - handling suspend event...")
  if director:getCurrentScene() == Resources.Scenes.Play then
    Resources.Scenes.Play:updatePause(true)
  end
end
system:addEventListener("suspend", suspend)

-- Load scoreloop
dbg.print("resources - loading QScores...")
require("QScores")

-- Initialize scoreloop
scores:init(
  Resources.Scoreloop.GameID,
  Resources.Scoreloop.GameSecret,
  Resources.GameData.Version,
  Resources.Scoreloop.Currency,
  Resources.Scoreloop.Languages)

-- Initialize the LUA math random seed
math.randomseed(os.time())

-- Allow the physics engine to sleep
dbg.print("resources - updating physics engine for sleep...")
physics:setAllowSleeping(true)
physics:pause()
--physics.debugDraw = true

-- Disable backlight always on so that
-- the phone can go to sleep when there is
-- no interaction with the game.
device:setBacklightAlways(false)

-- Initialize the ads API
if ads:isAvailable() then
  ads:init()
end
