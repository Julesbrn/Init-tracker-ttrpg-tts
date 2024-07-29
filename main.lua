VERSION = "V2.9.9.5 - 07/28/24" -- N/A
math.randomseed(os.time())

--Global variables
DEBUG_MODE = false

isCombatStarted = false
counter = 1
bHide = false
confMsg = nil
confSender = nil
confirmTime = os.time()
showNumbersb = false
lastNext = os.time()

stats = {}
lastTime = os.time()
roundNumber = 0
showNumbersb = false
currentVisibility = "Clubs"
creatures = {}
turnNumber = 1
numCreatures = 0
lastSave = nil

-- End global variables

function doPrint(msg, isDbg)
  if isDbg then
    if DEBUG_MODE then
      printToAll(msg) -- It's a debug message and we're in debug mode.
    end
  else
    printToAll(msg) -- It's a non-debug message, print it anyway.
  end
end

function toggleUI(player, value, id)
  printToAll("sdfgsdfg")
  UI.hide("mapSelection")
end

function safeAppendStr(str1, str2)
  if (str1 == nil) then
    return str2
  elseif (str2 == nil) then
    return ""
  else
    return str1 .. str2
  end
end

function cleanVisStr(str)
  str = string.gsub(str, "^|+", "")  -- remove leading |
  str = string.gsub(str, "|+$", "")  -- remove trailing |
  str = string.gsub(str, "%|+", "|") -- remove ||

  return str
end

function removePlayerVisibility(str, color)
  if str == nil then
    return "invisible"
  end
  dumper(str, "str", 0)
  dumper(color, "color", 0)
  str = string.gsub(str, color, "")
  str = cleanVisStr(str)
  return str
end

function addPlayerVisibility(str, color)
  if str == nil then
    return color
  end
  str = str .. "|" .. color
  return str
end

function minimizeUI(player, value, id)
  local mapSelectionScroll2 = UI.getAttribute("mapSelection2", "visibility")
  mapSelectionScroll2 = addPlayerVisibility(mapSelectionScroll2, player.color)

  local mapSelectionScroll1 = UI.getAttribute("mapSelection1", "visibility")
  mapSelectionScroll1 = removePlayerVisibility(mapSelectionScroll1, player.color)
  UI.setAttribute("mapSelection1", "visibility", mapSelectionScroll1)
  UI.setAttribute("mapSelection2", "visibility", mapSelectionScroll2)
end

function restoreUI(player, value, id)
  local mapSelectionScroll2 = UI.getAttribute("mapSelection2", "visibility")
  mapSelectionScroll2 = removePlayerVisibility(mapSelectionScroll2, player.color)

  local mapSelectionScroll1 = UI.getAttribute("mapSelection1", "visibility")
  mapSelectionScroll1 = addPlayerVisibility(mapSelectionScroll1, player.color)
  UI.setAttribute("mapSelection1", "visibility", mapSelectionScroll1)
  UI.setAttribute("mapSelection2", "visibility", mapSelectionScroll2)
end

