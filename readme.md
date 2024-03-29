# Tabletop Simulator Initiative Tracker

## What is this?

This is a Tabletop simulator script that helps DnD players track their initiative.

## How do I install this?

Download the zip from the releases section and extract the archive to this location
```cmd
%homedrive%%homepath%\Documents\my games\Tabletop Simulator\Saves\Saved Objects\
```

## How do I use this?

First drag the item into the world from the saved objects box.

Now if you type ".help" (without quotes) into the chat box, you will see a full list of commands.

All commands are executed via chat.

Commands are
```
+Inititive CreatureName
--Adds the specified creature to the encounter with that Inititive
.del
--Deletes the item at this turn number. (Starts at 1, 
.next
--Forces the next turn button to be pressed
.start
--Starts the encounter with the given creatures
.stop
--Stops the encounter and clears the list
.stats
--Prints the average time for each creature
.statsfull
--Prints the full time stats for each creature
.swap X Y
--Swaps player X and Player Y. (Used for ties, 
.goto X
--sets the next turn to this player. (Does not increment round number, 
.XdY+Z
--Rolls X dice with Y sides, adding Z to each die rolled. (Used for to hits, 
.XdY_Z
--Rolls X dice with Y sides added together with the mod Z. (Used for damage, 
.help
--Unknown, you should try it
```

## Example

To add a creature run the command
```
+{Initiative} {Creature name}
```
Repeat this for each creature.

Once all creatures are present run the command ```.start```

The highest initiative will go first. (As per DND rules). Once the creature has finished its turn, the player controlling said creature will click the next turn button. Once the round is complete, the highest initiative will go again.

## Confirmation?

Some actions need to be confirmed. These are mostly destructive actions. e.g. deleting a character.
When prompted, to confirm an action type ```.con``` or ```.confirm```

Note: Multiple pending confimation will cancel all pending confimations.

## Encounter's done

When the encounter is over, you can stop the combat by typing ```.stop``` and ```.con```.

Now that the encounter is over, you can see who took the longest. Type ```.statsfull```.