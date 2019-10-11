defmodule MainMod do
	topology = Enum.at(System.argv(),1)
	numNodes = String.to_integer(Enum.at(System.argv(),0))
	algorithm = Enum.at(System.argv(),2)
	IO.puts(algorithm)
	IO.puts(topology)
	IO.puts(numNodes)
	if algorithm == "gossip" do
		IO.puts "here"
	end
	Proj2V1.proj2(numNodes, algorithm, topology)
end



MainMod