function onLoad(save_state)
  self.UI.setValue("VersionNumber", VERSION)
  globalUI = [[
    <Defaults>
    <Panel id="Window" class="TankChessPanel" color="#595959" outline="#635351" outlineSize="2 -2" />
    <Button class="mapButton" padding="0 0 145 0" textColor="#FFFFFF"
        colors="#AD9F91|#C9B9A9|#756C63|rgba(0.78,0.78,0.78,0.5)" />
    <Image class="mapImage" width="144" height="144" rectAlignment="UpperCenter" offsetXY="0 -3" />
</Defaults>

<Button id="nxtBtnUI" width="200" color="red" height="50" position="0,300,0" visibility=""
    onClick="{guid}/nextTurn">Next Turn</Button>

<Panel id="mapSelection1" class="TankChessPanel"
    width="480"
    height="500"
    rectAlignment="UpperCenter"
    offsetXY="0 -250"
    allowDragging="true"
    showAnimation="FadeIn"
    showAnimationDelay="2"
    visibility="White|Brown|Red|Orange|Yellow|Green|Teal|Blue|Purple|Pink|Grey|Black"
    returnToOriginalPositionWhenReleased="false">
    <VerticalScrollView
        id="mapSelectionScroll"
        rectAlignment="LowerCenter"
        offsetXY="0 -00"
        scrollSensitivity="40"
        padding="0 0 50 0"
        scrollbarColors="#AD9F91|#C9B9A9|#756C63|rgba(0.78,0.78,0.78,0.5)"
        width="480"
        height="480"
        color="#000000">
        <VerticalLayout padding="3 0 8 3" spacing="8 8" height="1000" width="460"
            childForceExpandHeight="false">
            <Button id="nxtBtn" minWidth="200" color="blue" minHeight="50" position="0,800,-30"
                visibility="White" onClick="{guid}/nextTurn">Next Turn</Button>


            <Text height="1500" width="1500" id="turnOrder" color="Green" fontSize="17"
                horizontalOverflow="Wrap" verticalOverflow="OverFlow"
                alignment="UpperLeft">Type +{inishudiv} {player name} to add players/monsters</Text>
        </VerticalLayout>
    </VerticalScrollView>
    <HorizontalLayout
        rectAlignment="UpperRight"
        width="40"
        height="20"
    >
        <Button id="minimizeBtn"
            width="20"
            height="20"
            color="#990000"
            textColor="#FFFFFF"
            fontSize="12"
            text="m"
            onClick="{guid}/minimizeUI"
            >
        </Button>

    </HorizontalLayout>
    <Text id="title" text="Initive Tracker - {version}" alignment="UpperLeft"
        fontSize="18"
        offsetXY="5 0"
        fontStyle="Bold" color="#FFFFFF"></Text>
</Panel>

<Panel id="mapSelection2" class="TankChessPanel"
    width="200"
    height="21"
    rectAlignment="UpperCenter"
    offsetXY="0 -250"
    allowDragging="true"
    visibility="invisible"
    showAnimation="FadeIn"
    showAnimationDelay="2"
    returnToOriginalPositionWhenReleased="false">
    <HorizontalLayout
        rectAlignment="UpperRight"
        width="40"
        height="20"
    >
        <Button id="restoreBtn"
            position="10,10"
            width="20"
            height="20"
            color="#990000"
            textColor="#FFFFFF"
            fontSize="12"
            text="M"
            onClick="{guid}/restoreUI">
        </Button>

    </HorizontalLayout>
    <Text id="title" text="Initive Tracker" alignment="UpperLeft"
        fontSize="18"
        offsetXY="5 0"
        fontStyle="Bold" color="#FFFFFF"></Text>
</Panel>
]]
  globalUI = string.gsub(globalUI, "{guid}", self.guid)
  globalUI = string.gsub(globalUI, "{version}", VERSION)
  --print(globalUI)
  UI.setXml(globalUI)
  UI.hide("Window")
  if (save_state == nil or save_state == '') then
    --Do nothing. This is a new game.
  else
    local saved = JSON.decode(save_state)
    stats = saved["stats"]
    lastTime = saved["lastTime"]
    roundNumber = saved["roundNumber"]
    showNumbersb = saved["showNumbersb"]
    currentVisibility = saved["currentVisibility"]
    creatures = saved["creatures"]
    if (not table.empty(creatures)) then
      startInit()
    end

    turnNumber = saved["turnNumber"]
    numCreatures = saved["numCreatures"]
    updateCreatures()
  end
  --Clear the screen
  for j = 1, 3 do
    for i = 1, 7 do
      doPrint("", false)
    end
  end
end

function onUpdate()
  UI.setAttribute("nxtBtn", "visibility", currentVisibility)
end

currentPlayer = ""

function parseToken(token)
  if (string.match(token, "^N:")) then
    token = tonumber(string.sub(token, 3))
  elseif (string.match(token, "^B:")) then
    token = string.sub(token, 3)
    token = token == "true"
  elseif (string.match(token, "^F:")) then
    token = string.sub(token, 3)
  elseif (string.match(token, "^V:")) then
    token = string.sub(token, 3)
  elseif (string.match(token, "^P:")) then
    token = string.sub(token, 3)
  end
  return token
end

--[[
  This is a debug Function. Below are some examples. Not advised for public lobbies.
  -P:turnNumber - prints the value of turnNumber (global variable)
  -F:updateCreatures - calls the function updateCreatures(), updating creatures list.
  -V:turnNumber 5 - sets the value of turnNumber to 5
  -V:debugVar B:true - sets the value of debugVar to true
  -V:debugVar B:false - sets the value of debugVar to false
  ]]
