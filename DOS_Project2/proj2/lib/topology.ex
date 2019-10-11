defmodule Topology do
	def topologyNeighbours(numNodes,topology,neighbour_list) do

        neighbour_list = cond do

        	########################
        	topology=="3Dtorus"->
			  IO.inspect("3D Torus")
			  finalNumNodes=nearest_cube_number(numNodes)
			  n = cube_root(finalNumNodes)
			  n=trunc(n)
			  # IO.inspect("====================")
			  # IO.inspect(finalNumNodes)
			  # IO.inspect(n)
			  my_list=Enum.map(1..finalNumNodes,fn i ->
			    a=cond do
			      rem(i,n)==1->
			        n1 = i+1
			        n2 = i+ (n-1)
			        Enum.uniq([n1,n2])
			      rem(i,n)==0->
			        n1 = i-1
			        n2 = i - (n-1)
			       Enum.uniq([n1,n2])
			      rem(i,n)!=0 && rem(i,n)!=1->
			        n1 = i-1
			        n2 = i+1
			           Enum.uniq([n1,n2])
			    end
			    b=cond do
			      div(rem(i-1,n*n),n) == 0->
			        n3 = i+n
			        n4 = i + n*(n-1)
			        Enum.uniq([n3,n4])
			      div(rem(i-1,n*n),n) == (n-1)->
			        n3 = i-n
			        n4 = i - n*(n-1)
			                           Enum.uniq([n3,n4])
			      div(rem(i-1,n*n),n)>0 && div(rem(i-1,n*n),n)<(n-1) ->
			        n3 = i-n
			        n4 = i+n
			                     Enum.uniq([n3,n4])
			    end

			   c= cond do
			     div(i-1,(n*n)) == 0->
			       n5 = i + n*n
			       n6 = i + n*n*(n-1)
			                                Enum.uniq([n5,n6])
			     div(i-1,(n*n)) == (n-1)->
			       n5 = i- n*n
			       n6 = i - n*n*(n-1)
			                         Enum.uniq([n5,n6])
			     div(i-1,(n*n))>0 && div(i-1,(n*n))<(n-1)->
			       n5 = i-n*n
			       n6 = i+n*n
			                       Enum.uniq([n5,n6])
			   end
			    a++b++c
			  end)



            topology=="full" ->
                IO.inspect("Full network topology")
                my_list=[]

                for i <- 1..numNodes do
                    my_list =
                    for j <- 1..numNodes  do
                        if (j !== i) do
                                my_list++j
                        end
                    end
                    my_list=Enum.reject(my_list, &is_nil/1)
                    Enum.concat(neighbour_list,my_list)
                    #IO.inspect(my_list,charlists: :as_lists)
                end

            topology=="line" ->
                IO.inspect("Line Topology")
                for i <- 1..numNodes do
                    my_list = cond do
                        i===1 ->
                            myNeighbour=i+1
                            [myNeighbour]
                        i===numNodes ->
                            myNeighbour=i-1
                            [myNeighbour]
                        i>1 && i<numNodes ->
                            n1=i-1
                            n2=i+1
                            [n1,n2]
                    end
                    Enum.concat(neighbour_list,my_list)

                end
