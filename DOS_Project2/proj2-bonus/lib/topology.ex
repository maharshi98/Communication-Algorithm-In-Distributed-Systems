defmodule Topology do
    def topologyNeighbours(numNodes,topology,nList) do
        
        nList = cond do

            topology=="full" ->
                IO.inspect("full network topology")
                myList=[]
                
                for i <- 1..numNodes do
                    myList = 
                    for j <- 1..numNodes  do
                        if (j !== i) do
                                myList++j
                        end
                    end
                    myList=Enum.reject(myList, &is_nil/1)
                    Enum.concat(nList,myList)
                    #IO.inspect(myList,charlists: :as_lists)
                end

            topology=="line" -> 
                IO.inspect("Line Topology")
                for i <- 1..numNodes do
                    myList = cond do
                        i===1 ->
                            myNeighbour=i+1
                            [myNeighbour]
                        i===numNodes ->
                            myNeighbour=i-1
                            [myNeighbour]
                        i>1 && i<numNodes ->
                            neighbour1=i-1
                            neighbour2=i+1
                            [neighbour1,neighbour2]    
                    end
                    Enum.concat(nList,myList)
                    
                end
                
            
            
            topology=="3Dtorus"->
              IO.inspect("3D Torus")
              finalNumNodes=nearestCubeNumber(numNodes)
              n = cube_root(finalNumNodes)
              n=trunc(n)
              
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

              topology=="honeycomb"->
                  finalNumNodes=nearest_Square(numNodes)
                  n=nearest_Square_Root(finalNumNodes)
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
              finalNumNodes=nearest_Square(numNodes)
              n=nearest_Square_Root(finalNumNodes)
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

            
            topology=="rand2D" ->
                IO.inspect("Random-2D-grid topology")
                cList=[]
                myList=[]
                #generate nodes
                cList = for i <- 1..numNodes do
                    randGenerate(i,cList)
                end
                #IO.inspect(cList)
                #calculate neighbours
                for i <- 1..numNodes do
                    myList = 
                    for j <- 1..numNodes  do
                        if (j !== i) do
                            if (calc_Dist(i, j, cList) < 0.1) do
                                myNeighbour=j
                                myList++myNeighbour
                            end
                        end
                    end
                    myList=Enum.reject(myList, &is_nil/1)
                    Enum.concat(nList,myList)
                    #IO.inspect(myList,charlists: :as_lists)
                end

            
            topology=="3D" ->
                IO.inspect("3D-grid topology")
                finalNumNodes = Kernel.trunc(nearestCubeNumber(numNodes))
                sideLength = Kernel.trunc(Float.ceil(cube_root(numNodes)))
                surfaceSize = Kernel.trunc(:math.pow(sideLength, 2))
                #IO.puts surfaceSize
                IO.puts finalNumNodes

                for i <- 1..finalNumNodes do
                    #IO.puts i
                    myList = cond do
                        
                        #corner8
                        i===1 ->
                            neighbour1 = i+1
                            neighbour2 = i+sideLength
                            neighbour3 = i+surfaceSize
                            [neighbour1, neighbour2, neighbour3]
                        i===sideLength ->
                            neighbour1 = i-1
                            neighbour2 = i+sideLength
                            neighbour3 = i+surfaceSize
                            [neighbour1, neighbour2, neighbour3]
                        i===surfaceSize-sideLength+1 ->
                            neighbour1 = i+1
                            neighbour2 = i-sideLength
                            neighbour3 = i+surfaceSize
                            [neighbour1, neighbour2, neighbour3]
                        i===surfaceSize ->
                            neighbour1 = i-1
                            neighbour2 = i-sideLength
                            neighbour3 = i+surfaceSize
                            [neighbour1, neighbour2, neighbour3]
                        i===1+(sideLength-1)*surfaceSize ->
                            neighbour1 = i+1
                            neighbour2 = i+sideLength
                            neighbour3 = i-surfaceSize
                            [neighbour1, neighbour2, neighbour3]
                        i===sideLength+(sideLength-1)*surfaceSize ->
                            neighbour1 = i-1
                            neighbour2 = i+sideLength
                            neighbour3 = i-surfaceSize
                            [neighbour1, neighbour2, neighbour3]
                        i===surfaceSize-sideLength+1+(sideLength-1)*surfaceSize ->
                            neighbour1 = i+1
                            neighbour2 = i-sideLength
                            neighbour3 = i-surfaceSize
                            [neighbour1, neighbour2, neighbour3]
                        i===finalNumNodes ->
                            neighbour1 = i-1
                            neighbour2 = i-sideLength
                            neighbour3 = i-surfaceSize
                            [neighbour1, neighbour2, neighbour3]
                        
                        #12side
                        i>1 && i<sideLength ->
                            neighbour1 = i-1
                            neighbour2 = i+1
                            neighbour3 = i+sideLength
                            neighbour4 = i+surfaceSize
                            [neighbour1, neighbour2, neighbour3, neighbour4]
                        i<surfaceSize-sideLength && i>1 && rem(i,sideLength)===1 ->
                            neighbour1 = i+1
                            neighbour2 = i+sideLength
                            neighbour3 = i-sideLength
                            neighbour4 = i+surfaceSize
                            [neighbour1, neighbour2, neighbour3, neighbour4]
                        i>sideLength && i<surfaceSize && rem(i, sideLength)===0 ->
                            neighbour1 = i-1
                            neighbour2 = i-sideLength
                            neighbour3 = i+sideLength
                            neighbour4 = i+surfaceSize
                            [neighbour1, neighbour2, neighbour3, neighbour4]
                        i>surfaceSize-sideLength+1 && i<surfaceSize ->
                            neighbour1 = i-sideLength
                            neighbour2 = i-1
                            neighbour3 = i+1
                            neighbour4 = i+surfaceSize
                            [neighbour1, neighbour2, neighbour3, neighbour4]
                        
                        i>1 && i<=finalNumNodes-surfaceSize && rem(i, surfaceSize)===1 ->
                            neighbour1 = i+1
                            neighbour2 = i+sideLength
                            neighbour3 = i+surfaceSize
                            neighbour4 = i-surfaceSize
                            [neighbour1, neighbour2, neighbour3, neighbour4]
                        i>surfaceSize && i<=finalNumNodes-surfaceSize && rem(i, surfaceSize)===sideLength ->
                            neighbour1 = i-1
                            neighbour2 = i+sideLength
                            neighbour3 = i-surfaceSize
                            neighbour4 = i+surfaceSize
                            [neighbour1, neighbour2, neighbour3, neighbour4]
                        i>surfaceSize && i<=finalNumNodes-surfaceSize && rem(i, surfaceSize)===surfaceSize-sideLength+1 ->
                            neighbour1 = i+1
                            neighbour2 = i-sideLength
                            neighbour3 = i-surfaceSize
                            neighbour4 = i+surfaceSize
                            [neighbour1, neighbour2, neighbour3, neighbour4]
                        i>surfaceSize && i<=finalNumNodes-surfaceSize && rem(i, surfaceSize)===0 ->
                            neighbour1 = i-1
                            neighbour2 = i-sideLength
                            neighbour3 = i-surfaceSize
                            neighbour4 = i+surfaceSize
                            [neighbour1, neighbour2, neighbour3, neighbour4]
                        
                        i>1+(sideLength-1)*surfaceSize && i<sideLength+(sideLength-1)*surfaceSize ->
                            neighbour1 = i-1
                            neighbour2 = i+1
                            neighbour3 = i+sideLength
                            neighbour4 = i-surfaceSize
                            [neighbour1, neighbour2, neighbour3, neighbour4]
                        i<surfaceSize-sideLength+(sideLength-1)*surfaceSize && i>1+(sideLength-1)*surfaceSize && rem(i,sideLength)===1 ->                        
                            neighbour1 = i+1
                            neighbour2 = i+sideLength
                            neighbour3 = i-sideLength
                            neighbour4 = i-surfaceSize
                            [neighbour1, neighbour2, neighbour3, neighbour4]
                        i>sideLength+(sideLength-1)*surfaceSize && i<surfaceSize+(sideLength-1)*surfaceSize && rem(i, sideLength)===0 ->
                            neighbour1 = i-1
                            neighbour2 = i-sideLength
                            neighbour3 = i+sideLength
                            neighbour4 = i-surfaceSize
                            [neighbour1, neighbour2, neighbour3, neighbour4]
                        i>surfaceSize-sideLength+1+(sideLength-1)*surfaceSize && i<surfaceSize+(sideLength-1)*surfaceSize ->

                            neighbour1 = i-sideLength
                            neighbour2 = i-1
                            neighbour3 = i+1
                            neighbour4 = i-surfaceSize
                            [neighbour1, neighbour2, neighbour3, neighbour4]
                        
                        #6surface
                        #top
                        i>sideLength+1 && i<(sideLength-1)*sideLength && rem(i, sideLength)>1 ->
                            #IO.puts "top"
                            neighbour1 = i+1
                            neighbour2 = i-1
                            neighbour3 = i+sideLength
                            neighbour4 = i-sideLength
                            neighbour5 = i+surfaceSize
                            [neighbour1, neighbour2, neighbour3, neighbour4, neighbour5]
                        #bottom
                        i>sideLength+1+(sideLength-1)*surfaceSize && i<(sideLength-1)*sideLength+(sideLength-1)*surfaceSize && rem(i, sideLength)>1 ->
                            #IO.puts "bottom"
                            neighbour1 = i+1
                            neighbour2 = i-1
                            neighbour3 = i+sideLength
                            neighbour4 = i-sideLength
                            neighbour5 = i-surfaceSize
                            [neighbour1, neighbour2, neighbour3, neighbour4, neighbour5]
                        #left
                        i>1+surfaceSize && i<=finalNumNodes-surfaceSize-sideLength && rem(i, sideLength)==1 && rem(i, surfaceSize)!==1 && rem(i, surfaceSize)!==surfaceSize-sideLength+1 ->
                            #IO.puts "left"
                            neighbour1 = i+sideLength
                            neighbour2 = i-sideLength
                            neighbour3 = i+surfaceSize
                            neighbour4 = i+surfaceSize
                            neighbour5 = i+1
                            [neighbour1, neighbour2, neighbour3, neighbour4, neighbour5]
                        #right
                        i>1+sideLength+surfaceSize && i<=finalNumNodes-surfaceSize && rem(i, sideLength)==0 && rem(i, surfaceSize)!==sideLength && rem(i, surfaceSize)!==0 ->
                            #IO.puts "right"
                            neighbour1 = i+sideLength
                            neighbour2 = i-sideLength
                            neighbour3 = i+surfaceSize
                            neighbour4 = i-surfaceSize
                            neighbour5 = i-1
                            [neighbour1, neighbour2, neighbour3, neighbour4, neighbour5]
                        #back
                        i>1+surfaceSize && i<finalNumNodes-2*surfaceSize+sideLength && rem(i, surfaceSize)>1 &&rem(i,surfaceSize)<sideLength ->
                            #IO.puts "back"
                            neighbour1 = i+1
                            neighbour2 = i-1
                            neighbour3 = i+surfaceSize
                            neighbour4 = i-surfaceSize
                            neighbour5 = i+sideLength
                            [neighbour1, neighbour2, neighbour3, neighbour4, neighbour5]
                        #front
                        i>2*surfaceSize-sideLength+1 && i<finalNumNodes-surfaceSize && rem(i,surfaceSize)>surfaceSize-sideLength+1 && rem(i,surfaceSize)!==0 ->
                            #IO.puts "front"
                            neighbour1 = i+1
                            neighbour2 = i-1
                            neighbour3 = i+surfaceSize
                            neighbour4 = i-surfaceSize
                            neighbour5 = i-sideLength
                            [neighbour1, neighbour2, neighbour3, neighbour4, neighbour5]
                        #inside
                        true ->
                            neighbour1 = i+1
                            neighbour2 = i-1
                            neighbour3 = i+sideLength
                            neighbour4 = i-sideLength
                            neighbour5 = i+surfaceSize
                            neighbour6 = i-surfaceSize
                            [neighbour1, neighbour2, neighbour3, neighbour4, neighbour5, neighbour6]
                    end
                    Enum.concat(nList,myList)
                    #IO.inspect(myList,charlists: :as_lists)
                end
            end
        
        nList
        
    end     
    
    def getOtherNeighbour(currentActor,neighbour1,numNodes) do
        neighbour2=:rand.uniform(numNodes)
        if(neighbour1 !== neighbour2 && currentActor !== neighbour2) do
            neighbour2
        else
            getOtherNeighbour(currentActor,neighbour1,numNodes)
        end
    end
    
    def getOtherNeighbour(currentActor,neighbour1,neighbour2,numNodes) do
        neighbour3=:rand.uniform(numNodes)
        if(neighbour1 !== neighbour3 && neighbour2 !== neighbour3 && currentActor !== neighbour3) do
            neighbour3
        else
            getOtherNeighbour(currentActor,neighbour1,neighbour2,numNodes)
        end
    end
    
    def nearest_Square_Root(numNodes) do
        trunc(Float.ceil(:math.sqrt(numNodes)))
    end

    def nearest_Square(numNodes) do
        trunc(:math.pow(Float.ceil(:math.sqrt(numNodes)),2))
    end

    def nearestCubeNumber(numNodes) do
        cr = Float.ceil(cube_root(numNodes))
        trunc(:math.pow(cr,3))        
    end
    
    def cube_root(x, precision \\ 1.0e-12) do
        f = fn(prev) -> (2 * prev + x / :math.pow(prev, 2)) / 3 end
        fixed_point(f, x, precision, f.(x))
    end
    
    def fixed_point(_, guess, tolerance, next) when abs(guess - next) < tolerance, do: next
    
    def fixed_point(f, _, tolerance, next), do: fixed_point(f, next, tolerance, f.(next))

    def neighbourPIDMapping(pidTupleList,nList) do
        nListPID=[]
        l1=length(nList)
        #IO.inspect("L1")
        #IO.inspect(l1)
        nListPID = for i <- 1..l1 do
        l2=length(Enum.at(nList,i-1))
        if(l2 !=0) do
            #IO.inspect("qqq")
            #IO.inspect(l2)
            smallnListPID = for j <- 1..l2 do
                mynList=Enum.at(nList,i-1)
                #IO.inspect(Enum.at(nList,i-1), charlists: :as_lists)
                neighbourIndex=Enum.at(mynList,j-1)
                #IO.inspect(Enum.at(mynList,j-1))
                myPID=findPID(neighbourIndex,pidTupleList)
                #IO.inspect("Hello")
                #IO.inspect(findPID(neighbourIndex,pidTupleList))
                myPID
                #IO.inspect(myPID)
                end
                [smallnListPID]
        else
           IO.puts("The topology is broken so Gossip won't be executed.")
           System.halt(0) 
        end
    end
        nListPID
        
    end

    def findPID(index,pidTupleList) do
        #IO.inspect(pidTupleList)
        #IO.inspect(Enum.at(pidTupleList,index-1))
        myTuple=Enum.at(pidTupleList,index-1)
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

    def calc_Dist(index1, index2, corList) do
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
