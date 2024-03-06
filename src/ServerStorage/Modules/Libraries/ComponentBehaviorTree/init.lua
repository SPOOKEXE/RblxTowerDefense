export type ConditionTrueFalse = (...any?) -> boolean
export type ConditionSwitch = (...any?) -> number
export type Callback = (...any?) -> any?

export type TreeSequencerItem = { CurrentNodeID : string?, NextNodeCache : { string }, ConditionsAutoParams : { any }?, FunctionsAutoParams : { any }? }

local PERFORMANCE_PROFILING = false
local PERFORMANCE_PROFILING_DECIMAL_PLACES = 10e4 -- change the number AFTER the 'e'

-- // Variables // --
local HttpService = game:GetService("HttpService")

local Threader = require(script.Threader)

local NodeEnums = { Action = 1, ConditionTrueFalse = 2, ConditionSwitch = 3, ConditionWhileTrue = 4, RandomSwitch = 5, Delay = 6, }

local function TableDeepCopy( ref )
	if typeof(ref) ~= "table" then
		return ref
	end
	local clonedTable = {}
	for k,v in pairs(ref) do
		clonedTable[TableDeepCopy(k)] = TableDeepCopy(v)
	end
	return clonedTable
end

-- // Factory Functions // --
local NodeFactories = { }

function NodeFactories.ActionNode( callback : Callback, nextNode : any? )
	assert( typeof(callback) == "function", "Passed callback must be a function." )
	return { Type = NodeEnums.Action, Action = callback, NextNode = nextNode }
end

function NodeFactories.WhileConditionNode( condition : ConditionTrueFalse, callback : Callback, nextNode : any? )
	assert( typeof(condition) == "function", "Passed condition must be a function." )
	assert( typeof(callback) == "function", "Passed callback must be a function." )
	return { Type = NodeEnums.ConditionWhileTrue, Condition = condition, Callback = callback, NextNode = nextNode, }
end

function NodeFactories.DelayNode( delay : number, nextNode : any? )
	assert( typeof(delay) == "number", "Passed 'delay' must be a number." )
	return { Type = NodeEnums.Delay, NextNode = nextNode }
end

function NodeFactories.ConditionTrueFalseNode( condition : ConditionTrueFalse, ifTrueBranch : any?, ifFalseBranch : any?, nextNode : any? )
	assert( typeof(condition) == "function", "Passed condition must be a function." )
	assert( typeof(ifTrueBranch) == "function" or typeof(ifTrueBranch) == "table", "Passed condition must be a function or node." )
	assert( typeof(ifFalseBranch) == "function" or typeof(ifFalseBranch) == "table", "Passed condition must be a function or node." )
	return { Type = NodeEnums.ConditionTrueFalse, Condition = condition, IfTrueBranch = ifTrueBranch, IfFalseBranch = ifFalseBranch, NextNode = nextNode, }
end

function NodeFactories.ConditionSwitchNode( condition : ConditionSwitch, branches : { Callback }, nextNode : any? )
	assert( typeof(condition) == "function", "Passed condition must be a function." )
	assert( typeof(branches) == "table", "Passed 'branches' must be an array." )
	return { Type = NodeEnums.ConditionSwitch, Condition = condition, Branches = branches, NextNode = nextNode }
end

function NodeFactories.RandomSwitchNode( branches : { Callback }, nextNode : any? )
	assert( typeof(branches) == "table", "Passed branches must be a table." )
	return { Type = NodeEnums.RandomSwitch, Branches = branches, NextNode = nextNode }
end

-- // Tree Entity Component // --
local TreeEntityComponent = {}
TreeEntityComponent.__index = TreeEntityComponent

function TreeEntityComponent.New( nodes )
	local self = setmetatable({
		Nodes = nodes,
		TreeRootNode = nil,

		_ForwardSparseTree = { },
		_IDToNode = { },
		_UpdatingSequencersCache = { },
	}, TreeEntityComponent)
	self:FindRootNode()
	self:UpdateGraphTrees()
	return self
