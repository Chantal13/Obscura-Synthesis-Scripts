-- Initial version of code stolen from https://www.lua.org/pil/11.4.html probably
List = {}
function List.new()
	return {first = 0, last = -1}
end

function List.pushLeft(list, value)
	local first = list.first - 1
	list.first = first
	list[first] = value
end

function List.pushRight(list, value)
	local last = list.last + 1
	list.last = last
	list[last] = value
end

function List.popLeft(list)
	local first = list.first
	if first > list.last then error("list is empty") end
	local value = list[first]
	list[first] = nil        -- to allow garbage collection
	list.first = first + 1
	return value
end

function List.popRight(list)
	local last = list.last
	if list.first > last then error("list is empty") end
	local value = list[last]
	list[last] = nil         -- to allow garbage collection
	list.last = last - 1
	return value
end

function List.isEmpty(list)
	return list.first > list.last
end

local testList = List.new()
assert(List.isEmpty(testList))

List.pushRight(testList, "a")
assert(not List.isEmpty(testList))
List.pushRight(testList, "b")
assert(not List.isEmpty(testList))
List.pushRight(testList, "c")
assert(not List.isEmpty(testList))
assert(List.popLeft(testList) == "a")
assert(List.popLeft(testList) == "b")
assert(List.popLeft(testList) == "c")
assert(List.isEmpty(testList))

List.pushRight(testList, "a")
List.pushRight(testList, "b")
List.pushRight(testList, "c")
assert(List.popRight(testList) == "c")
assert(List.popRight(testList) == "b")
assert(List.popRight(testList) == "a")
assert(List.isEmpty(testList))

local testListNeg = List.new()
assert(List.isEmpty(testListNeg))

List.pushLeft(testListNeg, "a")
assert(not List.isEmpty(testListNeg))
List.pushLeft(testListNeg, "b")
List.pushLeft(testListNeg, "c")
assert(List.popRight(testListNeg) == "a")
assert(List.popRight(testListNeg) == "b")
assert(List.popRight(testListNeg) == "c")
assert(List.isEmpty(testListNeg))

List.pushLeft(testListNeg, "a")
List.pushLeft(testListNeg, "b")
List.pushLeft(testListNeg, "c")
assert(List.popLeft(testListNeg) == "c")
assert(List.popLeft(testListNeg) == "b")
assert(List.popLeft(testListNeg) == "a")
assert(List.isEmpty(testListNeg))
