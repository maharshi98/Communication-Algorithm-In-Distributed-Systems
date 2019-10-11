defmodule Gossip do
	use GenServer

    def init(init_state) do
        {:ok,init_state}
    end

    def handle_cast({:sendNeighbour, neighbour_list}, init_state) do
        {:noreply, init_state ++ neighbour_list}
    end

    def handle_cast({:sendRumor,_rumor},init_state) do
        rumorCount=Enum.at(init_state,1)
        newRumorCount=rumorCount+1
        if(newRumorCount>9) do
            Process.exit(self(),:normal)
        else
            #IO.inspect("Actor Index" <> " " <> Integer.to_string(Enum.at(initialState,0)))
            #IO.inspect(Enum.at(initialState,1))

            GenServer.cast(self(),{:sendRumorContinuosly})
        end
        #IO.inspect("Outside Rumor")
        myList = [Enum.at(init_state,0),newRumorCount,Enum.at(init_state,2)]
        {:noreply,myList}
    end

    def handle_call({:read}, _from, init_state) do
        #IO.inspect(initalState)
        {:reply, init_state, init_state}
    end

    def handle_cast({:sendRumorContinuosly},init_state) do
        neighbour_list = sendRumorToNeighbour(Enum.at(init_state,2),["Rumor"])
        if(length(neighbour_list)!==0) do
            Process.sleep(10)
            GenServer.cast(self(),{:sendRumorContinuosly})
        else
            Process.sleep(10)
            Process.exit(self(),:normal)
        end
        {:noreply,init_state}
    end

    def sendRumorToNeighbour(neighbour_list,rumor) do
        if(length(neighbour_list)===0) do
            neighbour_list
        else
            randomPIDList=selectRandomNeighbour(neighbour_list)
            if(length(randomPIDList)!==0) do
                randomPID=Enum.at(randomPIDList,0)
                GenServer.cast(randomPID,{:sendRumor,rumor})
            end
            randomPIDList
        end
    end

    def selectRandomNeighbour(neighbour_list) do
        #IO.inspect(neighbourList)
        l3=length(neighbour_list)
        if(l3===0) do
            neighbour_list
        else
            randomNumber=:rand.uniform(l3)-1
            #IO.inspect(randomNumber)
            randomPID=Enum.at(neighbour_list,randomNumber)
            #IO.inspect(randomPID)
            if(Process.alive?(randomPID)==true) do
                [randomPID]
            else
                #IO.inspect("Entered")
                neighbour_list=neighbour_list--[randomPID]
                selectRandomNeighbour(neighbour_list)
            end
        end
    end
end
