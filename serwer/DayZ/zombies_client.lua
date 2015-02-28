
myZombies = { }
resourceRoot = getResourceRootElement()





function playerdead ()
    setTimer ( Zomb_release, 4000, 1 )
end
addEventHandler ( "onClientPlayerWasted", getLocalPlayer(), playerdead )




function Zomb_release ()
    for k, ped in pairs( myZombies ) do
        if (isElement(ped)) then
            if (getElementData (ped, "zombie") == true) then
                setElementData ( ped, "target", nil )
                setElementData ( ped, "status", "idle" )
                table.remove(myZombies,k)
            end
        end
    end
end



--REMOVES A ZOMBIE FROM INFLUENCE AFTER ITS KILLED
function pedkilled ( killer, weapon, bodypart )
    if (getElementData (source, "zombie") == true) and (getElementData (source, "status") ~= "dead" ) then
        setElementData ( source, "target", nil )
        setElementData ( source, "status", "dead" )
    end
end
addEventHandler ( "onClientPedWasted", getRootElement(), pedkilled )



-- Isso verifica todos os zumbis em cada segundo para ver se eles estão à vista
function zombie_check ()
    if (getElementData (getLocalPlayer (), "zombie") ~= true) and ( isPedDead ( getLocalPlayer () ) == false ) then
        local zombies = getElementsByType ( "ped",getRootElement(),true )
        local Px,Py,Pz = getElementPosition( getLocalPlayer () )
        if isPedDucked ( getLocalPlayer ()) then
            local Pz = Pz-1
        end     
        for theKey,theZomb in ipairs(zombies) do
            if (isElement(theZomb)) then
                local Zx,Zy,Zz = getElementPosition( theZomb )
                if (getDistanceBetweenPoints3D(Px, Py, Pz, Zx, Zy, Zz) < 45 ) then
                    if (getElementData (theZomb, "zombie") == true) then
                        if ( getElementData ( theZomb, "status" ) == "idle" ) then --CHECKS IF AN IDLE ZOMBIE IS IN SIGHT
                            local isclear = isLineOfSightClear (Px, Py, Pz+1, Zx, Zy, Zz +1, true, false, false, true, false, false, false) 
                            if (isclear == true) then
                                setElementData ( theZomb, "status", "chasing" )
                                setElementData ( theZomb, "target", getLocalPlayer() )
                                table.insert( myZombies, theZomb ) --ADDS ZOMBIE TO PLAYERS COLLECTION
                                table.remove( zombies, theKey)
                                zombieradiusalert (theZomb)
                            end
                        elseif (getElementData(theZomb,"status") == "chasing") and (getElementData(theZomb,"target") == nil) then --CHECKS IF AN AGGRESSIVE LOST ZOMBIE IS IN SIGHT
                            local isclear = isLineOfSightClear (Px, Py, Pz+1, Zx, Zy, Zz +1, true, false, false, true, false, false, false) 
                            if (isclear == true) then
                                setElementData ( theZomb, "target", getLocalPlayer() )
                                isthere = "no"
                                for k, ped in pairs( myZombies ) do
                                    if ped == theZomb then
                                        isthere = "yes"
                                    end
                                end
                                if isthere == "no" then
                                    table.insert( myZombies, theZomb ) --ADDS THE WAYWARD ZOMBIE TO THE PLAYERS COLLECTION
                                    table.remove( zombies, theKey)
                                end
                            end
                        elseif ( getElementData ( theZomb, "target" ) == getLocalPlayer() ) then --CHECKS IF AN ALREADY AGGRESSIVE ZOMBIE IS IN SIGHT
                            local isclear = isLineOfSightClear (Px, Py, Pz+1, Zx, Zy, Zz +1, true, false, false, true, false, false, false) 
                            if (isclear == false) then --IF YOUR ZOMBIE LOST YOU, MAKES IT REMEMBER YOUR LAST COORDS
                                setElementData ( theZomb, "target", nil )
                                triggerServerEvent ("onZombieLostPlayer", theZomb, oldPx, oldPy, oldPz)
                            end
                        end
                    end
                end
            end
        end
    -- este segundo semestre é para verificação de pediatria e zumbis
    
        local nonzombies = getElementsByType ( "ped",getRootElement(),true )
        for theKey,theZomb in ipairs(zombies) do
            if (isElement(theZomb)) then
                if (getElementData (theZomb, "zombie") == true) then
                    local Zx,Zy,Zz = getElementPosition( theZomb )
                    for theKey,theNonZomb in ipairs(nonzombies) do
                        if (getElementData (theNonZomb, "zombie") ~= true) then -- if the ped isnt a zombie
                            local Px,Py,Pz = getElementPosition( theNonZomb )
                            if (getDistanceBetweenPoints3D(Px, Py, Pz, Zx, Zy, Zz) < 45 ) then
                                local isclear = isLineOfSightClear (Px, Py, Pz+1, Zx, Zy, Zz +1, true, false, false, true, false, false, false ) 
                                if (isclear == true) and ( getElementHealth ( theNonZomb ) > 0) then
                                    if ( getElementData ( theZomb, "status" ) == "idle" ) then --CHECKS IF AN IDLE ZOMBIE IS IN SIGHT
                                        triggerServerEvent ("onZombieLostPlayer", theZomb, Px, Py, Pz)                                  
                                        setElementData ( theZomb, "status", "chasing" )
                                        setElementData ( theZomb, "target", theNonZomb )
                                        zombieradiusalert (theZomb)
                                    elseif ( getElementData ( theZomb, "status" ) == "chasing" ) and ( getElementData ( theZomb, "target" ) == nil) then
                                        triggerServerEvent ("onZombieLostPlayer", theZomb, Px, Py, Pz)
                                        setElementData ( theZomb, "target", theNonZomb )                                    
                                    end
                                end                 
                            end     
                            if ( getElementData ( theZomb, "target" ) == theNonZomb ) then --CHECKS IF AN ALREADY AGGRESSIVE ZOMBIE IS IN SIGHT OF THE PED
                                local Px,Py,Pz = getElementPosition( theNonZomb )
                                if (getDistanceBetweenPoints3D(Px, Py, Pz, Zx, Zy, Zz) < 45 ) then
                                    local isclear = isLineOfSightClear (Px, Py, Pz+1, Zx, Zy, Zz+1, true, false, false, true, false, false, false) 
                                    if (isclear == false) then --IF YOUR ZOMBIE LOST THE PED, MAKES IT REMEMBER the peds LAST COORDS
                                        triggerServerEvent ("onZombieLostPlayer", theZomb, Px, Py, Pz)                          
                                        setElementData ( theZomb, "target", nil )
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    for k, ped in pairs( myZombies ) do
        if (isElement(ped) == false) then
            table.remove( myZombies, k)
        end
    end
    oldPx,oldPy,oldPz = getElementPosition( getLocalPlayer () )
