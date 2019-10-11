defmodule MainMod do
	topology = Enum.at(System.argv(),1)
	numNodes = String.to_integer(Enum.at(System.argv(),0))
	algorithm = Enum.at(System.argv(),2)
	fail_nodes = String.to_integer(Enum.at(System.argv(),3))
	
	Project2Bonus.proj2(numNodes, algorithm, topology, fail_nodes)
end

MainMod