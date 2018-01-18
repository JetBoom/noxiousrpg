-- This is a way to store all the currently ACTIVE items on the server in an easy-to-reference data structure.
-- All items, regardless of what they happen to be, have a unique ID from GetUID() when they're created.
-- Items stores an Item object and uses the UID (a number) as the key.
-- Whenever an Item OBJECT is created, it is added to this table. All values in the table are weak (__mode = "v").
-- The Item object in this table is garbage collected if it ceases to exist in the world ie, not anywhere except this table.

Items = {}
if SERVER then
	setmetatable(Items, {__mode = "v"})
end
-- For now every client receives a network message when an item is destroyed on the server which then deletes it on their client.