end






function getGroundMaterial(x, y, z)
  local hit, hitX, hitY, hitZ, hitElement, normalX, normalY, normalZ, material = processLineOfSight(x, y, z, x, y, z - 10, true, false, false, true, false, false, false, false, nil)
  return material
end


function isInBuilding(x, y, z)
  local hit, hitX, hitY, hitZ, hitElement, normalX, normalY, normalZ, material = processLineOfSight(x, y, z, x, y, z + 10, true, false, false, true, false, false, false, false, nil)
  if hit then
    return true
  end
  return false
end


function isObjectAroundPlayer2(thePlayer, distance, height)
  material_value = 0
  local x, y, z = getElementPosition(thePlayer)
  for i = math.random(0, 360), 360 do
    local nx, ny = getPointFromDistanceRotation(x, y, distance, i)
    local hit, hitX, hitY, hitZ, hitElement, normalX, normalY, normalZ, material = processLineOfSight(x, y, z + height, nx, ny, z + height, true, false, false, false, false, false, false, false)
    if material == 0 then
      material_value = material_value + 1
    end
    if material_value > 40 then
      return 0, hitX, hitY, hitZ
    end
  end
  return false
end

function isObjectAroundPlayer(thePlayer, distance, height)
  local x, y, z = getElementPosition(thePlayer)
  for i = math.random(0, 360), 360 do
    local nx, ny = getPointFromDistanceRotation(x, y, distance, i)
    local hit, hitX, hitY, hitZ, hitElement, normalX, normalY, normalZ, material = processLineOfSight(x, y, z + height, nx, ny, z + height)
    if material == 0 then
      return material, hitX, hitY, hitZ
    end
  end
  return false