function doFunc(message, sender)
  message = message:gsub("^-", "")
  local lst = {}
  for token in string.gmatch(message, "[^%s]+") do
    table.insert(lst, token)
  end

  local tmp = _G
  for i = 1, #lst do
    --printToAll("counter :" .. i .. ": token :" .. lst[i] .. ":")
    local token = lst[i]
    local token_parsed = parseToken(token)
    if (string.match(token, "^F:")) then
      tmp = tmp[token_parsed]()
    elseif (string.match(token, "^V:")) then
      tmp[token_parsed] = parseToken(lst[i + 1])
      return
    elseif (string.match(token, "^P:")) then
      printToAll(token_parsed .. " = " .. tmp[token_parsed])
    else
      tmp = tmp[token_parsed]
    end
  end
end

-- This is where the chat messages are parsed into actions.
function onChat(message, sender)
  message = message:gsub("[ ]+", " ")
  debugMessage("---------------\n" .. message .. "\n---------------")
  -- We use string.sub for the commands that have parameters. e.g. ".goto 5" runs the goto command with parameter 5.
  -- Exact matches do not take parameters.
  if (string.sub(message, 1, 1) == "+") then
    addCreature(message, sender.color, sender.steam_name)
  elseif (string.sub(message, 1, 1) == "-") then     -- This and the above look for a single character
    doFunc(message, sender)
  elseif (string.sub(message, 1, 4) == ".del") then  -- Look for ".del"
    createConfirm(message, sender)
  elseif (message == ".next") then                   -- Look for ".next"
    createConfirm(message, sender)
  elseif (string.sub(message, 1, 5) == ".goto") then -- Look for ".goto"
    local gotoNum = tonumber(string.sub(message, 7))
    if (gotoNum == nil) then
      printToAll("Invalid number. Please reference .shownumbers")
      return
    end
    nextTurn("", gotoNum)
  elseif (message == ".start") then
    startInit()
  elseif (message == ".stop") then
    createConfirm(message, sender)
  elseif (message == ".stats") then
    getStats(false)
  elseif (message == ".statsfull") then
    getStats(true)
  elseif (message == ".shownumbers") then
    showNumbers()
  elseif (message == ".confirm") then
    checkConfirm(sender)
  elseif (message == ".con") then
    checkConfirm(sender)
  elseif (message == ".help") then
    printHelp()
  elseif (string.sub(message, 1, 5) == ".swap") then
    doSwap(message)
  elseif (string.sub(message, 1, 1) == ".") then
    rollDice(message, sender.steam_name)
  else
    debugMessage("============")
    return true
  end
  debugMessage("============")
  return false
end

function confirmed(message, sender)
  if (string.sub(message, 1, 4) == ".del") then
    removeCreature(message)
  elseif (message == ".next") then
    nextTurn("", "-1")
  elseif (message == ".stop") then
    stopInit()
    getStats(false)
  end
end

-- The main purpose of requiring confirmation is to prevent multiple people performing the same action.
function createConfirm(message, sender)
  if (message == ".next") then
    if (sender.color == creatures[turnNumber]["owner"]) then
      confirmed(message, sender)
      return
    else
      doPrint("It is not your turn.", false)
    end
  end

  if (confMsg == nil) then
    -- For destructive commands, confirm with the user.
    confirmTime = os.time()
    doPrint("Please confirm this action with '.confirm' or '.con'. Waiting for 10 seconds.", false)
    confMsg = message
    confSender = sender
  else
    -- If multiple people try to confirm at the same time, cancel all.
    doPrint("Conflicting requests received... Cancelling all.", false)
    confMsg = nil
    confSender = nil
  end
end

function checkConfirm(sender)
  if ((os.time() - confirmTime) > 20) then
    -- We only wait 20 seconds.
    doPrint("Confirm timed out, Reseting...", false)
    confMsg = nil
    confSender = nil
    return
  end

  if (confMsg == nil or confSender == nil) then
    doPrint("There is nothing to confirm.", false)
  elseif (not (sender.color == confSender.color)) then
    doPrint("You do not have a pending command.", false)
  else
    doPrint("Confirmed.", false)
    confirmed(confMsg, confSender) -- Do the prompted command.
    confMsg = nil
    confSender = nil
  end
end

