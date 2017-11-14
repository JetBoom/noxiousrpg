-- This is a way to store all the currently ACTIVE items on the server in an easy-to-reference data structure.
-- All items, regardless of what they happen to be, have a unique ID from GetUID() when they're created.
-- Items stores an Item object and uses the UID (a number) as the key.
-- Whenever an Item OBJECT is created, it is added to this table. All values in the table are weak (__mode = "v").
-- The Item object in this table is garbage collected if it ceases to exist in the world ie, not anywhere except this table.

Items = {}
if SERVER then
	setmetatable(Items, {__mode = "v"})
end
-- The client just sort of has to absorb the resource hogging from this since lag and PVS can cause items to be garbage collected when they shouldn't be.
-- TODO: A better system that garbage collects correctly on both ends.
