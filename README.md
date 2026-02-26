
Folder heirachy Base 📂: 
``` text
Workspace
  └── Bases
        └── Base0
              └── Floors
              |      └── Floor1
              |            └── Build 
              |            |      └── MainStructure
              |            |             └── pure materials nothing to script/outter layer and windows of foor1
              |            |      └── Barriers 
              |            |            └── Main (Folder) not in use.. (dont intend to use)
              |            |            └── BarrierSupport ( not actual lasers)
              |            |      └── Platforms
              |            |              └── Left
              |            |              |      └── Stand1 (Model)
              |            |              |            └── Important (Folder)
              |            |              |             |       └── Equipped (BoolValue)
              |            |              |             |       └── NPCName (string)
              |            |              |             └── Collect
              |            |              |             |      └── Text
              |            |              |             |            └── TextFrame
              |            |              |             |                  └── Amount
              |            |              |             |                  └── Header
              |            |              |             | 
              |            |              |             └── Placeholder 
              |            |              |                     └── NPCPlatform (folder)
              |            |              |      └── Stand2
              |            |              |      └──
              |            |              |      └──
              |            |              └── Right
              |            |                    └──
              |            |                    └──
              |            |                    └──
              |            |                    └──
              |            |              └── Left (empty folder)
              |            |              └── Right (empty folder)
              |            |              └── Lock (LockGui)/ can lock base but disabled this feature in this game
              |            |      └── Signs
              |            |            └── SignsPart
              |            |                  └── PlayerNameBase 
              |            |                          └── Owner (gui)
              |            |      └── Spawns
              |            └── Doors
              |                  └── Door1
              |                        └── Lasers
              |                        |      └── Laser1
              |                        |      └── Laser1
              |                        |      └── .... (actual lasers instance) to do lock mechanism ( already exists but disabled for this game)
              |                        └── Hitbox (Hitbox of laser is stored here) actual instance
              |                  └── Hitbox ( Hitbox of whole ground floor is stored here) actual instance
              |      └── Floor2 (Dont work at it rn) 
              └── Slots (Folder)
              |      └── Slot1 
              |       |     └── Collect (Instance)
              |       |     └── Spawn (Instance)
              |       |     └── Configuration (config)
              |       |             └── Rebirth (IntVal)
              |       |             └── Occupied (boolVal)
              |       |             └── Thing (ObjVal)
              |      └── Slot2
              |      └── ... slot14 (floor1 combined) 
              └── Spawn (Spawns player at this coords) 
              └── Configuration 
                      └── Player (ObjValue) Stores actual player instance here inside base 
        └── Base1
        └── Base2
        .... Base7
```

Folder Heirachy SpawnArea📂

```
workspace
    └── SpawnArea
            └── Area1
                  └── SpawnPlate ( we use this to spawn npcs)
                  └── (building blocsk) no functionality
```

Folder Heirachy NPCs📂 : 

```
ReplicatedStorage
      └── NPCs
            └── Haunter 
            |      └── Head
            |            └── NameGui
            |                  └── NpcName (text)
            |            └── PerSecondGui  
            |                    └── CashPerSecond
            |            └── RarityGui
            |                  └── Rarity
            |            └── TimerGui  
            |                    └── Time
            |            └── Value (Stores how much value to buy) gui
            |                  └── TextLabel
            └── hell nah
            └── noob
```