function printHelp()
  doPrint("+Inititive CreatureName", false)
  doPrint("--Adds the specified creature to the encounter with that Inititive", false)
  doPrint(".del", false)
  doPrint("--Deletes the item at this turn number. (Starts at 1, false)")
  doPrint(".next", false)
  doPrint("--Forces the next turn button to be pressed.", false)
  doPrint(".start", false)
  doPrint("--Starts the encounter with the given creatures.", false)
  doPrint(".stop", false)
  doPrint("--Stops the encounter and clears the list.", false)
  doPrint(".stats", false)
  doPrint("--Prints the average time for each creature.", false)
  doPrint(".statsfull", false)
  doPrint("--Prints the full time stats for each creature.", false)
  doPrint(".swap X Y", false)
  doPrint("--Swaps player X and Player Y. (Used for ties, false)")
  doPrint(".goto X", false)
  doPrint("--sets the next turn to this player. (Does not increment round number, false)")
  doPrint(".XdY+Z", false)
  doPrint("--Rolls X dice with Y sides, adding Z to each die rolled. (Used for to hits, false)")
  doPrint(".XdY_Z", false)
  doPrint("--Rolls X dice with Y sides added together with the mod Z. (Used for damage, false)")
  doPrint(".help", false)
  doPrint("--Unknown, you should try it.", false)
end

function removeCreature(message)
  message = rgsub(message, ".del ", "")
  toDel = tonumber(message)
  if (turnNumber >= toDel) then
    turnNumber = turnNumber - 1
  end
  doPrint("deleting " .. toDel, false)
  table.remove(creatures, toDel)
  updateCreatures()
end

function getStats(isFull) -- Prints the stats for each creature.
  if (len(stats) == 0) then
    doPrint("No stats collected. Play some rounds.", false)
  end
  local numCreatures2 = len(stats)

  local i = 0
  for k, v in pairs(stats) do
    i = i + 1
    local name = k
    local tmp = 0
    local min = 9999999999
    local max = -9999999999
    local num = 0
    for j = 1, len(stats[name]) do
      if (tonumber(stats[name][j]) < 600) then
        num = num + 1
        tmp = tmp + stats[name][j]
        if (stats[name][j] < min) then
          min = stats[name][j]
        end
        if (stats[name][j] > max) then
          max = stats[name][j]
        end
      end
    end
    if (num > 1) then
      tmp = tmp / num
    end
    if (isFull) then
      local statTxt = name ..
          "=> Avg: " ..
          math.floor(tonumber(tmp)) ..
          "s Min: " ..
          math.floor(tonumber(min)) .. "s Max: " .. math.floor(tonumber(max)) .. "s Turns: " .. math.floor(tonumber(num))
      doPrint(statTxt, false)
    else
      doPrint(name .. " => " .. math.floor(tonumber(tmp)))
    end
  end
end

function checkTurnNumber() -- Logic for round counting
  if (not isCombatStarted) then
    roundNumber = 1
    return
  end
  if (turnNumber > numCreatures) then
    roundNumber = roundNumber + 1
    doPrint("Top of the round! Round #" .. roundNumber, false)
    turnNumber = 1
  end
end

function showNumbers() -- Show creatures with their index in the array.
  showNumbersb = not showNumbersb
  updateCreatures()
end

function nextTurn(userData, newTurnNumber) -- Note: userData is not used. However, it's being sent from the button. The button fails without it.
  if (newTurnNumber == "-1") then
  else
    printToColor("Don't do that.", userData.color)
    return -- -2 means right click. -3 means middle click.
  end

  updateCreatures()
  numCreatures = len(creatures)
  if (not isCombatStarted and numCreatures > 0) then
    doPrint("Warning: Combat has not been started yet. To start, type .start", false)
    return
  elseif (not isCombatStarted) then
    doPrint("No creatures defined. Please add creatures with \"+inititive Creature Name\"")
    return
  end

  if (turnNumber < 0 or turnNumber > numCreatures or turnNumber == nil or nextTurn == '') then
    doPrint("There was an error in the turn number. It has been reset to start.", false)
    turnNumber = 1
  end
  --doPrint((os.time(, false) - lastNext))
  if ((os.time() - lastNext) < 0.15) then
    local tmp1 = (os.time() - lastNext)
    local tmp2 = f_round(tmp1, 2)
    doPrint("Please wait 1.5 seconds between next turns. (" .. tmp2 .. "s)") --math.floor((os.time() - lastNext),2))
    --doPrint("This function is broken. You need to wait 1.5 seconds.")--math.floor((os.time() - lastNext),2))
    return
  end
  lastNext = os.time()

  checkTurnNumber()
  doPrint("_length of stats: " .. len(stats), true)
  if (stats[creatures[turnNumber].name] == nil) then
    stats[creatures[turnNumber].name] = {}
  end
  doPrint("length of stats: " .. len(stats), true)


  local tmp = os.time() - lastTime
  --doPrint("length of stats2: " .. len(stats[creatures[turnNumber].name], false))
  table.insert(stats[creatures[turnNumber].name], tmp)
  --doPrint("length of stats2: " .. len(stats[creatures[turnNumber].name], false))
  lastTime = os.time()


  local patt = '[0-9]+'
  local isNum = string.match(newTurnNumber, patt)

  doPrint("turnNumber: ", true)
  doPrint(turnNumber, true)
  doPrint("numCreatures: ", true)
  doPrint(numCreatures, true)
  doPrint("isNum: ", true)
  doPrint(isNum, true)




  local NextTurnNumberInt = tonumber(newTurnNumber)
  if (NextTurnNumberInt == -1) then
    debugMessage("Incrementing turn number")
    turnNumber = turnNumber + 1
  else
    debugMessage("Setting custom turnNumber")
    debugMessage(newTurnNumber)
    doPrint("NextTurnNumberInt: ", true)
    doPrint(NextTurnNumberInt, true)
    doPrint("newTurnNumber: ", true)
    doPrint(newTurnNumber, true)
    if (NextTurnNumberInt < 0 or NextTurnNumberInt > numCreatures) then
      doPrint("That creature does not exist...", false)
      return
    end
    turnNumber = NextTurnNumberInt
  end





  checkTurnNumber()

  local msg = creatures[turnNumber].name .. "'s Turn!";
  broadcastAll(msg);
  self.UI.setAttribute("nxtBtn", "visibility", creatures[turnNumber].owner)
  UI.setAttribute("nxtBtn", "visibility", creatures[turnNumber].owner)
  debugMessage("Setting visibility to: " .. creatures[turnNumber].owner)
  currentVisibility = creatures[turnNumber].owner
  updateCreatures()