end


function getPointFromDistanceRotation(x, y, dist, angle)
  local a = math.rad(90 - angle)
  local dx = math.cos(a) * dist
  local dy = math.sin(a) * dist
  return x + dx, y + dy
end




---------------------------------------------------------------------------------------
-----------------------------------------------


function zombieSpawning()
  local x, y, z = getElementPosition(getLocalPlayer())
  local material, hitX, hitY, hitZ = isObjectAroundPlayer2(getLocalPlayer(), 30, 3)
  if material == 0 and not isInBuilding(x, y, z) and not isElementInWater(getLocalPlayer()) then
    triggerServerEvent("createZomieForPlayer", getLocalPlayer(), hitX, hitY, hitZ)
  end
end
setTimer(zombieSpawning, 5000, 0)



function onStealthKill(source, player, targetPlayer) 
--Cancelar Função Stealth Kill -- Para ligar criar a funcao no zombies.lua e tentar... sem killPed
cancelEvent()
--triggerServerEvent("onZombieGetsKilledttttt", source, player, targetPlayer)
end
addEventHandler("onClientPlayerStealthKill", getLocalPlayer(), onStealthKill) 


------------------------------------------------
---------------------------------------------------------------------------------------





function playZumbiRandomHitSound()
  --local number = math.random(1, 3)
  --playSound("sounds/hit" .. number .. ".mp3")
  local xplayz, yplayz, zplayz = getElementPosition(getLocalPlayer()) 
  local somhitz = playSound3D("sounds/hitmarker.wav", xplayz, yplayz, zplayz, false)
  setSoundMaxDistance(somhitz, 10)

end
addEvent( "zumbihit", true )
addEventHandler( "zumbihit", getRootElement(), playZumbiRandomHitSound) 



 ---------------------------------------------------------------------------------------               
------------------------------------------------


--MAKES A ZOMBIE JUMP
addEvent( "Zomb_Jump", true )
function Zjump ( ped )
    if (isElement(ped)) then
        setPedControlState( ped, "jump", true )
        setTimer ( function (ped) if ( isElement ( ped ) ) then setPedControlState ( ped, "jump", false) end end, 800, 1, ped )
    end
end
addEventHandler( "Zomb_Jump", getRootElement(), Zjump )

--MAKES A ZOMBIE PUNCH
addEvent( "Zomb_Punch", true )
function Zpunch ( ped )
    if (isElement(ped)) then
    --local actionsd = math.random( 1, 2 )
    --if actionsd == 1 then
    --setPedAnimation(ped, "riot", "RIOT_PUNCHES", false, false, true)
    --else
    -- setPedAnimation(ped, "knife", "knife_1", false, false, true)
    --end

    --setPedAnimation(ped, "knife", "KILL_Knife_Player", false, false, true)
        --showZumbiDamageScreen(0, "up")
        --tentar, if getDistanceBetweenPoints3D < 1 hit + mage + som
        --zmoan(getLocalPlayer())
        setPedControlState( ped, "fire", true )
        setTimer ( function (ped) if ( isElement ( ped ) ) then setPedControlState ( ped, "fire", false) end end, 800, 1, ped )
    end
end
addEventHandler( "Zomb_Punch", getRootElement(), Zpunch )