################################
						topology=="honeycomb"->
						          finalNumNodes=get_nearest_square(numNodes)
						          n=get_nearest_root(finalNumNodes)
						          n=trunc(n)
						          n=cond do
						            rem(n,2)==0->n
						            true->n+1
						            end
						          finalNumNodes=:math.pow(n,2)
						          finalNumNodes=trunc(finalNumNodes)
						          Enum.map(1..finalNumNodes,fn i->
						            myList=cond do
						              i<n and i>1 and rem(i,2)==0->
						                [i+1,i-1]
						             i<n and  i>1 and rem(i,2)!=0->
						                [i+1,i-1,i+n]
						              finalNumNodes-(n+1)<i and i<finalNumNodes and rem(i,2)==0 ->
						                [i+1,i-1]
						              finalNumNodes-(n+1)<i and i<finalNumNodes and rem(i,2)!=0 ->
						                [i+1,i-1,i-n]
						              rem(i,n)==1 and rem(div(i,n),2)==0 ->
						                [i+n,i+1]
						              rem(i,n)==1 and rem(div(i,n),2)!=0 ->
						                [i-n,i+1]
						              rem(i,n)==0 and rem(div(i,n),2)==0 and i != n and i != (n*n) ->
						                [i-1,i+n]
						              rem(i,n)==0 and rem(div(i,n),2) != 0 and i != n and i != (n*n) ->
						                [i-1,i-n]
						              i==n or i==(n*n)->
						                [i-1]
						              n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==1 and rem(i,2)==0->
						                [i+1,i-1,i+n]
						              n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==1 and rem(i,2)==1->
						                [i+1,i-1,i-n]
						              n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==0 and rem(i,2)==0->
						                [i+1,i-1,i-n]
						              n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==0 and rem(i,2)==1->
						                [i+1,i-1,i+n]
						            end
						            myList
						          end)
						topology=="randhoneycomb"->
						  finalNumNodes=get_nearest_square(numNodes)
						  n=get_nearest_root(finalNumNodes)
						  n=trunc(n)
						  n=cond do
						    rem(n,2)==0->n
						    true->n+1
						  end
						  finalNumNodes=:math.pow(n,2)
						  finalNumNodes=trunc(finalNumNodes)
						  Enum.map(1..finalNumNodes,fn i->
						    myList=cond do
						      i<n and i>1 and rem(i,2)==0->
						        [i+1,i-1]
						      i<n and  i>1 and rem(i,2)!=0->
						        [i+1,i-1,i+n]
						      finalNumNodes-(n+1)<i and i<finalNumNodes and rem(i,2)==0 ->
						        [i+1,i-1]
						      finalNumNodes-(n+1)<i and i<finalNumNodes and rem(i,2)!=0 ->
						        [i+1,i-1,i-n]
						      rem(i,n)==1 and rem(div(i,n),2)==0 ->
						        [i+n,i+1]
						      rem(i,n)==1 and rem(div(i,n),2)!=0 ->
						        [i-n,i+1]
						      rem(i,n)==0 and rem(div(i,n),2)==0 and i != n and i != (n*n) ->
						        [i-1,i+n]
						      rem(i,n)==0 and rem(div(i,n),2) != 0 and i != n and i != (n*n) ->
						        [i-1,i-n]
						      i==n or i==(n*n)->
						        [i-1]
						      n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==1 and rem(i,2)==0->
						        [i+1,i-1,i+n]
						      n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==1 and rem(i,2)==1->
						        [i+1,i-1,i-n]
						      n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==0 and rem(i,2)==0->
						        [i+1,i-1,i-n]
						      n+1<=i and i<=finalNumNodes-n and rem(i,n)!=1 and  rem(i,n)!=0 and rem(div(i,n),2)==0 and rem(i,2)==1->
						        [i+1,i-1,i+n]
						    end
						    if(i<=div(finalNumNodes,2))do
						        myList++[i+div(finalNumNodes,2)]
						    else
						        myList++[i-div(finalNumNodes,2)]
						      end

						  end)
