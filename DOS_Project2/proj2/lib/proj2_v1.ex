defmodule Proj2V1 do
  def proj2(finalNumNodes, algorithm, topology) do
    pidTupleList = cond do
      algorithm == "gossip"->
        cond do
          topology=="line" or topology=="full" ->
            IO.inspect("Number of nodes in topology are "<>Integer.to_string(finalNumNodes))
            Enum.map(1..finalNumNodes, fn i -> startLink1(i) end)

          topology=="3Dtorus" ->
            properNumNodes=Topology.nearest_cube_number(finalNumNodes)
            IO.inspect("Number of nodes in topology are "<>Integer.to_string(properNumNodes))
            Enum.map(1..properNumNodes, fn i -> startLink1(i) end)
          topology=="rand2D" ->
            IO.inspect("Number of nodes in topology are "<>Integer.to_string(finalNumNodes))
            Enum.map(1..finalNumNodes, fn i -> startLink1(i) end)
          topology=="randhoneycomb" or  topology=="honeycomb"->
            
            properNumNodes=Topology.get_nearest_square(finalNumNodes)
            n=Topology.get_nearest_root(properNumNodes)
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
            IO.puts("Invalid Topology.")
            System.halt(0)
        end
      algorithm=="push-sum" ->
        cond do
          topology=="line" or topology=="full" or topology=="rand2D" ->
            Enum.map(1..finalNumNodes, fn i -> startLink2(i) end)
          topology=="randhoneycomb" or  topology=="honeycomb"->
            properNumNodes=Topology.get_nearest_square(finalNumNodes)
            n=Topology.get_nearest_root(properNumNodes)
            n=trunc(n)
            n=cond do
              rem(n,2)==0->n
              true->n+1
              end
            properNumNodes=:math.pow(n,2)
            properNumNodes=trunc(properNumNodes)
            
            Enum.map(1..properNumNodes, fn i -> startLink2(i) end)
          topology=="3Dtorus" ->
            properNumNodes=Topology.nearest_cube_number(finalNumNodes)
            
            Enum.map(1..properNumNodes, fn i -> startLink2(i) end)

          true ->
            IO.puts("Invalid Topology.")
            System.halt(0)
        end
      true ->
        IO.puts("Invalid Algorithm. The only permissible values of algorithms are gossip and push-sum.")
        System.halt(0);
    end

    IO.puts("Step 1: Calculating Neighbours ...")
    neighbourList=Topology.topologyNeighbours(finalNumNodes,topology,[])
    IO.puts("Neighbours Calculated.")

    IO.puts("Step 2: Mapping neighbours to their PIDs ...")
    #IO.inspect pidTupleList
    neighbourListPID=Topology.neighbour_PID_Map(pidTupleList,neighbourList)
    IO.puts("Mapping Completed")

    IO.puts("Step 3: Sending neighbours to each process ...")
    sendNeighbours(topology,finalNumNodes,pidTupleList,neighbourListPID)
    IO.puts("Neighbours Sent.")

    #getInitialState(finalNumNodes,pidTupleList)
    randomNodePID = if(algorithm=="gossip") do
      selectRandomNode(pidTupleList)
    end
    myRandomList= if(algorithm=="push-sum") do
      selectRandomNodePS(pidTupleList)
    end




    startTime = System.system_time(:millisecond)
    #IO.inspect(startTime)
    if(algorithm=="gossip") do
      IO.puts("Gossip Started ...")
      startGossip(randomNodePID, "Appoclypse on 1 October")
    else
      IO.puts("PushSum Started ...")
      startPushSum(myRandomList)
    end


    l7=length(pidTupleList)
    _abc = Enum.map(pidTupleList, fn i ->
      Process.monitor(elem(i,1)) end)
      if (algorithm == "gossip") do
        gossipConvergence(0,l7)
      else
        pushsumConvergence()
      end

    IO.puts(" ----------> CONVERGENCE TIME <----------")
    #IO.inspect(System.system_time(:millisecond))
    IO.inspect(System.system_time(:millisecond) - startTime)
    if(algorithm=="gossip") do
      IO.puts("Gossip Ended ...")
    else
      IO.puts("PushSum Ended ...")
    end

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

  def pushsumConvergence() do
    receive do
      {:DOWN, _ref, :process, _object, _reason} -> :ok
      #IO.inspect(object)
     end
  end
  #function missing

  def startLink1(currentActor) do
    {:ok, pid} = GenServer.start_link(Gossip,[currentActor,0])
    {currentActor,pid}
  end

  def startLink2(currentActor) do

    {:ok, pid} = GenServer.start_link(PushSum,[currentActor,currentActor,1,0])
    {currentActor,pid}
  end

  def sendNeighbours(topology,numNodes,pidTupleList,neighbourListPID) do
    finalNumNodes = cond do
      topology=="line" or topology=="full" ->
        numNodes

      topology=="3Dtorus"->
        Topology.nearest_cube_number(numNodes)
      topology=="rand2D" ->
        numNodes
      topology=="honeycomb" or topology=="randhoneycomb" ->
        properNumNodes = Topology.get_nearest_square(numNodes)
        n=Topology.get_nearest_root(properNumNodes)
        n=trunc(n)
        n=cond do
          rem(n,2)==0->n
          true->n+1
          end
        properNumNodes=:math.pow(n,2)
        properNumNodes=trunc(properNumNodes)
        properNumNodes
      # topology=="randhoneycomb"->
      #   Topology.get_nearest_square(numNodes)

    end
    #IO.inspect(finalNumNodes)
    for i <- 1..finalNumNodes do
      myPID=Topology.find_PID(i,pidTupleList)
      GenServer.cast(myPID,{:sendNeighbour,Enum.at(neighbourListPID,i-1)})
    end
  end

  def getInitialState(finalNumNodes,pidTupleList) do
    for i <- 1..finalNumNodes do
      myPID=Topology.find_PID(i,pidTupleList)
      GenServer.call(myPID,{:read})
    end
  end

  def selectRandomNode(pidTupleList) do
    randomNumber=:rand.uniform(length(pidTupleList))
    randomNumberPID=Topology.find_PID(randomNumber,pidTupleList)
    if(Process.alive?(randomNumberPID)==true) do
      randomNumberPID
    else
      pidTupleList=pidTupleList-[{randomNumber,randomNumberPID}]
      selectRandomNode(pidTupleList)
    end
  end

  def selectRandomNodePS(pidTupleList) do
    randomNumber=:rand.uniform(length(pidTupleList))
    randomNumberPID=Topology.find_PID(randomNumber,pidTupleList)
    if(Process.alive?(randomNumberPID)==true) do
      [randomNumber,randomNumberPID]
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
end