--MAKES A ZOMBIE STFU
addEvent( "Zomb_STFU", true )
function Zstfu ( ped )
    if (isElement(ped)) then
        setPedVoice(ped, "PED_TYPE_DISABLED")
    end
end
addEventHandler( "Zomb_STFU", getRootElement(), Zstfu )



--MAKES A ZOMBIE MOAN
addEvent( "Zomb_Moan", true )
function Zmoan ( ped, randnum )
    if (isElement(ped)) then
        local Zx,Zy,Zz = getElementPosition( ped )
        local sound = playSound3D("sounds/mgroan"..randnum..".ogg", Zx, Zy, Zz, false)
        setSoundMaxDistance(sound, 95)
    end
end
addEventHandler( "Zomb_Moan", getRootElement(), Zmoan )



---------------------------------------------------------
---------------------------------------------------------------------------------------






---------------------------------------------------------------------------------------
----------------------------------------------------------



function disableTargetMarkers()
    setPedTargetingMarkerEnabled(false) -- Desabilitar marcador verde de sangue encima da cabeça!
end
addEventHandler("onClientResourceStart", resourceRoot, disableTargetMarkers)


--INITAL SETUP
function clientsetupstarter(startedresource)
    if startedresource == getThisResource() then
        setTimer ( clientsetup, 1234, 1)
        MainClientTimer1 = setTimer ( zombie_check, 1000, 0)  --STARTS THE TIMER TO CHECK FOR ZOMBIES
    end
end
addEventHandler("onClientResourceStart", getRootElement(), clientsetupstarter)





function clientsetup()
    oldPx,oldPy,oldPz = getElementPosition( getLocalPlayer () )
    throatcol = createColSphere ( 0, 0, 0, .3)
    --woodpic = guiCreateStaticImage( .65, .06, .1, .12, "zombiewood.png", true )
    --guiSetVisible ( woodpic, false )

-- Todos os zumbis STFU
    local zombies = getElementsByType ( "ped" )
    for theKey,theZomb in ipairs(zombies) do
        if (isElement(theZomb)) then
            if (getElementData (theZomb, "zombie") == true) then
                setPedVoice(theZomb, "PED_TYPE_DISABLED")
            end
        end
    end
end


   
--UPDATES PLAYERS COUNT OF AGGRESIVE ZOMBIES
addEventHandler ( "onClientElementDataChange", getRootElement(),
function ( dataName )
    if getElementType ( source ) == "ped" and dataName == "status" then
        local thestatus = (getElementData ( source, "status" ))
        if (thestatus == "idle") or (thestatus == "dead") then      
            for k, ped in pairs( myZombies ) do
                if ped == source and (getElementData (ped, "zombie") == true) then
                    setElementData ( ped, "target", nil )
                    table.remove( myZombies, k)
                    setElementData ( getLocalPlayer(), "dangercount", tonumber(table.getn( myZombies )) )
                end
            end
        end
    end
end )




-- Ataque dos zombis por traz e GUI STUFF
function movethroatcol ()
    --local screenWidth, screenHeight = guiGetScreenSize()
    --local dcount = tostring(table.getn( myZombies ))
    --dxDrawText( dcount, screenWidth-40, screenHeight -50, screenWidth, screenHeight, tocolor ( 0, 0, 0, 255 ), 1.44, "pricedown" )
    --dxDrawText( dcount, screenWidth-42, screenHeight -52, screenWidth, screenHeight, tocolor ( 255, 255, 255, 255 ), 1.4, "pricedown" )
    
    if isElement(throatcol) then
        local playerrot = getPedRotation ( getLocalPlayer () )
        local radRot = math.rad ( playerrot )
        local radius = 1
        local px,py,pz = getElementPosition( getLocalPlayer () )
        local tx = px + radius * math.sin(radRot)
        local ty = py + -(radius) * math.cos(radRot)
        local tz = pz
        setElementPosition ( throatcol, tx, ty, tz )
    end