################################



            topology=="rand2D" ->
                IO.inspect("Random-2D-grid topology")
                list1=[]
                my_list=[]
                #generate nodes
                list1 = for i <- 1..numNodes do
                    randGenerate(i,list1)
                end
                #IO.inspect(list1)
                #calculate neighbours
                for i <- 1..numNodes do
                    my_list =
                    for j <- 1..numNodes  do
                        if (j !== i) do
                            if (calDis(i, j, list1) < 0.1) do
                                myNeighbour=j
                                my_list++myNeighbour
                            end
                        end
                    end
                    my_list=Enum.reject(my_list, &is_nil/1)
                    Enum.concat(neighbour_list,my_list)
                    #IO.inspect(my_list,charlists: :as_lists)
                end
            end
        # IO.inspect(neighbour_list)
        neighbour_list
    end

    def get_other_neighbour(currentActor,n1,numNodes) do
        n2=:rand.uniform(numNodes)
        if(n1 !== n2 && currentActor !== n2) do
            n2
        else
            get_other_neighbour(currentActor,n1,numNodes)
        end
    end

    def get_other_neighbour(currentActor,n1,n2,numNodes) do
        n3=:rand.uniform(numNodes)
        if(n1 !== n3 && n2 !== n3 && currentActor !== n3) do
            n3
        else
            get_other_neighbour(currentActor,n1,n2,numNodes)
        end
    end

    def get_nearest_root(numNodes) do
        trunc(Float.ceil(:math.sqrt(numNodes)))
    end

    def get_nearest_square(numNodes) do
        trunc(:math.pow(Float.ceil(:math.sqrt(numNodes)),2))
    end

    def nearest_cube_number(numNodes) do
        cr = Float.ceil(cube_root(numNodes))
        trunc(:math.pow(cr,3))
    end

    def cube_root(x, precision \\ 1.0e-12) do
        f = fn(prev) -> (2 * prev + x / :math.pow(prev, 2)) / 3 end
        fixed_point(f, x, precision, f.(x))
    end

    def fixed_point(_, guess, tolerance, next) when abs(guess - next) < tolerance, do: next

    def fixed_point(f, _, tolerance, next), do: fixed_point(f, next, tolerance, f.(next))

    def neighbour_PID_Map(pidTupleList,neighbour_list) do
        neighbour_list_PID=[]
        l1=length(neighbour_list)
        #IO.inspect("L1")
        #IO.inspect(l1)
        neighbour_list_PID = for i <- 1..l1 do
        l2=length(Enum.at(neighbour_list,i-1))
        if(l2 !=0) do
            #IO.inspect("qqq")
            #IO.inspect(l2)
            smallneighbour_list_PID = for j <- 1..l2 do
                myneighbour_list=Enum.at(neighbour_list,i-1)
                #IO.inspect(Enum.at(neighbour_list,i-1), charlists: :as_lists)
                neighbourIndex=Enum.at(myneighbour_list,j-1)
                #IO.inspect(Enum.at(myneighbour_list,j-1))
                myPID=find_PID(neighbourIndex,pidTupleList)
                #IO.inspect("Hello")
                #IO.inspect(find_PID(neighbourIndex,pidTupleList))
                myPID
                #IO.inspect(myPID)
                end
                [smallneighbour_list_PID]
        else
           IO.puts("The topology is broken so Gossip won't be executed.")
           System.halt(0)
        end
    end
        neighbour_list_PID

    end

    def find_PID(index,pidTupleList) do
        # IO.inspect(pidTupleList)
				# IO.inspect index
        # #IO.inspect(Enum.at(pidTupleList,index-1))
        myTuple=Enum.at(pidTupleList,index-1)

				# IO.inspect myTuple
				myPID=elem(myTuple,1)
        myPID
    end

    def randGenerate(nodeIndex, corList) do
        x=Float.ceil(:rand.uniform(), 3)
        y=Float.ceil(:rand.uniform(), 3)
        if (Enum.member?(corList, x) && Enum.member?(corList, y)) do
            randGenerate(nodeIndex, corList)
        end
        myCor = [x, y]
        _corList=Enum.concat(corList, myCor)
        #IO.inspect(nodeIndex)
        #IO.inspect(myCor)
    end

    def calDis(index1, index2, corList) do
        x1=Enum.at(Enum.at(corList, index1-1), 0)
        x2=Enum.at(Enum.at(corList, index2-1), 0)
        y1=Enum.at(Enum.at(corList, index1-1), 1)
        y2=Enum.at(Enum.at(corList, index2-1), 1)
        dx=x1-x2
        dy=y1-y2
        :math.sqrt(:math.pow(dx,2)+:math.pow(dy,2))
        #IO.inspect(:math.sqrt(:math.pow(dx,2)+:math.pow(dy,2)))
    end



end
