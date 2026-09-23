--// Initializes the game’s client-side systems by loading player data and starting modules for inventory, crates, chat, shop, settings, rewards, rounds, and UI features.

wait()
local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");

repeat wait() until Players.LocalPlayer
local Player = Players.LocalPlayer;
local Modules = script.Parent:WaitForChild("Client Modules");

local FetchClientData = ReplicatedStorage.Remotes["Remote Functions"]:WaitForChild("Client Data");
local Data = FetchClientData:InvokeServer(Player);

local _Cases = require(Modules.__Cases);
local _Chat = require(Modules.__Chat);
local _Shop = require(Modules.__Shop);
local _Loading = require(Modules.__Loading);
local _Inventory = require(Modules.__Inventory);
local _Settings = require(Modules.__Settings);
local _Rounds = require(Modules.__Rounds);
local _Rewards = require(Modules.__Rewards);
local _Help = require(Modules.__Help);
local _Invite = require(Modules.__Invite);


_Inventory:Int()
_Cases:Int()
_Chat:Int()
_Shop:Int()
_Settings:Int()
_Help:Int()
_Rewards:Int()
_Loading:Int()
_Invite:Int()
_Rounds:Int()