end
addEventHandler ( "onClientRender", getRootElement(), movethroatcol )



function choketheplayer ( theElement, matchingDimension )
    if getElementType ( theElement ) == "ped" and ( isPedDead ( getLocalPlayer () ) == false ) then
        if ( getElementData ( theElement, "target" ) == getLocalPlayer () ) and (getElementData (theElement, "zombie") == true) then
            local px,py,pz = getElementPosition( getLocalPlayer () )
            setTimer ( checkplayermoved, 600, 1, theElement, px, py, pz)
        end
    end
end
addEventHandler ( "onClientColShapeHit", getRootElement(), choketheplayer )




function checkplayermoved (zomb, px, py, pz)
    if (isElement(zomb)) then
        --outputChatBox ( "ccccc", player, 0, 238, 0, true )
        local nx,ny,nz = getElementPosition( getLocalPlayer () )
        local distance = (getDistanceBetweenPoints3D (px, py, pz, nx, ny, nz))
        if (distance < .7) and ( isPedDead ( getLocalPlayer () ) == false ) then
                --outputChatBox ( "Zumbi vai atacar ^^", player, 0, 238, 0, true )
            setElementData ( zomb, "status", "throatslashing" )
        end
    end
end




-- ZOMBIES ALERTAS QUALQUER IDLE num raio de 10 tiros QUANDO OCORRER OU outros zumbis ter alertado
function zombieradiusalert (theElement)
    local Px,Py,Pz = getElementPosition( theElement )
    local zombies = getElementsByType ( "ped" )
    for theKey,theZomb in ipairs(zombies) do
        if (isElement(theZomb)) then
        if (getElementData (theZomb, "zombie") == true) then
            if ( getElementData ( theZomb, "status" ) == "idle" ) then
               local Zx,Zy,Zz = getElementPosition( theZomb )
               local distance = (getDistanceBetweenPoints3D (Px, Py, Pz, Zx, Zy, Zz))
               if (distance < 10) and ( isPedDead ( getLocalPlayer () ) == false ) then
                isthere = "no"
                for k, ped in pairs( myZombies ) do
                if ped == theZomb then
                   isthere = "yes"
                end
                end
                
                if isthere == "no" and (getElementData (getLocalPlayer (), "zombie") ~= true) then
                if (getElementType ( theElement ) == "ped") then
                   local isclear = isLineOfSightClear (Px, Py, Pz, Zx, Zy, Zz, true, false, false, true, false, false, false) 
                   if (isclear == true) then
                        setElementData ( theZomb, "status", "chasing" )
                        setElementData ( theZomb, "target", getLocalPlayer () )
                        table.insert( myZombies, theZomb ) --ADDS ZOMBIE TO PLAYERS COLLECTION
                   end
                else
                        setElementData ( theZomb, "status", "chasing" )
                        setElementData ( theZomb, "target", getLocalPlayer () )
                        table.insert( myZombies, theZomb ) --ADDS ZOMBIE TO PLAYERS COLLECTION
                end
                end
               end
            end
        end
        end
    end
end