end

function f_round(num, numDecimalPlaces)
  if numDecimalPlaces and numDecimalPlaces > 0 then
    local mult = 10 ^ numDecimalPlaces
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function removePrefix(input_string)
  local _, index = string.find(input_string, " ")
  if index then
    return string.sub(input_string, index + 1)
  end
  return ""
end

function addCreature(message, color, steam_name)
  message = rgsub(message, "+", "")
  debugMessage("addCreature: |" .. message .. "|")

  --This if statement is because of Stebe.
  if (string.match(message, "%(.*%)")) then             -- % shows that the character needs to be taken litterally. Normally "\(" in other languages.
    message = string.gsub(message, "%(.*%)", "(idiot)") --if you try to add a fake color in your monster name, it gets replaced.
  end

  local tmp = split(message, " ")
  local initNum = tmp[1]
  local isNum = string.match(initNum, '[0-9]+') -- verify this is a number via regex
  debugMessage("(initNum|isNum) = (" .. initNum .. "|" .. isNum .. ")")
  if (isNum == nil) then
    doPrint("Not a number. Inititive needs to be a number", false)
    return
  end

  local creatureName = removePrefix(message)
  debugMessage("creatureName :" .. creatureName .. ":")


  if (creatureName == nil or creatureName == "") then
    printToAll("There was an error with the name of the monster. Please try again. Defaulting to Player name")
    creatureName = string.sub(steam_name, 1, 8)
  end

  if (numCreatures > 0) then
    if DEBUG_MODE then
      dumper(creatures, "creatures", 0)
      dumper(creatures[turnNumber], "creatures[turnNumber]", 0)
      dumper(creatures[turnNumber]["init"], "creatures[turnNumber][\"init\"]", 0)
    end
    if (tonumber(creatures[turnNumber]["init"]) < tonumber(initNum)) then
      turnNumber = turnNumber + 1
    end
  end

  if (creatureName == nil) then
    doPrint("No name entered.", false)
    return
  end

  --doPrint(a, false)
  --doPrint(_BoolVar_, false)

  --doPrint("init: " .. a .. ". Name: " .. _BoolVar_, false)
  --dumpArr({"init: ", a , "Name: ", _BoolVar_}, "raw creature data")
  local tmp = {}
  tmp["init"] = tonumber(initNum)
  tmp["name"] = creatureName
  tmp["owner"] = color --"host"
  --dump(creatures)
  --dump(tmp)
  dumper(creatures, "creatures", 0)
  table.insert(creatures, tmp)
  --creatures.insert(tmp)

  updateCreatures()
end

function stopInit() -- Stops the current session.
  isCombatStarted = false
  creatures = {}
  --stats = {}    turnNumber = 1
  numCreatures = 0
  turnNumber = 1
  currentVisibility = "clubs"
  UI.setAttribute("nxtBtn", "visibility", "clubs")
  updateCreatures()
