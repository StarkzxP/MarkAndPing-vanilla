# Map and Ping Vanilla

## Some Info

This is a modified version of my WoW Classic addon to work with WoW 1.12, it has some limitations compared to the WoW Classic version.

-   You can't use the addon while you're alone since raid marks don't work without being in a group.
-   You have to target the NPC to mark it instead of mouseover.
-   You need to be near your group leader for it to actually mark the NPC.

These limitations are due to the fact that WoW Vanilla does not allow raid markers to be placed by party members, only by the leader. Therefore, when a party member marks an NPC, the addon makes the leader mark it internally.

If the group leader doesn't install the addon, it won't work.

## Description

This addon for WoW Vanilla aims to replicate the ping functionality of WoW Retail as closely as possible. Due to API limitations, it's not a 100% recreation, but it still provides a highly useful tool for quickly marking monsters, players, or NPCs.

With easy-to-use features, players can quickly place raid markers on important targets, making coordination in both PvE and PvP scenarios more efficient. While not identical to the Retail version, this addon offers great functionality for target management in WoW Vanilla.

## How to Use:

-   First, assign a hotkey in the WoW keybindings menu. Look for "Mark and Ping" in the list, and choose a key that suits you. You can assign any key you prefer for quick access to the addon’s functionality.
-   Next, target an NPC, monster, or player and press the assigned key to mark them. This will send an alert to all group members and place a raid marker on the selected unit.

## Commands:

-   **/mping volume** <high|medium|low> – Set the volume level for the ping sound (defaults to medium).
-   **/mping ping** – Plays the ping sound for testing.
