defmodule Project2Bonus do
  def proj2(finalNumNodes,algorithm,topology,nodesToFail) do
    pidTupleList = cond do
      algorithm == "gossip"->
        cond do 
          topology=="line" or topology=="full" ->
            IO.inspect("Number of nodes in topology are "<>Integer.to_string(finalNumNodes))
            Enum.map(1..finalNumNodes, fn i -> startLink1(i) end)

          topology=="3Dtorus" ->
            properNumNodes=Topology.nearestCubeNumber(finalNumNodes)
            IO.inspect("Number of nodes in topology are "<>Integer.to_string(properNumNodes))
            Enum.map(1..properNumNodes, fn i -> startLink1(i) end)
          topology=="rand2D" ->
            IO.inspect("Number of nodes in topology are "<>Integer.to_string(finalNumNodes))
            Enum.map(1..finalNumNodes, fn i -> startLink1(i) end)
          topology=="randhoneycomb" or  topology=="honeycomb"->
            properNumNodes=Topology.nearest_Square(finalNumNodes)
            n=Topology.nearest_Square_Root(properNumNodes)
            n=trunc(n)
            n=cond do
              rem(n,2)==0->n
              true->n+1
              end
            properNumNodes=:math.pow(n,2)
            properNumNodes=trunc(properNumNodes)
            IO.inspect "---------------------#{properNumNodes}"
            Enum.map(1..properNumNodes, fn i -> startLink1(i) end)

          true -> 
            IO.puts("Invalid Topology. The only permissible values of topologies are line, full, 3Dtorus, rand2D, honeycomb and randhoneycomb.")
            System.halt(0)
        end
      
      true -> 
        IO.puts("Invalid Algorithm. The only permissible values of algorithms is gossip.")
        System.halt(0);
    end

    IO.puts(".... Calculating Neighbours ....")
    neighbourList=Topology.topologyNeighbours(finalNumNodes,topology,[])
    IO.puts("Neighbours Calculated.")

    IO.puts(".... Mapping ....")
    neighbourListPID=Topology.neighbourPIDMapping(pidTupleList,neighbourList)
    IO.puts("Mapping Completed")

    IO.puts(".... Sending neighbours ....")
    sendNeighbours(topology,finalNumNodes,pidTupleList,neighbourListPID)
    IO.puts("Neighbours Sent.")

    #getInitialState(finalNumNodes,pidTupleList)
    
    randomNodeList=failNodes(0,nodesToFail,finalNumNodes,topology,[])
    #IO.inspect(randomNodeList)

    failNodesPIDList=getPIDList(randomNodeList,pidTupleList,[])
    #IO.inspect(failNodesPIDList)

    #killFailNodes(failNodesPIDList)
    #IO.inspect("Killed")
    
    updateNeighbours(topology,finalNumNodes,pidTupleList,failNodesPIDList,randomNodeList)
    #getInitialState(finalNumNodes,pidTupleList)

    randomNodePID = if(algorithm=="gossip") do
      selectRandomNode(pidTupleList)
    end
    
    
    if(Enum.member?(failNodesPIDList,randomNodePID)==true) do
      IO.puts("The Node selected to initiate the protocol has been killed. So please run the program again.")
      System.halt(0)
    end
    

    startTime = System.system_time(:millisecond)
    if(algorithm=="gossip") do
      IO.inspect("Gossip Started")
      startGossip(randomNodePID, "message")
    
    end
    
    l7=length(pidTupleList)-nodesToFail
    _abc = Enum.map(pidTupleList, fn i -> 
      Process.monitor(elem(i,1)) end)
      if (algorithm == "gossip") do
        gossipConvergence(0,l7) 
      end

    ## new monitoring code ##

    IO.puts "-----------> Convergence time <------------"
    IO.inspect(System.system_time(:millisecond) - startTime )
    IO.puts("Gossip ended.")
  end

  def gossipConvergence(processesKilled,finalNumNodes) do
    receive do
     {:DOWN, _ref, :process, _object, _reason} -> :ok
     #IO.inspect(object) 
    end
    newProcessesKilled=processesKilled+1
    if (newProcessesKilled < finalNumNodes ) do
      gossipConvergence(newProcessesKilled,finalNumNodes) 
    end
  end

  def startLink1(currentActor) do
    {:ok, pid} = GenServer.start_link(Gossip,[currentActor,0,1])
    {currentActor,pid}
  end


  def sendNeighbours(topology,numNodes,pidTupleList,neighbourListPID) do
    finalNumNodes = cond do
      topology=="line" or topology=="full" ->
        numNodes

      topology=="3Dtorus"->
        Topology.nearestCubeNumber(numNodes)
      topology=="rand2D" ->
        numNodes
      topology=="honeycomb" or topology=="randhoneycomb" ->
        properNumNodes = Topology.nearest_Square(numNodes)
        n=Topology.nearest_Square_Root(properNumNodes)
        n=trunc(n)
        n=cond do
          rem(n,2)==0->n
          true->n+1
          end
        properNumNodes=:math.pow(n,2)
        properNumNodes=trunc(properNumNodes)
        properNumNodes
    end
    #IO.inspect(finalNumNodes)
    for i <- 1..finalNumNodes do
      myPID=Topology.findPID(i,pidTupleList)
      GenServer.cast(myPID,{:sendNeighbour,Enum.at(neighbourListPID,i-1)})
    end
  end

  def getInitialState(finalNumNodes,pidTupleList) do
    for i <- 1..finalNumNodes do
      myPID=Topology.findPID(i,pidTupleList)
      GenServer.call(myPID,{:read})    
    end
  end
  

  def selectRandomNode(pidTupleList) do
    randomNumber=:rand.uniform(length(pidTupleList))
    randomNumberPID=Topology.findPID(randomNumber,pidTupleList)
    if(Process.alive?(randomNumberPID)==true) do
      randomNumberPID
    else
      pidTupleList=pidTupleList-[{randomNumber,randomNumberPID}]
      selectRandomNode(pidTupleList)
    end
  end

  def startGossip(randomNodePID,rumor) do
    GenServer.cast(randomNodePID,{:sendRumor,rumor})
  end

  def startPushSum(myRandomList) do
    GenServer.cast(Enum.at(myRandomList,1),{:pushSum,[0,0]})
  end

  def failNodes(nodesFailed,nodesToFail,finalNumNodes,topology,randomNumList) do
    myNodes = cond do
      topology=="line" or topology=="full" ->
        finalNumNodes

      topology=="3Dtorus"->
        Topology.nearestCubeNumber(finalNumNodes)
      topology=="rand2D" ->
        finalNumNodes
      topology=="honeycomb" or topology=="randhoneycomb" ->
        properNumNodes = Topology.nearest_Square(finalNumNodes)
        n=Topology.nearest_Square_Root(properNumNodes)
        n=trunc(n)
        n=cond do
          rem(n,2)==0->n
          true->n+1
          end
        properNumNodes=:math.pow(n,2)
        properNumNodes=trunc(properNumNodes)
        properNumNodes
    end
    # IO.inspect(finalNumNodes)
    if(nodesFailed<nodesToFail) do
      randomNodeNumber=:rand.uniform(myNodes)
      if(Enum.member?(randomNumList,randomNodeNumber)==true) do
        failNodes(nodesFailed,nodesToFail,finalNumNodes,topology,randomNumList)
      else
        randomNumList=Enum.concat(randomNumList,[randomNodeNumber])
        failNodes(nodesFailed+1,nodesToFail,finalNumNodes,topology,randomNumList)
      end
      
    else
      IO.inspect(randomNumList)  
    end
    
  end

  def getPIDList(randomNodeList, pidTupleList, myPIDList) do
    l8=length(randomNodeList)
    myPIDList = for i <- 1..l8 do
      myPID=Topology.findPID(Enum.at(randomNodeList,i-1),pidTupleList)
      myPID
    end
  end

  def killFailNodes(failNodesPIDList) do
    l9=length(failNodesPIDList)
    for i <- 1..l9 do
      myPID=Enum.at(failNodesPIDList,i-1)
      Process.exit(myPID,:normal)
    end
  end

  def updateNeighbours(topology,numNodes,pidTupleList,failNodePIDList,randomNodeList) do
    finalNumNodes = cond do
      topology=="line" or topology=="full" ->
        numNodes

      topology=="3Dtorus"->
        Topology.nearestCubeNumber(numNodes)
      topology=="rand2D" ->
        numNodes
      topology=="honeycomb" or topology=="randhoneycomb" ->
        properNumNodes = Topology.nearest_Square(numNodes)
        n=Topology.nearest_Square_Root(properNumNodes)
        n=trunc(n)
        n=cond do
          rem(n,2)==0->n
          true->n+1
          end
        properNumNodes=:math.pow(n,2)
        properNumNodes=trunc(properNumNodes)
        properNumNodes
    end
    #IO.inspect(finalNumNodes)
    for i <- 1..finalNumNodes do
      myPID=Topology.findPID(i,pidTupleList)
      GenServer.cast(myPID,{:updateNeighbour,failNodePIDList,randomNodeList})
    end
  end

  
end