end

function doSwap(message) -- Swaps two creatures's places
  --dumper(creatures, "doSwap", 0)
  local tmp = split(message, " ")

  local first = tonumber(tmp[2])
  local second = tonumber(tmp[3])
  if (first > numCreatures or second > numCreatures) then
    doPrint("That number is out of range.", false)
    return
  end
  --doPrint(first, true)
  --doPrint(second, true)

  local tmp2 = creatures[first] -- TODO: add nil checks
  creatures[first] = creatures[second]
  creatures[second] = tmp2

  updateCreatures()
end

function onSave() -- BUILT IN FUNCTION. Happens on save.
  if (numCreatures <= 0) then
    return ""
  end

  lastSave = os.date("Last save: %H:%M:%S%p")

  local saved = {}
  saved["stats"] = stats
  saved["lastTime"] = lastTime
  saved["roundNumber"] = roundNumber
  saved["showNumbersb"] = showNumbersb
  saved["currentVisibility"] = currentVisibility
  saved["creatures"] = creatures
  saved["turnNumber"] = turnNumber
  saved["numCreatures"] = numCreatures
  local json = JSON.encode_pretty(saved)
  updateCreatures()
  return json
end

--Allows checking if the array is empty
function table.empty(self)
  for _, _ in pairs(self) do
    return false
  end
  return true
end

function debugMessage(msg)
  if (DEBUG_MODE) then
    doPrint(msg, true)
  end
end

function startInit()
  if (isCombatStarted == true) then
    doPrint("Combat has already started...", false)
    return
  end
  isCombatStarted = true
  debugMessage("test123") --doPrint("startInit(, false)")
  if (numCreatures == 0) then
    doPrint("No creatures added. use +Inititive CreatureName first.", false)
    return
  end
  lastTime = os.time()
  stats = {}
  turnNumber = 1
  roundNumber = 1
  broadcastAll("Number of Creatures: " .. numCreatures)

  broadcastAll(creatures[turnNumber].owner .. "'s Turn!");
  UI.setAttribute("nxtBtn", "visibility", creatures[turnNumber].owner)
  debugMessage("Setting visibility to: " .. creatures[turnNumber].owner)
  currentVisibility = creatures[turnNumber].owner
  updateCreatures()
  doPrint("Top of the round! Round #" .. roundNumber, false)
  --local current_timestamp = os.time()
  --local current_time = os.date("%Y-%m-%d %H:%M:%S", current_timestamp)
  --print("finished loading")
  --print(current_time)
end

function broadcastAll(msg)
  rgb = { r = 1, g = 1, b = 1 }
  broadcastToAll(msg, rgb) -- built in function
end

function compare(a, b)
  return tonumber(a["init"]) > tonumber(b["init"])
end

