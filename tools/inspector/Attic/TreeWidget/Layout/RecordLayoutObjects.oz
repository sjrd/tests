%%%
%%% Author:
%%%   Thorsten Brunklaus <bruni@ps.uni-sb.de>
%%%
%%% Copyright:
%%%   Thorsten Brunklaus, 1997-1998
%%%
%%% Last Change:
%%%   $Date$ by $Author$
%%%   $Revision$
%%%

%%%
%%% RecordLayoutObjects
%%%

%% RecordLayoutObject

class RecordLayoutObject
   from
      LayoutObject

   attr
      layoutMode %% Layout Mode
      labelXDim  %% X Dimension of Label
      lastXDim   %% X Dimension (Last Entry)
      
   meth layout
      case @dazzle
      then
	 Label = @label
      in
	 {Label layout}
	 {@brace layout}
	 labelXDim <- {Label getXDim($)}
	 RecordLayoutObject, performLayoutCheck(1)
	 case @layoutMode
	 of horizontal then RecordLayoutObject, horizontalLayout(1 @labelXDim)
	 [] vertical   then RecordLayoutObject, verticalLayout(1 0 0)
	 end
	 dazzle <- false
	 dirty  <- true
      else skip
      end
   end

   meth performLayoutCheck(I)
      _|Node   = {Dictionary.get @items I}
      NodeType = {Node getType($)}
   in
      case NodeType
      of record       then layoutMode <- vertical
      [] kindedRecord then layoutMode <- vertical
      [] hashTuple    then layoutMode <- vertical
      [] pipeTuple    then layoutMode <- vertical
      [] labelTuple   then layoutMode <- vertical
      [] list         then layoutMode <- vertical
      else
	 case I < @width
	 then RecordLayoutObject, performLayoutCheck((I + 1))
	 else layoutMode <- horizontal
	 end
      end
   end

   meth horizontalLayout(I XDim)
      Label|Node = {Dictionary.get @items I}
      LabelXDim NodeXDim
   in
      {Label layout}
      {Node layout}
      LabelXDim = {Label getXDim($)}
      NodeXDim  = {Node getXDim($)}      
      case I < @width
      then RecordLayoutObject, horizontalLayout((I + 1)
						(XDim + LabelXDim + NodeXDim))
      else
	 xDim     <- (XDim + LabelXDim + NodeXDim + I)
	 yDim     <- 1
	 lastXDim <- @xDim
      end
   end

   meth verticalLayout(I XDim YDim)
      Label|Node  = {Dictionary.get @items I}
      IXDim IYDim LabelXDim
   in
      {Label layout}
      {Node layout}
      IXDim|IYDim = {Node getXYDim($)}
      LabelXDim   = {Label getXDim($)}      
      case I < @width
      then
	 RecordLayoutObject, verticalLayout((I + 1)
					    {Max XDim (LabelXDim + IXDim)}
					    (YDim + IYDim))
      else
	 TXDim  = ({Node getLastXDim($)} + 1)
	 RLXDim = @labelXDim
	 NXDim  = {Max IXDim TXDim}
      in
	 xDim     <- RLXDim + {Max XDim (LabelXDim + NXDim)}
	 yDim     <- (YDim + IYDim)
	 lastXDim <- (RLXDim + LabelXDim + TXDim) 
      end
   end
   
   meth getLastXDim($)
      @lastXDim
   end

   meth setLastXDim(XDim)
      lastXDim <- XDim
   end
end

%% KindedRecordLayoutObject

class KindedRecordLayoutObject
   from
      RecordLayoutObject
end

%% RecordCycleLayoutObject

class RecordCycleLayoutObject
   from
      RecordLayoutObject

   attr
      cycleCount : 0 %% Record Cycle Count
      oldCycleCount  %% Previus CycleCount
      
   meth layout
      case @dazzle
      then
	 case @cycleCount
	 of 0 then oldCycleCount <- 0
	 else oldCycleCount <- (cycleCount <- 0)
	 end
	 RecordLayoutObject, layout
	 case @cycleCount
	 of 0 then skip
	 else
	    Cycle = @cycleNode
	    XDim
	 in
	    {Cycle layout}
	    XDim = {Cycle getXDim($)}
	    xDim     <- (XDim + @xDim)
	    lastXDim <- (XDim + @lastXDim) 
	 end
      else skip
      end
   end

   meth incCycleCount
      cycleCount <- (@cycleCount + 1)
   end
end

%% KindedRecordCycleLayoutObject

class KindedRecordCycleLayoutObject
   from
      RecordCycleLayoutObject
end
