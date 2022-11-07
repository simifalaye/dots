-- Base
import XMonad
import qualified Data.Map as M
import XMonad.Config.Desktop
import Data.Monoid
import Data.Maybe (fromJust)
import Data.Maybe (isJust)
import Data.Ratio
import System.IO (hPutStr, hPutStrLn, hClose, Handle)
import System.Exit (exitSuccess)
import Text.Printf
import qualified XMonad.StackSet as W

-- Utilities
import XMonad.Util.EZConfig
import XMonad.Util.NamedActions
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (safeSpawn, runInTerm, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.WorkspaceCompare

-- Hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.FadeWindows
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.UrgencyHook

-- Actions
import qualified XMonad.Actions.Search as S
import XMonad.Actions.CopyWindow
import XMonad.Actions.CycleWS
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.UpdatePointer
import XMonad.Actions.WithAll (sinkAll, killAll)

-- Layouts modifiers
import XMonad.Layout.WorkspaceDir
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Renamed
import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders
import XMonad.Layout.ToggleLayouts

-- Layouts
import XMonad.Layout.Tabbed

-- Prompts
import XMonad.Prompt (defaultXPConfig, XPConfig(..), XPPosition(Bottom, Top), Direction1D(..))
import XMonad.Prompt.ConfirmPrompt
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Man
import XMonad.Prompt.Shell (shellPrompt)
import XMonad.Prompt.Ssh

-------------------------------------------------------------------------------
-- User Config --

myFontName    = "FiraCode Nerd Font"
myFont        = printf "xft:%s:regular:pixelsize=12" myFontName
myTerm        = "alacritty" -- Sets default terminal
myTextEditor  = "nvim"      -- Sets default text editor
myBrowser     = "firefox"   -- Sets defualt browser
myFiles       = "nautilus"  -- Sets defualt file browser
myShell       = "zsh"       -- Sets default shell
myBorderWidth = 2           -- Sets border width for windows
myWindowGap   = 5           -- Sets the gap between windows
myModMask     = mod4Mask    -- Sets modkey to super/windows key
myStatusBar   = "xmobar -x 0" -- Sets status bar command

-- Run commands in terminal shell
myRunCmd :: String -> String -> String
myRunCmd cmd title = printf "%s -t %s -e %s -i -l -c %s " myTerm title myShell cmd

-- Theme: Base16 Colors
base00 = "#000000" -- Black
base01 = "#282828" -- Black 1
base02 = "#383838" -- Black 2
base03 = "#585858" -- Bright Black
base04 = "#B8B8B8" -- Grey
base05 = "#D8D8D8" -- White
base06 = "#E8E8E8" -- White 1
base07 = "#F8F8F8" -- Bright White
base08 = "#AB4642" -- Red
base09 = "#DC9656" -- Orange
base0A = "#F7CA88" -- Yellow/Bright-Yellow
base0B = "#A1B56C" -- Green/Bright-Green
base0C = "#86C1B9" -- Cyan/Bright-Cyan
base0D = "#7CAFC2" -- Blue/Bright-Blue
base0E = "#BA8BAF" -- Magenta/Bright-Magenta
base0F = "#A16946" -- Brown

myTabTheme = def
    { fontName            = myFont
    , activeColor         = base0D
    , activeBorderColor   = base0D
    , activeTextColor     = base00
    , inactiveColor       = base03
    , inactiveBorderColor = base03
    , inactiveTextColor   = base05
    }
myPromptTheme = def
    { font                = myFont
    , bgColor             = base03
    , fgColor             = base05
    , fgHLight            = base03
    , bgHLight            = base0D
    , borderColor         = base03
    , promptBorderWidth   = 0
    , height              = 20
    , position            = Top
    }
warmPromptTheme = myPromptTheme
    { bgColor             = base0A
    , fgColor             = base03
    , position            = Top
    }
hotPromptTheme = myPromptTheme
    { bgColor             = base08
    , fgColor             = base07
    }

-------------------------------------------------------------------------------
-- Keybinds --
-- Graphics.X11 keysym definitions: https://wiki.haskell.org/Xmonad/Key_codes
-- /usr/include/X11/keysymdef.h

myKeys conf = let
    wsKeys = map show $ [1..9] ++ [0]
    -- Helper functions
    -------------------
    -- Wrap multiple commands
    zipM  m nm ks as f = zipWith (\k d -> (m ++ k, addName nm $ f d)) ks as
    zipM' m nm ks as f b = zipWith (\k d -> (m ++ k, addName nm $ f d b)) ks as
    -- Define subkey menu title
    subKeys str ks = subtitle str : mkNamedKeymap conf ks
    -- Get WS by index no scratchpad
    getSortByIndexNoSP =
        fmap (.namedScratchpadFilterOutWorkspace) getSortByIndex
    -- Action Functions
    -------------------
    -- Navigate WS, ignore scratchpads
    nextNonEmptyWS = findWorkspace getSortByIndexNoSP Next HiddenNonEmptyWS 1
        >>= \t -> (windows . W.view $ t)
    prevNonEmptyWS = findWorkspace getSortByIndexNoSP Prev HiddenNonEmptyWS 1
        >>= \t -> (windows . W.view $ t)
    -- Make Full/float
    toFull = withFocused $ windows . (flip W.float $ W.RationalRect 0 0 1 1)
    toFloat = withFocused $ windows . (flip W.float $ W.RationalRect 0.1 0.1 0.8 0.8)
    in

    subKeys "System"
    [ ("M-q", addName "Restart & rebuild XMonad" $ spawn "xmonad --recompile; xmonad --restart")
    , ("M-S-q", addName "Quit XMonad" $ confirmPrompt hotPromptTheme "Quit XMonad" $io exitSuccess)
    , ("M-S-l", addName "Lock screen" $ spawn "xautolock -locknow || slock")
    , ("<Print>", addName "Print Fullscreen" $ spawn "screenshot -f")
    , ("S-<Print>", addName "Print Window" $ spawn "screenshot -w")
    , ("C-<Print>", addName "Print Selection" $ spawn "screenshot -s")
    ] ^++^

    subKeys "Launchers"
    [ ("M-<Return>", addName "Terminal" $ spawn (myTerm))
    , ("M-<Space>", addName "Launcher" $ spawn "rofi -show drun")
    , ("M-S-<Space>", addName "Snippets" $ spawn "rofi-snippets")
    , ("M-M1-<Space>", addName "Power Menu" $ spawn "rofi_power")
    , ("M-/", addName "NSP Term" $ namedScratchpadAction myScratchpads "terminal")
    , ("M-\\", addName "NSP Notes" $ namedScratchpadAction myScratchpads "notes")
    ] ^++^

    subKeys "Windows"
    [ ("M-x", addName "Kill" $ kill1)
    , ("M-S-x", addName "Kill all" $ confirmPrompt warmPromptTheme "Kill all" killAll)
    , ("M-t", addName "Tile" $ withFocused $ windows .W.sink)
    , ("M-f", addName "Fullscreen" $ toFull)
    , ("M-S-f", addName "Float" $ toFloat)
    , ("M-j", addName "Focus Next" $ windows W.focusDown)
    , ("M-k", addName "Focus Previous" $ windows W.focusUp)
    , ("M-S-j", addName "Swap Next" $ windows W.swapDown)
    , ("M-S-k", addName "Swap Previous" $ windows W.swapUp)
    , ("M-u", addName "Focus urgent" focusUrgent)
    , ("M-m", addName "Focus master" $ windows W.focusMaster)
    , ("M-S-m", addName "Swap master" $ windows W.swapMaster)
    , ("M-,", addName "Focus next screen" $ prevScreen)
    , ("M-.", addName "Focus prev screen" $ nextScreen)
    , ("M-S-,", addName "Move next screen" $ shiftPrevScreen)
    , ("M-S-.", addName "Move prev screen" $ shiftNextScreen)
    ] ^++^

    subKeys "Workspaces"
    (
    [ ("M-<Esc>" , addName "Toggle last workspace" $ toggleWS' ["NSP"])
    , ("M-<Tab>" , addName "Next non-empty workspace" $ nextNonEmptyWS)
    , ("M-S-<Tab>" , addName "Prev non-empty workspace" $ prevNonEmptyWS)
    ]
    ++ zipM "M-" "View ws" wsKeys [0..] (withNthWorkspace W.greedyView)
    ++ zipM "M-S-" "Move w to ws" wsKeys [0..] (withNthWorkspace W.shift)
    ++ zipM "M-M1-S-" "Copy w to ws" wsKeys [0..] (withNthWorkspace copy)
    ) ^++^

    subKeys "Layouts"
    [ ("M-n", addName "Next Layout" $ sendMessage NextLayout)
    , ("M-a", addName "First Layout" $ sendMessage FirstLayout)
    , ("M-b", addName "Toggle bar" $ sendMessage ToggleStruts)
    , ("M-i", addName "Increase master clients" $ sendMessage (IncMasterN 1))
    , ("M-d", addName "Decrease master clients" $ sendMessage (IncMasterN (-1)))
    , ("M-h", addName "Increase master area" $ sendMessage Shrink)
    , ("M-l", addName "Decrease master area" $ sendMessage Expand)
    ] ^++^

    subKeys "Multimedia"
    [ ("<XF86MonBrightnessUp>", addName "Backlight up" $ spawn "xbacklight -inc 10")
    , ("<XF86MonBrightnessDown>", addName "Backlight down" $ spawn "xbacklight -dec 10")
    , ("<XF86AudioMute>", addName "Volume mute" $ spawn "volume mute")
    , ("<XF86AudioLowerVolume>", addName "Volume Dec" $ spawn "volume dec")
    , ("<XF86AudioRaiseVolume>", addName "Volume Inc" $ spawn "volume inc")
    ] ^++^

    subKeys "Terminal Apps"
    [ ("M-r h", addName "htop" $ spawn (myRunCmd "htop" "Htop"))
    , ("M-r e", addName "nvim" $ spawn (myRunCmd "nvim" "Nvim"))
    , ("M-r c", addName "calc" $ spawn (myRunCmd "calc" "Calc"))
    ] ^++^

    subKeys "Graphical Apps"
    [ ("M-g b", addName "Web browser" $ spawn myBrowser)
    , ("M-g f", addName "File browser" $ spawn myFiles)
    , ("M-g p", addName "Screen recorder" $ spawn "peek")
    ] ^++^

    subKeys "Environment"
    [ ("M-e c", addName "Toggle picom" $ spawn "toggle-picom")
    , ("M-e s", addName "Toggle screenkey" $ spawn "toggle-screenkey")
    ]

-- Mouse bindings: default actions bound to mouse events
myMouseBindings :: XConfig Layout -> M.Map (KeyMask, Button) (Window -> X ())
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList
    -- mod-button1 %! Set the window to floating mode and move by dragging
    [ ((modMask, button1), \w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster)
    -- mod-button2 %! Raise the window to the top of the stack
      , ((modMask, button2), windows . (W.shiftMaster .) . W.focusWindow)
    -- mod-button3 %! Set the window to floating mode and resize by dragging
      , ((modMask, button3), \w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster)
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

-------------------------------------------------------------------------------
-- Workspaces --

-- Workspaces
myWorkspaces = [" 1:Web ", " 2:Dev ", " 3:Chat ", " 4:Vid ", " 5:Doc ",
                " 6:Misc", " 7:Misc ", " 8:Misc ", " 9:Sys "]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..]
-- Clickable workspaces
clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

-------------------------------------------------------------------------------
-- Startup --

myStartupHook = do
    spawn "autostart" -- Custom autostart script in home user bin directory
    spawn "! pgrep -x trayer && trayer --edge bottom --align right \
        \ --widthtype request --padding 6 --SetDockType true --SetPartialStrut true \
        \ --expand true --monitor 1 --transparent true --alpha 0 \
        \ --tint 0x000000 --height 20 --iconspacing 2"

-------------------------------------------------------------------------------
-- Layout Hook --

-- Layouts
myLayoutHook = avoidStruts
               $ toggleLayouts myStack
               $ (myStack ||| myHStack ||| myTabbed)
    where
        myStack  = renamed [Replace "Stack"]
                   $ mySpacing myWindowGap
                   $ Tall 1 (3/100) (1/2)
        myHStack = renamed [Replace "H-Stack"]
                   $ mySpacing myWindowGap
                   $ Mirror
                   $ Tall 1 (3/100) (1/2)
        myTabbed = renamed [Replace "Tabbed"]
                   $ tabbed shrinkText myTabTheme
        mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
        mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True


-------------------------------------------------------------------------------
-- Manage Hook --
-- Run: `xprop` and click on a window to get it's name and class

-- Window Rules
myManageHook :: ManageHook
myManageHook = (composeAll . concat $
    [
        -- General Conditions
          [className =? c --> doShift (myWorkspaces !! 0) | c <- myClassWebShifts]
        , [className =? c --> doShift (myWorkspaces !! 1) | c <- myClassDevShifts]
        , [className =? c --> doShift (myWorkspaces !! 2) | c <- myClassChatShifts]
        , [className =? c --> doShift (myWorkspaces !! 3) | c <- myClassVidShifts]
        , [className =? c --> doShift (myWorkspaces !! 4) | c <- myClassDocShifts]
        , [className =? c --> doShift (myWorkspaces !! 8) | c <- myClassSysShifts]
        , [className =? c --> doCenterFloat               | c <- myClassCFloats]
        , [className =? c --> doRectFloat (floatRect)     | c <- myClassRFloats]
        , [className =? c --> doIgnore                    | c <- myClassIgnore]
        , [resource  =? r --> doIgnore                    | r <- myResourceIgnore]

        -- Mattermost
        , [className =? "Mattermost" --> doShiftAndGo (myWorkspaces !! 2)]
        , [className =? "Mattermost-desktop" <&&> isDialog --> doRectFloat(floatRect)]

        -- Thunderbird
        , [className =? "Thunderbird" <&&>
            role =? "AlarmWindow" --> doRectFloat (floatRect)]
        , [className =? "Thunderbird" <&&> role =? "Preferences" --> doCenterFloat]

        --- Type Conditions
        , [isDialog --> doCenterFloat]
        , [isFullscreen --> (doF W.focusDown <+> doFullFloat)]
        , [isInProperty "_NET_WM_STATE" "_NET_WM_STATE_ABOVE" <||>
            isInProperty "_NET_WM_STATE" "_NET_WM_STATE_STAYS_ON_TOP"
            --> doCenterFloat]

    ])  <+> namedScratchpadManageHook myScratchpads
        <+> manageHook def

    where
        myClassWebShifts  = ["Firefox", "Opera", "vivaldi", "qutebrowser"]
        myClassDevShifts  = ["Gnome-calculator"]
        myClassChatShifts = ["Thunderbird"]
        myClassVidShifts  = ["zoom"]
        myClassDocShifts  = ["Dia", "libreoffice", "Wireshark"]
        myClassSysShifts  = ["Com.cisco.anyconnect.gui"]
        myClassCFloats    = ["Arandr", "confirm", "download", "error", "file_progress",
                             "splash", "toolbar", "Peek", "feh", "sxiv", "Xmessage", "Gxmessage"]
        myClassRFloats    = ["Vlc", "Zenity"]
        myClassIgnore     = []
        myResourceIgnore  = ["desktop", "desktop_window", "trayer"]
        -- Helpers
        role = stringProperty "WM_WINDOW_ROLE"
        floatRect = W.RationalRect (1 % 4) (1 % 4) (1 % 2) (1 % 2)
        doShiftAndGo ws = doF (W.greedyView ws) <+> doShift ws

-- Scratchpads
myScratchpads :: [NamedScratchpad]
myScratchpads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "notes" spawnNotes findNotes manageNotes
                ]
    where
        spawnTerm  = myRunCmd "'tmux new-session -As main'" "Scratchpad"
        findTerm   = title =? "Scratchpad"
        manageTerm = customFloating $ W.RationalRect l t w h
            where
                h = 0.9
                w = 0.9
                t = 0.95 -h
                l = 0.95 -w
        spawnNotes  = myRunCmd "'cd ~/notes && $EDITOR .'" "MyNotes"
        findNotes   = title =? "MyNotes"
        manageNotes = customFloating $ W.RationalRect l t w h
            where
                h = 0.9
                w = 0.9
                t = 0.95 -h
                l = 0.95 -w

-------------------------------------------------------------------------------
-- Handle Event Hook --

-- X Event actions
myHandleEventHook = docksEventHook
                <+> fadeWindowsEventHook
                <+> handleEventHook def
                <+> fullscreenEventHook

-------------------------------------------------------------------------------
-- Log Hook --

-- Xmobar Config
myLogHook :: Handle -> X ()
myLogHook xmproc = dynamicLogWithPP $ namedScratchpadFilterOutWorkspacePP $ xmobarPP
    { ppOutput = hPutStrLn xmproc
    -- Current workspace in xmobar (xmobarColor {fg} {bg})
    , ppCurrent = xmobarColor base00 base0D
    -- Visible but not current workspace
    , ppVisible = xmobarColor base05 "" . clickable
    -- Hidden workspaces in xmobar
    , ppHidden = xmobarColor base05 "" . clickable
    -- Hidden workspaces (no windows)
    , ppHiddenNoWindows = xmobarColor base03 "" . clickable
    -- Title of active window in xmobar
    , ppTitle = xmobarColor base0D "" . shorten 60
    -- Separators in xmobar
    , ppSep =  "<fc=" ++ base04 ++ "> | </fc>"
    -- Seperator between ws names
    , ppWsSep = ""
    -- Urgent workspace
    , ppUrgent = xmobarColor base08 ""
    , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
    } -- >> updatePointer (0.5, 0.5) (0, 0)

-------------------------------------------------------------------------------
-- Main --

main :: IO ()
main = do
    xmproc <- spawnPipe myStatusBar
    xmonad
        $ docks
        $ ewmh
        $ addDescrKeys' ((myModMask, xK_F1), xMessage) myKeys
        $ myConfig xmproc

myConfig xmproc = def
    -- Config
    { modMask            = myModMask
    , terminal           = myTerm
    , borderWidth        = myBorderWidth
    , normalBorderColor  = base00
    , focusedBorderColor = base0D
    , workspaces         = myWorkspaces
    , mouseBindings      = myMouseBindings
    -- Hooks
    , startupHook        = myStartupHook
    , layoutHook         = myLayoutHook
    , manageHook         = myManageHook
    , handleEventHook    = myHandleEventHook
    , logHook            = myLogHook xmproc
    }