end

-- internal call to update a sequencer item
function TreeEntityComponent:_InternalUpdateSequencerItem( sequenceItem : TreeSequencerItem )
	local currentNode = table.remove( sequenceItem.NextNodeCache, 1 )
	if currentNode == nil then
		currentNode = self.TreeRootNode -- somehow lost its way on the path / starting off with no node
	end

	sequenceItem.CurrentNodeID = currentNode.ID

	local condArgs = sequenceItem.ConditionsAutoParams or { }
	local funcArgs = sequenceItem.FunctionsAutoParams or { }

	if currentNode.NextNode then
		table.insert(sequenceItem.NextNodeCache, 1, currentNode.NextNode)
	end

	if currentNode.Type == NodeEnums.Action then

		currentNode.Action(self, sequenceItem, unpack(funcArgs))

	elseif currentNode.Type == NodeEnums.ConditionSwitch then

		local index = currentNode.Condition( self, sequenceItem, unpack(condArgs) )
		assert( typeof(index) == "number", "Condition index did not return a number." )
		local value = currentNode.Branches[ index ]
		if typeof(value) == "function" then
			value(self, sequenceItem, unpack(funcArgs))
		elseif typeof(value) == "string" and self._IDToNode[value] then
			table.insert(sequenceItem.NextNodeCache, 1, self._IDToNode[value])
		end

	elseif currentNode.Type == NodeEnums.ConditionTrueFalse then

		local trueFalse = currentNode.Condition( self, sequenceItem, unpack(condArgs) )
		local value = trueFalse and currentNode.IfTrueBranch or currentNode.IfFalseBranch
		if typeof(value) == "function" then
			value(self, sequenceItem, unpack(funcArgs))
		elseif typeof(value) == "string" and self._IDToNode[value] then
			table.insert(sequenceItem.NextNodeCache, 1, self._IDToNode[value])
		end

	elseif currentNode.Type == NodeEnums.ConditionWhileTrue then

		local callback = currentNode.Callback
		local doContinue = currentNode.Condition( self, sequenceItem, unpack(condArgs) )
		while doContinue do
			callback(self, sequenceItem, unpack(funcArgs))
			doContinue = currentNode.Condition( self, sequenceItem, unpack(condArgs) )
		end

	elseif currentNode.Type == NodeEnums.RandomSwitch then

		local randomIndex = currentNode.Branches[math.random(#currentNode.Branches)]
		local value = currentNode.Branches[randomIndex]
		if typeof(value) == "function" then
			value(self, sequenceItem, unpack(funcArgs))
		elseif typeof(value) == "string" and self._IDToNode[value] then
			table.insert(sequenceItem.NextNodeCache, 1, self._IDToNode[value])
		end

	end
end

-- update all attached sequencer items utilizing the threader
function TreeEntityComponent:ComponentUpdate( )
	if #self._UpdatingSequencersCache == 0 then
		return
	end

	local startClock = nil
	if PERFORMANCE_PROFILING then
		startClock = os.clock()
		print( #self._UpdatingSequencersCache )
	end

	debug.profilebegin('COMPONENT_BEHAVIOR_TREE::ComponentUpdate')
	local index = 1
	while index <= #self._UpdatingSequencersCache do
		local sequenceItem = self._UpdatingSequencersCache[index] :: TreeSequencerItem
		if not sequenceItem.IsUpdating then
			sequenceItem.IsUpdating = true
			Threader(function()
				self:_InternalUpdateSequencerItem( sequenceItem )
				sequenceItem.IsUpdating = false
			end)
		end
		index += 1
	end
	debug.profileend()

	if PERFORMANCE_PROFILING then
		local endClock = os.clock()
		local duration = (endClock - startClock)
		print( math.floor(duration * PERFORMANCE_PROFILING_DECIMAL_PLACES) / PERFORMANCE_PROFILING_DECIMAL_PLACES )
	end
end

-- start auto component updater
function TreeEntityComponent:AutoComponentUpdater( )
	if self.AUTO_UPDATE_ENABLED then
		return
	end
	self.AUTO_UPDATE_ENABLED = true

	task.spawn(function()
		while self.AUTO_UPDATE_ENABLED do
			self:ComponentUpdate( )
			task.wait()
		end
	end)
end

function TreeEntityComponent:CreateSequenceItem( ) : TreeSequencerItem
	return {
		CurrentNodeID = self.TreeRootNode and self.TreeRootNode.ID,
		NextNodeCache = { },

		ConditionsAutoParams = nil,
		FunctionsAutoParams = nil,

		IsUpdating = false,
	}
end

function TreeEntityComponent:AppendSequencer( sequencer )
	table.insert( self._UpdatingSequencersCache, sequencer )
end

function TreeEntityComponent:BulkAppendSequencers( sequencerArray )
	for _, sequencer in ipairs( sequencerArray ) do
		self:AppendSequencer( sequencer )
	end
end

function TreeEntityComponent:PopSequencer( sequencer )
	local index = table.find( self._UpdatingSequencersCache, sequencer )
	while index do
		table.remove( self._UpdatingSequencersCache, index )
		index = table.find( self._UpdatingSequencersCache, sequencer )
	end
end

function TreeEntityComponent:FindRootNode()
	-- find a root node (no parent nodes)
	for _, Node in ipairs( self.Nodes ) do
		if not Node.ParentIDs or #Node.ParentIDs == 0 then
			self.TreeRootNode = Node
			break
		end
	end
end

function TreeEntityComponent:UpdateGraphTrees()
	-- update the mapping dictionary
	self._ForwardSparseTree = { }
	self._IDToNode = { }
	for _, node in ipairs( self.Nodes ) do
		self._IDToNode[node.ID] = node

		-- skip already defined ones
		if self._ForwardSparseTree[node.ID] then
			continue
		end

		local Items = { }

		if node.Type == NodeEnums.ConditionSwitch or node.Type == NodeEnums.RandomSwitch then
			for _, branch in ipairs( node.Branches ) do
				if typeof(branch) == "string" then
					table.insert( Items, branch )
				end
			end
		elseif node.Type == NodeEnums.ConditionTrueFalse then
			if typeof(node.IfTrueBranch) == "string" then
				table.insert( Items, node.IfTrueBranch )
			end
			if typeof(node.IfFalseBranch) == "string" then
				table.insert( Items, node.IfTrueBranch )
			end
		end

		if typeof(node.NextNode) == "string" then
			table.insert( Items, node.NextNode )
		end

		self._ForwardSparseTree[node.ID] = Items
	end
end

-- // Tree Entity Builder // -
local function SearchNestedNodesAndGiveID( node, cache )
	cache = cache or { }
	if (not node) or typeof(node) == "function" or table.find(cache, node) then
		return
	end
	table.insert(cache, node)
	if not node.ID then
		node.ID = HttpService:GenerateGUID(false)
	end
	if node.Type == NodeEnums.ConditionSwitch or node.Type == NodeEnums.RandomSwitch then
		for _, branch in ipairs( node.Branches ) do
			SearchNestedNodesAndGiveID( branch, cache )
		end
	elseif node.Type == NodeEnums.ConditionTrueFalse then
		SearchNestedNodesAndGiveID( node.IfTrueBranch, cache )
		SearchNestedNodesAndGiveID( node.IfFalseBranch, cache )
	end
	SearchNestedNodesAndGiveID( node.NextNode, cache )
end

local function SearchNestedNodesAndFillLinks( node, parentNode, cache )
	cache = cache or { }

	if (not node) or typeof(node) == "function" then
		return
	end

	-- if parent node is specified,
	-- add it to the list of nodes if its not there already
	if parentNode then
		if not node.ParentIDs then
			node.ParentIDs = { }
		end
		if not table.find( node.ParentIDs, parentNode.ID ) then
			table.insert( node.ParentIDs, parentNode.ID )
		end
	end

	-- has already been searched
	if table.find(cache, node.ID) then
		return
	end
	table.insert(cache, node.ID)

	if parentNode and not table.find(parentNode.ChildIDs, node.ID) then
		table.insert(parentNode.ChildIDs, node.ID)
	end

	-- add tables if not existent
	if not node.ChildIDs then
		node.ChildIDs = { }
	end
	if not node.ParentIDs then
		node.ParentIDs = { }
	end

	-- find child nodes and recursive search those
	if node.Type == NodeEnums.ConditionSwitch or node.Type == NodeEnums.RandomSwitch then
		for _, branch in ipairs( node.Branches ) do
			SearchNestedNodesAndFillLinks( branch, node, cache )
		end
	elseif node.Type == NodeEnums.ConditionTrueFalse then
		SearchNestedNodesAndFillLinks( node.IfTrueBranch, node, cache )
		SearchNestedNodesAndFillLinks( node.IfFalseBranch, node, cache )
	end

	-- check if next-node exists
	if node.NextNode then
		if not table.find(node.ChildIDs, node.NextNode.ID) then
			table.insert(node.ChildIDs, node.NextNode.ID)
		end
		if not table.find(node.NextNode.ParentIDs, node.NextNode.ID) then
			table.insert(node.NextNode.ParentIDs, node.NextNode.ID)
		end
	end
end

local function ConvertNestedNodesToArray( dict )
	local Nodes = {}

	local function DeepSearch( node )
		if (not node) or typeof(node) == "function" or table.find(Nodes, node) then
			return
		end
		table.insert(Nodes, node)

		-- find child nodes and recursive search those
		if node.Type == NodeEnums.ConditionSwitch or node.Type == NodeEnums.RandomSwitch then
			local branches = node.Branches
			if typeof(branches[1]) == 'table' then
				node.Branches = {}
				for _, branch in ipairs( branches ) do
					table.insert(node.Branches, branch.ID)
				end
				for _, branch in ipairs( branches ) do
					DeepSearch( branch )
				end
			end
		elseif node.Type == NodeEnums.ConditionTrueFalse then
			local trueBranch = node.IfTrueBranch
			local falseBranch = node.IfFalseBranch
			if typeof( node.IfTrueBranch ) == "table" then
				node.IfTrueBranch = node.IfTrueBranch.ID
			end
			if typeof( node.IfFalseBranch ) == "table" then
				node.IfFalseBranch = node.IfFalseBranch.ID
			end
			DeepSearch( trueBranch )
			DeepSearch( falseBranch )
		end
		-- check if next-node exists
		local nextNode = node.NextNode
		if nextNode then
			node.NextNode = node.NextNode.ID
			DeepSearch( nextNode )
		end
	end
	DeepSearch( dict )
	return Nodes
end

local TreeEntityFactory = { }

function TreeEntityFactory.BuildFromNestedDictionary( dict )
	-- deep copy to not edit the original source
	dict = TableDeepCopy( dict )
	-- deep search for nodes and give unique IDs to each
	SearchNestedNodesAndGiveID( dict, nil )
	-- deep search nodes and compute the parent/child links
	SearchNestedNodesAndFillLinks( dict, nil, nil )
	-- convert nested dictionary of nodes to array of nodes
	local Nodes = ConvertNestedNodesToArray( dict )
	-- return a new tree entity using these nodes
	return TreeEntityComponent.New(Nodes)
end

-- // Module // --
local Module = {}

Module.NodeFactories = NodeFactories -- create nodes using this
Module.TreeEntityComponent = TreeEntityComponent -- base behavior tree entity
Module.TreeEntityFactory = TreeEntityFactory -- use this to generate a behavior tree from config

return Module