--[[
  This function does the actual text on the ui.
    It concatenates the creature name, init, and owner.
    Specifically in the format of [init]: [name] ([owner's color])
  ]]
function updateCreatures()
  --broadcastAll("B_numCreatures: " .. numCreatures)
  --broadcastAll("B_turnNumber: " .. turnNumber)

  checkTurnNumber()
  --[[
      By default, Lua uses an unstable sort. This means that when a large list of creatures get sorted,
      creatures with the same init, can get randomly reordered. Since we're forcing a stable sort here,
      that is not an issue. Order will be preserved.
      ]]
  table.stable_sort(creatures, compare)
  --sortCreatures(creatures)
  numCreatures = len(creatures)

  local CreatureListTxt = ""
  if (isCombatStarted) then
    CreatureListTxt = "Round #" .. roundNumber .. "\n"
  elseif (numCreatures > 0) then
    CreatureListTxt = "Setup Phase\n"
  else
    CreatureListTxt = "" -- If we have no creatures, we don't want to display anything
  end

  for i = 1, numCreatures do -- Here we loop through the creatures table
    if (i == turnNumber and isCombatStarted) then
      CreatureListTxt = CreatureListTxt ..
          "> " -- This is the current turn, so we add a ">" to the front of the line
    end
    if (showNumbersb) then
      CreatureListTxt = CreatureListTxt ..
          "[" ..
          i ..
          "] " -- If we have show numbers enabled, this is the reference number. Note: lua arrays start at 1, not 0
    end

    CreatureListTxt = CreatureListTxt ..
        creatures[i]["init"] ..
        ": " ..
        creatures[i]["name"] ..
        " (" ..
        creatures[i]["owner"] ..
        ")" ..
        "\n" -- This is the actual text that gets displayed
  end

  if (lastSave == nil) then
  else
    CreatureListTxt = CreatureListTxt ..
        lastSave                                                                             -- If we have a last save, we add the last save (time) to the text.
  end
  UI.setValue("turnOrder", CreatureListTxt)                                                  -- Same as above, but the global ui (Player's screen).
  if (numCreatures > 0) then
    self.UI.setValue("turnOrder", CreatureListTxt)                                           -- Here we set the text value of the Text UI element "turnOrder" to our concatenated string. This is the game board.
  else
    self.UI.setValue("turnOrder", "Type +{inishudiv} {player name} to add players/monsters") -- If we have no creatures, we want to display a message telling the players how to add creatures.
  end
end

function onNextClick(player, value, id) -- Called when the next button gets clicked.
  --doPrint(player.steam_name, false)
  --doPrint(id, false)
  onNext()
end

function onNext()
  counter = counter + 1
  if (counter > numPlayers) then -- TODO: problem?
    counter = 1
  end
  broadcastAll(players[counter].color .. "'s Turn!");
  UI.setAttribute("nxtBtn", "visibility", players[turnNumber].color)
  debugMessage("Setting visibility to: " .. creatures[turnNumber].owner)
  currentVisibility = creatures[turnNumber].owner

  updateTurn()
end

-- This function sets the visibility of the next button
function toggleHide()
  for i = 1, numPlayers do
    --doPrint(i, false)
    --players[i].UI.hide("nxtBtn")
    --self.UI.hide("nxtBtn")
    UI.setAttribute("nxtBtn", "visibility", players[turnNumber].color)
    debugMessage("Setting visibility to: " .. creatures[turnNumber].owner)
    currentVisibility = creatures[turnNumber].owner
  end
  bHide = not bHide
end

-- Provides the player's the ability to roll dice
function rollDice(message, playername)
  message = message:gsub(" ", "")

  local diceMathType = 0
  if string.match(message, "+") then
    diceMathType = 1 -- add mod to each roll (to hit)
  elseif string.match(message, "_") then
    diceMathType = 2 -- add dice together then add mod (damage rolls)
  else
    diceMathType = 1 --no mod, but roll them individually
  end
  diceNumbers = splitDiceString(message)

  numDice     = diceNumbers[1]
  diceMax     = diceNumbers[2]
  mod         = diceNumbers[3]
  if (mod == nil) then
    mod = 0
  end
  if (numDice <= 0) then
    doPrint("I'd like to see you try.", false)
  elseif (numDice > 100) then
    doPrint("Ok, what are you doing?", false)
  end


  if (numDice == nil or diceMax == nil) then
    debugMessage("playername: " .. playername)
    if (playername == "Embodiedawesomeness") then
      doPrint("Error in command", false)
    else
      broadcastAll("Look at this idiot, doesnt know how to use a command. Laugh at him.");
    end
    return
  end

  ret = ""

  if (diceMathType == 1) then
    for i = 1, numDice do
      ret = ret .. " " .. (math.random(diceMax) + mod) .. ","
    end
  end

  if (diceMathType == 2) then
    local totalRoll5 = 0
    for i = 1, numDice do
      --doPrint(i, false)
      --doPrint(totalRoll5, false)
      totalRoll5 = totalRoll5 + math.random(diceMax)
    end
    totalRoll5 = totalRoll5 + mod
    ret = totalRoll5
  end
  doPrint("." .. numDice .. "d" .. diceMax .. "+" .. mod .. " => " .. ret, false)
end

--hashmap = u(h("3247524C35494E75"))

--Replace all instances of a with b in message
function rgsub(message, a, b)
  return message:gsub(a, b)
end

function splitDiceString(message)
  debugMessage("Message1: " .. message)
  ret = {}
  message = string.sub(message, 2, -1)
  debugMessage("Message2: " .. message)
  message = message:gsub("d", ",")
  debugMessage("Message3: " .. message)
  message = message:gsub("+", ",")
  debugMessage("Message4: " .. message)
  message = message:gsub("_", ",")
  debugMessage("Message5: " .. message)
  ret = split(message, ",")
  --debugMessage("ret[0]: " .. ret[0])
  --debugMessage("ret[1]: " .. ret[1])
  --debugMessage("ret[2]: " .. ret[2])
  return ret
end

function len(obj)
  if (obj == nil) then
    return 0
  end
  local counter = 0
  for index in pairs(obj) do
    counter = counter + 1
  end
  return counter
end

function rotate()
  max = table.getn(players)
  counter = counter + 1
  if (counter > m) then
    counter = 1 --lua starts at 1...
  end
end

function istable(t)
  return type(t) == 'table'
end

function dumper(variable, identifier, counter)
  if not DEBUG_MODE then
    return
  end

  if counter == 0 then
    doPrint("\n<dumper identifier=\"" .. identifier .. "\">")
  end
  local tabs = ""
  for i = 1, counter do
    tabs = tabs .. "-"
  end
  doPrint(identifier .. " - " .. counter, true)
  if (variable == nil) then
    doPrint("nil", true)
    return
  end
  doPrint(type(variable, true))
  if (istable(variable)) then
    for key, value in pairs(variable) do
      if (istable(value)) then
        doPrint(key .. " => ", true)
        dumper(value, identifier, counter + 1)
      else
        print(tabs .. key .. " => " .. tostring(value))
      end
    end
  else
    doPrint("<variable>")
    doPrint(variable, true)
    doPrint("</variable>")
  end
  if counter == 0 then
    doPrint("</dumper>\n")
  end
end

function split(str, pat)
  debugMessage("str: " .. str)
  debugMessage("pat: " .. pat)
  local t = {} -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pat
  debugMessage("fpat: " .. fpat)
  local last_end = 1
  debugMessage("last_end: " .. last_end)
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t, cap)
    end
    last_end = e + 1
    s, e, cap = str:find(fpat, last_end)
  end
  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end
  return t
end

---------START SORT FUNCTIONS---------
local _sort_core = {}

--tunable size for
_sort_core.max_chunk_size = 24

function _sort_core.insertion_sort_impl(array, first, last, less)
  for i = first + 1, last do
    local k = first
    local v = array[i]
    for j = i, first + 1, -1 do
      if less(v, array[j - 1]) then
        array[j] = array[j - 1]
      else
        k = j
        break
      end
    end
    array[k] = v
  end
end

function _sort_core.merge(array, workspace, low, middle, high, less)
  local i, j, k
  i = 1
  -- copy first half of array to auxiliary array
  for j = low, middle do
    workspace[i] = array[j]
    i = i + 1
  end
  -- sieve through
  i = 1
  j = middle + 1
  k = low
  while true do
    if (k >= j) or (j > high) then
      break
    end
    if less(array[j], workspace[i]) then
      array[k] = array[j]
      j = j + 1
    else
      array[k] = workspace[i]
      i = i + 1
    end
    k = k + 1
  end
  -- copy back any remaining elements of first half
  for k = k, j - 1 do
    array[k] = workspace[i]
    i = i + 1
  end
end

function _sort_core.merge_sort_impl(array, workspace, low, high, less)
  if high - low <= _sort_core.max_chunk_size then
    _sort_core.insertion_sort_impl(array, low, high, less)
  else
    local middle = math.floor((low + high) / 2)
    _sort_core.merge_sort_impl(array, workspace, low, middle, less)
    _sort_core.merge_sort_impl(array, workspace, middle + 1, high, less)
    _sort_core.merge(array, workspace, low, middle, high, less)
  end
end

--inline common setup stuff
function _sort_core.sort_setup(array, less)
  local n = #array
  local trivial = false
  --trivial cases; empty or 1 element
  if n <= 1 then
    trivial = true
  else
    --default less
    less = less or function(a, b)
      return a < b
    end
    --check less
    if less(array[1], array[1]) then
      error("invalid order function for sorting")
    end
  end
  --setup complete
  return trivial, n, less
end

--linkedSet_Sorted = u(h("644D4E6D3247524C35494E752F555F5F"))

function _sort_core.stable_sort(array, less)
  --setup
  local trivial, n, less = _sort_core.sort_setup(array, less)
  if not trivial then
    --temp storage
    local workspace = {}
    workspace[math.floor((n + 1) / 2)] = array[1]
    --dive in
    _sort_core.merge_sort_impl(array, workspace, 1, n, less)
  end
  return array
end

function _sort_core.insertion_sort(array, less)
  --setup
  local trivial, n, less = _sort_core.sort_setup(array, less)
  if not trivial then
    _sort_core.insertion_sort_impl(array, 1, n, less)
  end
  return array
end

--export sort core
table.insertion_sort = _sort_core.insertion_sort
table.stable_sort = _sort_core.stable_sort
table.unstable_sort = table.sort
---------END SORT FUNCTIONS---------