function shootingnoise ( weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
    if alertspacer ~= 1 then
        if (weapon == 9) then
            alertspacer = 1
            setTimer ( resetalertspacer, 5000, 1 )
            zombieradiusalert(getLocalPlayer ())
        elseif (weapon > 21) and (weapon ~= 23) then
            alertspacer = 1
            setTimer ( resetalertspacer, 5000, 1 )
            zombieradiusalert(getLocalPlayer ())
        end
    end
    if hitElement then
        if (getElementType ( hitElement ) == "ped") then
            if (getElementData (hitElement, "zombie") == true) then         
                isthere = "no"
                for k, ped in pairs( myZombies ) do
                    if ped == hitElement then
                        isthere = "yes"
                    end
                end
                if isthere == "no" and (getElementData (getLocalPlayer (), "zombie") ~= true) then
                    setElementData ( hitElement, "status", "chasing" )
                    setElementData ( hitElement, "target", getLocalPlayer () )
                    table.insert( myZombies, hitElement ) --ADDS ZOMBIE TO PLAYERS COLLECTION
                    zombieradiusalert (hitElement)
                end
            end
        end
    end
end
addEventHandler ( "onClientPlayerWeaponFire", getLocalPlayer (), shootingnoise )






function resetalertspacer ()
    alertspacer = nil
end

function choketheplayer ( theElement, matchingDimension )
    if getElementType ( theElement ) == "ped" and ( isPedDead ( getLocalPlayer () ) == false ) and (getElementData (theElement , "zombie") == true) then
        if ( getElementData ( theElement, "target" ) == getLocalPlayer () ) then
            local px,py,pz = getElementPosition( getLocalPlayer () )
            setTimer ( checkplayermoved, 600, 1, theElement, px, py, pz)
        end
    end
end






addEvent( "Spawn_Placement", true )
function Spawn_Place(xcoord, ycoord)
    local x,y,z = getElementPosition( getLocalPlayer() )
    local posx = x+xcoord
    local posy = y+ycoord
    local gz = getGroundPosition ( posx, posy, z+500 )
    triggerServerEvent ("onZombieSpawn", getLocalPlayer(), posx, posy, gz+1 )
end
addEventHandler("Spawn_Placement", getRootElement(), Spawn_Place)




function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end





----------------------------------------------
---------------------------------------------------------------------------------------


  
---------------------------------------------------------------------------------------
------------------------------------------------- 
  





function pedGetDamageDayZ(attacker, weapon, bodypart, loss, zombie)
  --cancelEvent()
  if attacker and attacker == getPedOccupiedVehicle(getLocalPlayer()) and not getElementData(source, "isDead") == true then
     attacker2 = getLocalPlayer()
     
    morloggg = false 
    if (bodypart == 9  or bodypart == 3 or bodypart == 4 or bodypart == 5 or bodypart == 6 or bodypart == 7 or bodypart == 8)then
    --outputChatBox ( "HIT de carro em zumbi", 255, 0, 0 ) -- We output a warning to him.
    damagedd = math.random(550, 850)
    end 
    
    
    setElementData(source, "blood", getElementData(source, "blood") - damagedd) 
    
    local healthss = math.floor(getElementHealth(source))
    --outputChatBox ( "Vida do zumbi s atropelado heal: "..healthss, 255, 0, 0 ) -- We output a warning to him.
    --outputChatBox ( "Vida do zumbi s atropelado dayz: "..damagedd, 255, 0, 0 ) -- We output a warning to him.
    
    if healthss <= 35 then
    setElementData(source, "blood",0)
    --outputChatBox ( "Zumbi Morreu ATROPELADO Antes da Hora ... ", 255, 255, 0 )
    morloggg = true 
    triggerServerEvent("onZombieGetsKilled", source, attacker2, headshot, zombie, weapon)
    --setElementHealth ( source, 100 )
    end
      
  
    if getElementData(source, "blood") <= 0 and morloggg == false then
    --outputChatBox ( "Zumbi Morreu ATROPELADO ", 255, 255, 0 ) 
    triggerServerEvent("onZombieGetsKilled", source, attacker2, headshot, zombie, weapon)
    end
    
    
    
    
  end
  
  
  if attacker and attacker == getLocalPlayer() then
    damage = 100
    morlog = false 
    if weapon == 37 then
      return
    end
    if weapon == 63 or weapon == 51 or weapon == 19 then
      setElementData(source, "blood", 0)
      if 0 >= getElementData(source, "blood") then
      triggerServerEvent("onZombieGetsKilled", source, attacker, zombie, weapon)
      end
    elseif weapon and weapon > 1 and attacker and getElementType(attacker) == "player" and getElementData(source, "animal") == false then
      damage = getWeaponDamage(weapon)
      
      
      if bodypart == 9 then

        headshot = true
  
        if (weapon == 24) or (weapon == 34) or  (weapon == 25) or (weapon == 26) or (weapon == 27) or (weapon == 339) then
            setPedHeadless(source, true)
            --outputChatBox ( "head Shot", 255, 0, 0 ) 
           
            damage = damage * 1.5
         
        else
            --outputChatBox ( "outra arma tira dano na cabeca", 255, 0, 0 ) -- We output a warning to him.
            damage = damage * 1.2 
        end
        
        
        
        
      elseif ( bodypart == 3 or bodypart == 4) then

            damage = damage * 0.2         
            headshot = false
            local idroupa = getElementModel ( source )
            --outputChatBox ( "HIT no Peito, Skin: "..idroupa, 255, 0, 0 )
            
            
            
      elseif ( bodypart == 5 or bodypart == 6 or bodypart == 7 or bodypart == 8) then
           damage = damage * 0.1
           headshot = false
           --outputChatBox ( "HIT no Braços ou Pernas", 255, 0, 0 ) -- We output a warning to him.
      end 
      

      setElementData(source, "blood", getElementData(source, "blood") - math.random(damage * 0.75, damage * 1.25))       --tira o dano de acordo com a variavel dano
      


      if getElementData(source, "blood") <= 0 and morlog == false and getElementData(source, "animal") == false then
      --outputChatBox ( "Zumbi Morreu ... ", 255, 255, 0 ) 
      triggerServerEvent("onZombieGetsKilled", source, attacker, headshot, zombie, weapon)
      end
    end
  end
end
addEventHandler("onClientPedDamage", getRootElement(), pedGetDamageDayZ)






----------------------------------------
---------------------------------------------------------------------------------------  

---------------------------------------------------------------------------------------
-------------------------------------------------  





--function checkZombies()
--  zombiesaliveee = 0
--  zombiestotal = 0
--  for i, ped in ipairs(getElementsByType("ped")) do
--    if getElementData(ped, "zombie") then
--    zombiesaliveee = zombiesaliveee + 1
--    end
--    if getElementData(ped, "deadzombie") then
--      zombiestotal = zombiestotal + 1
--    end
--  end
--  setElementData(getRootElement(), "zombiesalive", zombiesaliveee)
--  setElementData(getRootElement(), "zombiestotal", zombiestotal + zombiesaliveee)
--end
--setTimer(checkZombies, 5000, 0)




--function checkZombies3()
  --local x, y, z = getElementPosition(getLocalPlayer())
  --for i, ped in ipairs(getElementsByType("ped")) do
  --   if getElementData(ped, "zombie") then
    --  local sound = getElementData(getLocalPlayer(), "volume") / 5
      -- local visibly = getElementData(getLocalPlayer(), "visibly") / 5
      --  local xZ, yZ, zZ = getElementPosition(ped)
      --   if getDistanceBetweenPoints3D(x, y, z, xZ, yZ, zZ) < sound + visibly then
        --outputChatBox ( "Som correndo", player, 0, 238, 0, true )  
        --   if getElementData(ped, "leader") == nil then

   --     triggerServerEvent("botAttack", getLocalPlayer(), ped)
        --        --triggerServerEvent("createZomieForPlayer", getLocalPlayer(), hitX, hitY, hitZ)
          --     end
        --   else
      --     if getElementData(ped, "target") == getLocalPlayer() then
        --      --outputChatBox ( "Som parando de correr", player, 0, 238, 0, true ) 
          --       setElementData(ped, "target", nil)
   --       --      end
          --      if getElementData(ped, "leader") == getLocalPlayer() then
 --       --         outputChatBox ( "Som parando de correr", player, 0, 238, 0, true )  
 --         triggerServerEvent("botStopFollow", getLocalPlayer(), ped)
          --        end
        --      end
      --    end
    --  end
  --end
--setTimer(checkZombies3, 500, 0)






-----------------------------------------------
---------------------------------------------------------------------------------------  
