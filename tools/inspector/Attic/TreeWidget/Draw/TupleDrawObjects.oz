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
%%% TupleDrawObjects
%%%

local
   class TupleShareDrawObject
      from
	 DrawObject

      meth draw(X Y)
	 case @dirty
	 then
	    xAnchor <- X
	    yAnchor <- Y
	    case @layoutMode
	    of horizontal then TupleShareDrawObject, horizontalDraw(1 X Y)
	    [] vertical   then TupleShareDrawObject, verticalDraw(1 X Y)
	    end
	    dirty <- false
	 else skip
	 end
      end

      meth horizontalDraw(I X Y)
	 case I < @width
	 then
	    Node|Separator = {Dictionary.get @items I}
	    XDim           = {Node getXDim($)}
	    DeltaX         = (X + XDim)
	 in
	    {Node draw(X Y)}
	    {Separator draw(DeltaX Y)}
	    TupleShareDrawObject, horizontalDraw((I + 1) (DeltaX + 1) Y)
	 else
	    Node = {Dictionary.get @items I}
	 in
	    {Node draw(X Y)}
	 end
      end

      meth verticalDraw(I X Y)
	 case I < @width
	 then
	    Node|Separator = {Dictionary.get @items I}
	    YDim           = {Node getYDim($)}
	    LXDim          = {Node getLastXDim($)}
	    DeltaY         = (Y + YDim)
	 in
	    {Node draw(X Y)}
	    {Separator draw((X + LXDim) (DeltaY - 1))}
	    TupleShareDrawObject, verticalDraw((I + 1) X DeltaY)
	 else
	    Node = {Dictionary.get @items I}
	 in
	    {Node draw(X Y)}
	 end
      end
      
      meth undraw
	 TupleShareDrawObject, performUndraw(1)
	 dirty <- true
      end

      meth performUndraw(I)
	 case I < @width
	 then
	    Node|Separator = {Dictionary.get @items I}
	 in
	    {Node undraw}
	    {Separator undraw}
	    TupleShareDrawObject, performUndraw((I + 1))
	 else
	    Node = {Dictionary.get @items I}
	 in
	    {Node undraw}
	 end
      end

      meth assignStack(OldNode)
	 skip
      end
      
      meth replace(I Value Call)
	 Items = @items
	 Node
      in
	 case I < @width
	 then
	    OldNode|Separator = {Dictionary.get @items I}
	 in
	    {OldNode undraw}
	    Node = {self Call(OldNode Value $)}
	    case {OldNode isProxy($)}
	    then {OldNode alter(Node)}
	    else {Dictionary.put Items I Node|Separator}
	    end
	 else
	    OldNode = {Dictionary.get @items I}
	 in
	    {OldNode undraw}
	    Node = {self Call(OldNode Value $)}
	    case {OldNode isProxy($)}
	    then {OldNode alter(Node)}
	    else {Dictionary.put Items I Node}
	    end
	 end
	 {Node setParentData(self I)}
	 TupleShareDrawObject, notify
      end

      meth replaceNormal(OldNode Value $)
	 {Create Value @visual @depth}
      end

      meth replaceDepth(OldNode Value $)
	 RValue = {OldNode getValue($)}
	 Node   = {New BitmapTreeNode create(depth @visual @depth)}
      in
	 {Node setRescueValue(RValue)}
	 Node
      end
      
      meth link(I Value)
	 Items = @items
	 Node
      in
	 case I < @width
	 then
	    OldNode|Separator = {Dictionary.get @items I}
	    Proxy             = {New ProxyNode create(OldNode Node)}
	 in
	    Node = {self replaceNormal(OldNode Value $)}
	    {OldNode undraw}
	    {Dictionary.put Items I Proxy|Separator}
	 else
	    OldNode = {Dictionary.get @items I}
	    Proxy   = {New ProxyNode create(OldNode Node)}
	 in
	    Node = {self replaceNormal(OldNode Value $)}
	    {OldNode undraw}
	    {Dictionary.put Items I Proxy}
	 end
	 {Node setParentData(self I)}
	 TupleShareDrawObject, notify
      end

      meth unlink(I)
	 Items = @items
      in
	 case I < @width
	 then
	    OldNode|Separator = {Dictionary.get Items I}
	    Node              = {OldNode delete($)}
	 in
	    {OldNode undraw}
	    {Dictionary.put Items I Node|Separator}
	 else
	    OldNode = {Dictionary.get Items I}
	    Node    = {OldNode delete($)}
	 in
	    {OldNode undraw}
	    {Dictionary.put Items I Node}
	 end
	 TupleShareDrawObject, notify
      end

      meth shrink(I)
	 {@parent unlink(@index)}
      end
      
      meth menuHint(Index Status)
	 case Index < @width
	 then
	    Node|_ = {Dictionary.get @items Index}
	 in
	    {Node setMenuStatus(Status)}
	 else
	    Node = {Dictionary.get @items Index}
	 in
	    {Node setMenuStatus(Status)}
	 end
      end
      
      meth notify
	 dazzle <- true
	 {@parent notify}
      end
      
      meth moveNodeXY(X XF Y YF)
	 case @dirty
	 then skip
	 else
	    xAnchor <- (@xAnchor + X)
	    yAnchor <- (@yAnchor + Y)
	    TupleShareDrawObject, performMoveNodeXY(1 X XF Y YF)
	 end
      end

      meth performMoveNodeXY(I X XF Y YF)
	 case I < @width
	 then
	    Node|Separator = {Dictionary.get @items I}
	 in
	    {Node moveNodeXY(X XF Y YF)}
	    {Separator moveNodeXY(X XF Y YF)}
	    TupleShareDrawObject, performMoveNodeXY((I + 1) X XF Y YF)
	 else
	    Node = {Dictionary.get @items I}
	 in
	    {Node moveNodeXY(X XF Y YF)}
	 end
      end
      
      meth reDraw(X Y)
	 case @dirty
	 then
	    xAnchor <- X
	    yAnchor <- Y
	    case @layoutMode
	    of horizontal then TupleShareDrawObject, horizontalReDraw(1 X Y)
	    [] vertical   then TupleShareDrawObject, verticalReDraw(1 X Y)
	    end
	    dirty <- false
	 else
	    DeltaX = (X - @xAnchor)
	    DeltaY = (Y - @yAnchor)
	 in
	    case DeltaX
	    of 0 then
	       case DeltaY
	       of 0 then skip
	       else
		  TupleShareDrawObject, moveNodeXY(DeltaX (DeltaX * @xf)
						   DeltaY (DeltaY * @yf))
	       end
	    else
	       TupleShareDrawObject, moveNodeXY(DeltaX (DeltaX * @xf)
						DeltaY (DeltaY * @yf))
	    end
	 end
      end

      meth horizontalReDraw(I X Y)
	 case I < @width
	 then
	    Node|Separator = {Dictionary.get @items I}
	    XDim           = {Node getXDim($)}
	    DeltaX         = (X + XDim)
	 in
	    {Node reDraw(X Y)}
	    {Separator reDraw(DeltaX Y)}
	    TupleShareDrawObject, horizontalReDraw((I + 1) (DeltaX + 1) Y)
	 else
	    Node = {Dictionary.get @items I}
	 in
	    {Node reDraw(X Y)}
	 end
      end

      meth verticalReDraw(I X Y)
	 case I < @width
	 then
	    Node|Separator = {Dictionary.get @items I}
	    YDim           = {Node getYDim($)}
	    LXDim          = {Node getLastXDim($)}
	    DeltaY         = (Y + YDim)
	 in
	    {Node reDraw(X Y)}
	    {Separator reDraw((X + LXDim) (DeltaY - 1))}
	    TupleShareDrawObject, verticalReDraw((I + 1) X DeltaY)
	 else
	    Node = {Dictionary.get @items I}
	 in
	    {Node reDraw(X Y)}
	 end
      end

      meth searchNode(Coord $)
	 coord(X Y) = Coord
      in
	 case @layoutMode
	 of horizontal then
	    TupleShareDrawObject, horizontalSearch(1 0 X $)
	 [] vertical   then
	    TupleShareDrawObject, verticalSearch(1 0 X Y $)
	 end
      end
      
      meth horizontalSearch(I Min X $)
	 case I < @width
	 then
	    Node|_ = {Dictionary.get @items I}
	    Max    = (Min + {Node getXDim($)})
	 in
	    case X >= Min andthen X =< Max
	    then {Node searchNode(coord((X - Min) 0) $)}
	    else TupleShareDrawObject, horizontalSearch((I + 1) (Max + 1) X $)
	    end
	 else
	    Node = {Dictionary.get @items I}
	    Max  = (Min + {Node getXDim($)}) 
	 in
	    case X >= Min andthen X =< Max
	    then {Node searchNode(coord((X - Min) 0) $)}
	    else nil
	    end
	 end
      end

      meth verticalSearch(I Min X Y $)
	 case I < @width
	 then
	    Node|_ = {Dictionary.get @items I}
	    Max    = (Min + {Node getYDim($)})
	 in
	    case Y >= Min andthen Y =< Max
	    then {Node searchNode(coord(X (Y - Min)) $)}
	    else TupleShareDrawObject, verticalSearch((I + 1) Max X Y $)
	    end
	 else
	    Node = {Dictionary.get @items I}
	    Max  = (Min + {Node getXDim($)})
	 in
	    case Y >= Min andthen Y =< Max
	    then {Node searchNode(coord(X (Y - Min)) $)}
	    else nil
	    end
	 end
      end
 
      meth handleWidthExpansion(N Index)
	 case N > 0
	 then
	    Node = {Dictionary.get @items Index}
	    Type = {Node getType($)}
	 in
	    case Type
	    of widthBitmap then
	       NewWidth = {Min ((@width - 1) + N) @widthLen}
	    in
	       {Node undraw}
	       {self adjustWidth(NewWidth Index)}
	       TupleShareDrawObject, notify
	    else skip
	    end
	 elsecase N
	 of 0 then skip
	 else
	    WidthLen = @widthLen
	    Width    = @width
	    Node     = {Dictionary.get @items Index}
	    Type     = {Node getType($)}
	    DelCount NewWidth NewIndex
	 in
	    case Type
	    of widthBitmap then
	       NewWidth = {Max (@width - 1 + N) 0}
	       DelCount = {Min ({Abs N} + 1) Width}
	    else
	       NewWidth = {Max (@width + N) 0}
	       DelCount = {Min {Abs N} WidthLen}
	    end
	    NewIndex = {Max (Index - DelCount + 1) 1}
	    case @type
	    of list then
	       {@obrace undraw}
	       {@cbrace undraw}
	       {self addSeparators(NewIndex - 1)}
	    else skip
	    end
	    {self eraseNodes(Index DelCount)}
	    {self adjustWidth(NewWidth NewIndex)}
	    TupleShareDrawObject, notify
	 end
      end
   
      meth eraseNodes(Index N)
	 case Index < @width
	 then
	    Node|Separator = {Dictionary.get @items Index}
	 in
	    {Node undraw}
	    {Separator undraw}
	 else
	    Node = {Dictionary.get @items Index}
	 in
	    {Node undraw}
	 end
	 case N > 1
	 then TupleShareDrawObject, eraseNodes((Index - 1) (N - 1))
	 else skip
	 end
      end

      meth handleDepthExpansion(N Value Index)
	 case N < 0
	 then {@parent up((N + 1) @index)}
	 elsecase N
	 of 0 then skip
	 else
	    Items    = @items
	    Visual   = @visual
	    OldDepth = {Visual getDepth($)}
	    NewDepth = (@depth + N - 1)
	    Node NewNode
	 in
	    case Index < @width
	    then
	       Separator
	    in
	       Node|Separator = {Dictionary.get Items Index}
	       {Dictionary.put Items Index NewNode|Separator}
	    else
	       Node = {Dictionary.get Items Index}
	       {Dictionary.put Items Index NewNode}
	    end
	    {Visual setDepth(NewDepth)}
	    NewNode = {self replaceNormal(Node Value $)}
	    {Visual setDepth(OldDepth)}
	    {Node undraw}
	    {NewNode setParentData(self Index)}
	    TupleShareDrawObject, notify
	 end
      end
   
      meth up(N I)
	 case N < 0
	 then {@parent up((N + 1) @index)}
	 else {self replace(I @value replaceDepth)}
	 end
      end
   end

   class TupleShareCycleDrawObject
      from
	 TupleShareDrawObject
	 
      meth draw(X Y)
	 case @cycleCount
	 of 0 then
	    TupleShareDrawObject, draw(X Y)
	 else
	    CycleNode = @cycleNode
	    XDim      = {CycleNode getXDim($)}
	    DeltaX    = (X + XDim)
	    DeltaY    = (Y + (@yDim - 1))
	    DeltaXX   = (X + (@lastXDim - 1))
	 in
	    {CycleNode draw(X Y)}
	    {@cobrace draw(DeltaX Y)}
	    TupleShareDrawObject, draw((DeltaX + 1) Y)
	    {@ccbrace draw(DeltaXX DeltaY)}
	 end
      end
      
      meth undraw
	 case @cycleCount
	 of 0 then
	    TupleShareDrawObject, performUndraw(1)
	 else
	    {@cycleNode undraw}
	    {@cobrace undraw}
	    TupleShareDrawObject, performUndraw(1)
	    {@ccbrace undraw}
	 end
	 dirty <- true
      end

      meth assignStack(OldNode)
	 OldStack = {OldNode getStack($)}
      in
	 {@cycleMan setStack(OldStack)}
      end
      
      meth replaceNormal(OldNode Value $)
	 CycleMan = @cycleMan
	 OldStack = {OldNode getStack($)}
	 Node
      in
	 {CycleMan setStack(OldStack)}
	 {CycleMan push}
	 Node = {CycleCreate Value @visual CycleMan @depth}
	 {CycleMan pop}
	 {CycleMan tellStack(Node)}
	 Node
      end

      meth replaceDepth(OldNode Value $)
	 RValue   = {OldNode getValue($)}
	 OldStack = {OldNode getStack($)}
	 Node     = {New BitmapTreeNode create(depth @visual @depth)}
      in
	 {Node setRescueValue(RValue)}
	 {Node setStack(OldStack)}
	 Node
      end

      meth moveNodeXY(X XF Y YF)
	 case @dirty
	 then skip
	 elsecase @cycleCount
	 of 0 then
	    xAnchor <- (@xAnchor + X)
	    yAnchor <- (@yAnchor + Y)
	    TupleShareDrawObject, performMoveNodeXY(1 X XF Y YF)
	 else
	    {@cycleNode moveNodeXY(X XF Y YF)}
	    {@cobrace moveNodeXY(X XF Y YF)}
	    xAnchor <- (@xAnchor + X)
	    yAnchor <- (@yAnchor + Y)
	    TupleShareDrawObject, performMoveNodeXY(1 X XF Y YF)
	    {@ccbrace moveNodeXY(X XF Y YF)}
	 end
      end

      meth reDraw(X Y)
	 case @cycleCount
	 of 0 then
	    case @oldCycleCount
	    of 0 then skip
	    else
	       {@cobrace undraw}
	       {@cycleNode undraw}
	       {@ccbrace undraw}
	    end
	    TupleShareDrawObject, reDraw(X Y)
	 else
	    CycleNode = @cycleNode
	    XDim      = {CycleNode getXDim($)}
	    DeltaX    = (X + XDim)
	    DeltaY    = (Y + (@yDim - 1))
	    DeltaXX   = (X + (@lastXDim - 1))
	 in
	    {CycleNode reDraw(X Y)}
	    {@cobrace reDraw(DeltaX Y)}
	    TupleShareDrawObject, reDraw((DeltaX + 1) Y)
	    {@ccbrace reDraw(DeltaXX DeltaY)}	    
	 end
      end

      meth searchNode(Coord $)
	 case @cycleCount
	 of 0 then TupleShareDrawObject, searchNode(Coord $)
	 else
	    coord(X Y) = Coord
	    RXDim      = ({@cycleNode getXDim($)} + 1)
	 in
	    TupleShareDrawObject, searchNode(coord((X - RXDim) Y) $)
	 end
      end
   end
in
   
   %% HashTupleDrawObject

   class HashTupleDrawObject
      from
	 TupleShareDrawObject
   end

   %% PipeTupleDrawObject
   
   class PipeTupleDrawObject
      from
	 TupleShareDrawObject

      meth draw(X Y)
	 case @type
	 of pipeTuple then TupleShareDrawObject, draw(X Y)
	 [] list      then PipeTupleDrawObject, fastDraw(X Y)
	 end
      end

      meth fastDraw(X Y)
	 case @dirty
	 then
	    xAnchor <- X
	    yAnchor <- Y
	    {@obrace draw(X Y)}
	    case @layoutMode
	    of horizontal then PipeTupleDrawObject, fastHorizontalDraw(1
								       (X + 1)
								       Y)
	    [] vertical   then PipeTupleDrawObject, fastVerticalDraw(1
								     (X + 1)
								     Y)
	    end
	    dirty <- false
	 else skip
	 end
      end

      meth fastHorizontalDraw(I X Y)
	 Node = {Dictionary.get @items I}
	 XDim = {Node getXDim($)}
      in
	 {Node draw(X Y)}
	 case I < @width
	 then PipeTupleDrawObject, fastHorizontalDraw((I + 1) (X + (XDim+1)) Y)
	 else {@cbrace draw((X + XDim) Y)}
	 end
      end

      meth fastVerticalDraw(I X Y)
	 Node = {Dictionary.get @items I}
	 YDim = {Node getYDim($)}
      in
	 {Node draw(X Y)}
	 case I < @width
	 then PipeTupleDrawObject, fastVerticalDraw((I + 1) X (Y + YDim))
	 else
	    LXDim = {Node getLastXDim($)}
	 in
	    {@cbrace draw((X + LXDim) (Y + (YDim - 1)))}
	 end
      end
      
      meth undraw
	 case @type
	 of pipeTuple then TupleShareDrawObject, undraw
	 [] list      then PipeTupleDrawObject, fastUndraw
	 end
      end

      meth fastUndraw
	 {@obrace undraw}
	 {@cbrace undraw}
	 PipeTupleDrawObject, performFastUndraw(1)
	 dirty <- true
      end
      
      meth performFastUndraw(I)
	 Node = {Dictionary.get @items I}
      in
	 {Node undraw}
	 case I < @width
	 then PipeTupleDrawObject, performFastUndraw((I + 1))
	 else skip
	 end
      end

      meth replace(I Value Call)
	 case @type
	 of pipeTuple then
	    case I < @width
	    then TupleShareDrawObject, replace(I Value Call)
	    else PipeTupleDrawObject, slowReplace(I Value Call)
	    end
	 [] list      then PipeTupleDrawObject, fastReplace(I Value Call)
	 end
      end

      meth link(I Value)
	 case @type
	 of pipeTuple then TupleShareDrawObject, link(I Value)
	 [] list      then PipeTupleDrawObject, fastLink(I Value)
	 end
      end

      meth unlink(I)
	 case @type
	 of pipeTuple then TupleShareDrawObject, unlink(I)
	 [] list      then PipeTupleDrawObject, fastUnlink(I)
	 end
      end
      
      meth slowReplace(I Value Call)
	 Items   = @items
	 OldNode = {Dictionary.get Items I}
      in
	 {OldNode undraw}
	 case {OldNode isProxy($)}
	 then TupleShareDrawObject, replace(I Value Call)
	 else
	    case Call
	    of replaceNormal then
	       {self assignStack(OldNode)}
	       {self performInsertion(I Value)}
	    else
	       Node = {self replaceDepth(OldNode Value $)}
	    in
	       {Node setParentData(self I)}
	       {Dictionary.put Items I Node}
	    end
	 end
	 TupleShareDrawObject, notify
      end

      meth fastReplace(I Value Call)
	 Items   = @items
	 OldNode = {Dictionary.get Items I}
	 Node    = {self Call(OldNode Value $)}
      in
	 {OldNode undraw}
	 {Node setParentData(self I)}
	 case {OldNode isProxy($)}
	 then {OldNode alter(Node)}
	 else {Dictionary.put Items I Node}
	 end
	 TupleShareDrawObject, notify
      end

      meth fastLink(I Value)
	 Items   = @items
	 OldNode = {Dictionary.get Items I}
	 Node    = {self replaceNormal(OldNode Value $)}
	 Proxy   = {New ProxyNode create(OldNode Node)}
      in
	 {Node setParentData(self I)}
	 {OldNode undraw}
	 {Dictionary.put Items I Proxy}
	 TupleShareDrawObject, notify
      end

      meth fastUnlink(I)
	 Items   = @items
	 OldNode = {Dictionary.get Items I}
	 Node    = {OldNode delete($)}
      in
	 {OldNode undraw}
	 {Dictionary.put Items I Node}
	 TupleShareDrawObject, notify
      end

      meth menuHint(Index Status)
	 case @type
	 of pipeTuple then TupleShareDrawObject, menuHint(Index Status)
	 [] list then
	    Node = {Dictionary.get @items Index}
	 in
	    {Node setMenuStatus(Status)}
	 end
      end

      meth moveNodeXY(X XF Y YF)
	 case @type
	 of pipeTuple then TupleShareDrawObject, moveNodeXY(X XF Y YF)
	 [] list      then PipeTupleDrawObject, fastMoveNodeXY(X XF Y YF)
	 end
      end

      meth fastMoveNodeXY(X XF Y YF)
	 case @dirty
	 then skip
	 else
	    xAnchor <- (@xAnchor + X)
	    yAnchor <- (@yAnchor + Y)
	    {@obrace moveNodeXY(X XF Y YF)}
	    PipeTupleDrawObject, performMoveNodeXY(1 X XF Y YF)
	 end
      end

      meth performMoveNodeXY(I X XF Y YF)
	 Node = {Dictionary.get @items I}
      in
	 {Node moveNodeXY(X XF Y YF)}
	 case I < @width
	 then PipeTupleDrawObject, performMoveNodeXY((I + 1) X XF Y YF)
	 else {@cbrace moveNodeXY(X XF Y YF)}
	 end
      end
      
      meth reDraw(X Y)
	 case @type
	 of pipeTuple then TupleShareDrawObject, reDraw(X Y)
	 [] list      then PipeTupleDrawObject, fastReDraw(X Y)
	 end
      end

      meth fastReDraw(X Y)
	 case @dirty
	 then
	    xAnchor <- X
	    yAnchor <- Y
	    {@obrace reDraw(X Y)}
	    case @layoutMode
	    of horizontal then
	       PipeTupleDrawObject, fastHorizontalReDraw(1 (X + 1) Y)
	    [] vertical   then
	       PipeTupleDrawObject, fastVerticalReDraw(1 (X + 1) Y)
	    end
	    dirty <- false
	 else
	    DeltaX = (X - @xAnchor)
	    DeltaY = (Y - @yAnchor)
	 in
	    case DeltaX
	    of 0 then
	       case DeltaY
	       of 0 then skip
	       else
		  PipeTupleDrawObject, moveNodeXY(DeltaX (DeltaX * @xf)
						  DeltaY (DeltaY * @yf))
	       end
	    else
	       PipeTupleDrawObject, moveNodeXY(DeltaX (DeltaX * @xf)
					       DeltaY (DeltaY * @yf))
	    end
	 end
      end

      meth fastHorizontalReDraw(I X Y)
	 Node = {Dictionary.get @items I}
	 XDim = {Node getXDim($)}
      in
	 {Node reDraw(X Y)}
	 case I < @width
	 then
	    PipeTupleDrawObject, fastHorizontalReDraw((I + 1) (X + (XDim+1)) Y)
	 else
	    {@cbrace reDraw((X + XDim) Y)}
	 end
      end

      meth fastVerticalReDraw(I X Y)
	 Node = {Dictionary.get @items I}
	 YDim = {Node getYDim($)}
      in
	 {Node reDraw(X Y)}
	 case I < @width
	 then PipeTupleDrawObject, fastVerticalReDraw((I + 1) X (Y + YDim))
	 else
	    LXDim = {Node getLastXDim($)}
	 in
	    {@cbrace reDraw((X + LXDim) (Y + (YDim - 1)))}
	 end
      end

      meth searchNode(Coord $)
	 case @type
	 of pipeTuple then TupleShareDrawObject, searchNode(Coord $)
	 [] list      then PipeTupleDrawObject, fastSearchNode(Coord $)
	 end
      end

      meth fastSearchNode(Coord $)
	 coord(X Y) = Coord
      in
	 case @layoutMode
	 of horizontal then
	    PipeTupleDrawObject, fastHorizontalSearch(1 1 X $)
	 [] vertical   then
	    PipeTupleDrawObject, fastVerticalSearch(1 0 (X - 1) Y $)
	 end
      end

      meth fastHorizontalSearch(I Min X $)
	 case I =< @width
	 then
	    Node = {Dictionary.get @items I}
	    Max  = (Min + {Node getXDim($)})
	 in
	    case X >= Min andthen X =< Max
	    then
	       {Node searchNode(coord((X - Min) 0) $)}
	    else
	       PipeTupleDrawObject, fastHorizontalSearch((I + 1) (Max + 1) X $)
	    end
	 else nil
	 end
      end

      meth fastVerticalSearch(I Min X Y $)
	 case I =< @width
	 then
	    Node = {Dictionary.get @items I}
	    Max  = (Min + {Node getYDim($)})
	 in
	    case Y >= Min andthen Y =< Max
	    then {Node searchNode(coord(X (Y - Min)) $)}
	    else PipeTupleDrawObject, fastVerticalSearch((I + 1) Max X Y $)
	    end
	 else nil
	 end
      end

      meth handleWidthExpansion(N Index)
	 case N > 0
	 then
	    widthLen <- (@width + N)
	    TupleShareDrawObject, handleWidthExpansion(N Index)
	 elsecase N
	 of 0 then skip
	 else
	    widthLen <- @width
	    TupleShareDrawObject, handleWidthExpansion(N Index)
	 end
      end
      
      meth eraseNodes(Index N)
	 case @type
	 of pipeTuple then TupleShareDrawObject, eraseNodes(Index N)
	 [] list      then PipeTupleDrawObject, fastEraseNodes(Index N)
	 end
      end

      meth fastEraseNodes(Index N)
	 Node = {Dictionary.get @items Index}
      in
	 {Node undraw}
	 case N > 1
	 then PipeTupleDrawObject, fastEraseNodes((Index - 1) (N - 1))
	 else skip
	 end
      end
      
      meth handleDepthExpansion(N Value Index)
	 case @type
	 of pipeTuple then
	    TupleShareDrawObject, handleDepthExpansion(N Value Index)
	 [] list      then
	    PipeTupleDrawObject, fastHandleDepthExpansion(N Value Index)
	 end
      end
      
      meth fastHandleDepthExpansion(N Value Index)
	 case N < 0
	 then {@parent up((N + 1) @index)}
	 elsecase N
	 of 0 then skip
	 else
	    Items    = @items
	    Visual   = @visual
	    OldDepth = {Visual getDepth($)}
	    NewDepth = (@depth + N - 1)
	    Node     = {Dictionary.get Items Index}
	    NewNode
	 in
	    {Visual setDepth(NewDepth)}
	    NewNode = {self replaceNormal(Node Value $)}
	    {Visual setDepth(OldDepth)}
	    {Node undraw}
	    {NewNode setParentData(self Index)}
	    {Dictionary.put Items Index NewNode}
	    TupleShareDrawObject, notify
	 end
      end
   end

   %% HashTupleCycleDrawObject

   class HashTupleCycleDrawObject
      from
	 TupleShareCycleDrawObject
   end

   %% PipeTupleCycleDrawObject

   class PipeTupleCycleDrawObject
      from
	 PipeTupleDrawObject
	 TupleShareCycleDrawObject

      meth draw(X Y)
	 case @cycleCount
	 of 0 then
	    PipeTupleDrawObject, draw(X Y)
	 else
	    CycleNode = @cycleNode
	    XDim      = {CycleNode getXDim($)}
	 in
	    {CycleNode draw(X Y)}
	    case @type
	    of pipeTuple then
	       DeltaX = (X + XDim)
	    in
	       {@cobrace draw((X + XDim) Y)}
	       TupleShareDrawObject, draw((DeltaX + 1) Y)
	       {@ccbrace draw((X + (@lastXDim - 1)) (Y + (@yDim - 1)))}
	    [] list      then
	       PipeTupleDrawObject, fastDraw((X + XDim) Y)
	    end
	 end
      end
      
      meth undraw
	 case @cycleCount
	 of 0 then
	    case @type
	    of pipeTuple then TupleShareDrawObject, undraw
	    [] list      then PipeTupleDrawObject, fastUndraw
	    end
	 else
	    CycleNode = @cycleNode
	 in
	    {CycleNode undraw}
	    case @type
	    of pipeTuple then
	       {@cobrace undraw}
	       TupleShareDrawObject, undraw
	       {@ccbrace undraw}
	    [] list      then
	       PipeTupleDrawObject, fastUndraw
	    end
	 end
      end

      meth replace(I Value Call)
	 case @type
	 of pipeTuple then
	    case I < @width
	    then TupleShareDrawObject, replace(I Value Call)
	    else PipeTupleDrawObject, slowReplace(I Value Call)
	    end
	 [] list      then
	    PipeTupleDrawObject, fastReplace(I Value Call)
	 end
      end

      meth replaceNormal(OldNode Value $)
	 TupleShareCycleDrawObject, replaceNormal(OldNode Value $)
      end

      meth replaceDepth(OldNode Value $)
	 TupleShareCycleDrawObject, replaceDepth(OldNode Value $)
      end

      meth moveNodeXY(X XF Y YF)
	 case @cycleCount
	 of 0 then
	    case @type
	    of pipeTuple then TupleShareDrawObject, moveNodeXY(X XF Y YF)
	    [] list      then PipeTupleDrawObject, fastMoveNodeXY(X XF Y YF)
	    end
	 else
	    {@cycleNode moveNodeXY(X XF Y YF)}
	    case @type
	    of pipeTuple then
	       {@cobrace moveNodeXY(X XF Y YF)}
	       TupleShareDrawObject, moveNodeXY(X XF Y YF)
	       {@ccbrace moveNodeXY(X XF Y YF)}
	    [] list      then
	       PipeTupleDrawObject, fastMoveNodeXY(X XF Y YF)
	    end
	 end
      end

      meth reDraw(X Y)
	 case @cycleCount
	 of 0 then
	    case @oldCycleCount
	    of 0 then skip
	    else
	       {@cobrace undraw}
	       {@cycleNode undraw}
	       {@ccbrace undraw}
	    end
	    PipeTupleDrawObject, reDraw(X Y)
	 else
	    CycleNode = @cycleNode
	    XDim      = {CycleNode getXDim($)}
	 in
	    {CycleNode reDraw(X Y)}
	    case @type
	    of pipeTuple then
	       DeltaX = (X + XDim)
	    in
	       {@cobrace reDraw(DeltaX Y)}
	       TupleShareDrawObject, reDraw((DeltaX + 1) Y)
	       {@ccbrace reDraw((X + (@lastXDim - 1)) (Y + (@yDim - 1)))}
	    [] list      then
	       PipeTupleDrawObject, fastReDraw((X + XDim) Y)
	    end
	 end
      end
   end
end

%% LabelTupleDrawObject

class LabelTupleDrawObject
   from
      DrawObject

   prop
      locking
      
   meth draw(X Y)
      case @dirty
      then
	 xAnchor <- X
	 yAnchor <- Y
	 {@label draw(X Y)}
	 case @layoutMode
	 of horizontal then
	    LabelTupleDrawObject, horizontalDraw(1 (X + @labelXDim) Y)
	 [] vertical   then
	    LabelTupleDrawObject, verticalDraw(1 (X + @labelXDim) Y)
	 end
	 dirty <- false
      else skip
      end
   end
   
   meth horizontalDraw(I X Y)
      Node = {Dictionary.get @items I}
      XDim = {Node getXDim($)}
   in
      {Node draw(X Y)}
      case I < @width
      then LabelTupleDrawObject, horizontalDraw((I + 1) (X + XDim + 1) Y)
      else {@brace draw((X + XDim) Y)}
      end
   end

   meth verticalDraw(I X Y)
      Node = {Dictionary.get @items I}
      YDim = {Node getYDim($)}
   in
      {Node draw(X Y)}
      case I < @width
      then
	 LabelTupleDrawObject, verticalDraw((I + 1) X (Y + YDim))
      else
	 LXDim = {Node getLastXDim($)}
      in
	 {@brace draw((X + LXDim) ((Y + YDim) - 1))}
      end
   end
   
   meth undraw
      {@label undraw}
      {@brace undraw}
      LabelTupleDrawObject, performUndraw(1)
      dirty <- true
   end

   meth performUndraw(I)
      Node = {Dictionary.get @items I}
   in
      {Node undraw}
      case I < @width
      then LabelTupleDrawObject, performUndraw((I + 1))
      else skip
      end
   end

   meth replace(I Value Call)
      Items   = @items
      OldNode = {Dictionary.get Items I}
      Node    = {self Call(OldNode Value $)}
   in
      {OldNode undraw}
      {Node setParentData(self I)}
      case {OldNode isProxy($)}
      then {OldNode alter(Node)}
      else {Dictionary.put Items I Node}
      end
      LabelTupleDrawObject, notify
   end

   meth replaceNormal(OldNode Value $)
      {Create Value @visual @depth}
   end

   meth replaceDepth(OldNode Value $)
      RValue = {OldNode getValue($)}
      Node   = {New BitmapTreeNode create(depth @visual @depth)}
   in
      {Node setRescueValue(RValue)}
      Node
   end
   
   meth link(I Value)
      Items   = @items
      OldNode = {Dictionary.get Items I}
      Node    = {self replaceNormal(OldNode Value $)}
      Proxy   = {New ProxyNode create(OldNode Node)}
   in
      {OldNode undraw}
      {Node setParentData(self I)}
      {Dictionary.put Items I Proxy}
      LabelTupleDrawObject, notify
   end
   
   meth unlink(I)
      Items   = @items
      OldNode = {Dictionary.get Items I}
      Node    = {OldNode delete($)}
   in
      {OldNode undraw}
      {Dictionary.put Items I Node}
      LabelTupleDrawObject, notify 
   end

   meth shrink(I)
      {@parent unlink(@index)}
   end
   
   meth notify
      dazzle <- true
      {@parent notify}
   end

   meth moveNodeXY(X XF Y YF)
      case @dirty
      then skip
      else
	 {@label moveNodeXY(X XF Y YF)}
	 LabelTupleDrawObject, performMoveNodeXY(1 X XF Y YF)
      end
   end

   meth performMoveNodeXY(I X XF Y YF)
      Node = {Dictionary.get @items I}
   in
      xAnchor <- (@xAnchor + X)
      yAnchor <- (@yAnchor + Y)
      {Node moveNodeXY(X XF Y YF)}
      case I < @width
      then LabelTupleDrawObject, performMoveNodeXY((I + 1) X XF Y YF)
      else {@brace moveNodeXY(X XF Y YF)}
      end
   end
   
   meth reDraw(X Y)
      case @dirty
      then
	 xAnchor <- X
	 yAnchor <- Y
	 {@label reDraw(X Y)}
	 case @layoutMode
	 of horizontal then
	    LabelTupleDrawObject, horizontalReDraw(1 (X + @labelXDim) Y)
	 [] vertical   then
	    LabelTupleDrawObject, verticalReDraw(1 (X + @labelXDim) Y)
	 end
	 dirty <- false
      else
	 DeltaX = (X - @xAnchor)
	 DeltaY = (Y - @yAnchor)
      in
	 case DeltaX
	 of 0 then
	    case DeltaY
	    of 0 then skip
	    else
	       LabelTupleDrawObject, moveNodeXY(DeltaX (DeltaX * @xf)
						DeltaY (DeltaY * @yf))
	    end
	 else
	    LabelTupleDrawObject, moveNodeXY(DeltaX (DeltaX * @xf)
					     DeltaY (DeltaY * @yf))
	 end
      end
   end

   meth horizontalReDraw(I X Y)
      Node = {Dictionary.get @items I}
      XDim = {Node getXDim($)}
   in
      {Node reDraw(X Y)}
      case I < @width
      then LabelTupleDrawObject, horizontalReDraw((I + 1) (X + XDim + 1) Y)
      else {@brace reDraw((X + XDim) Y)}
      end
   end

   meth verticalReDraw(I X Y)
      Node = {Dictionary.get @items I}
      YDim = {Node getYDim($)}
   in
      {Node reDraw(X Y)}
      case I < @width
      then
	 LabelTupleDrawObject, verticalReDraw((I + 1) X (Y + YDim))
      else
	 LXDim = {Node getLastXDim($)}
      in
	 {@brace reDraw((X + LXDim) ((Y + YDim) - 1))}
      end
   end

   meth searchNode(Coord $)
      coord(X Y) = Coord
      Label      = @label
      XDim       = {Label getXDim($)}
      LabelNode  = {Label searchNode(Coord $)}
   in
      case LabelNode
      of nil then
	 case @layoutMode
	 of horizontal then
	    LabelTupleDrawObject, horizontalSearch(1 XDim X $)
	 [] vertical   then
	    LabelTupleDrawObject, verticalSearch(1 0 (X - XDim) Y $)
	 end
      else LabelNode
      end
   end

   meth horizontalSearch(I Min X $)
      case I =< @width
      then
	 Node = {Dictionary.get @items I}
	 Max  = (Min + {Node getXDim($)})
      in
	 case X >= Min andthen X =< Max
	 then {Node searchNode(coord((X - Min) 0) $)}
	 else LabelTupleDrawObject, horizontalSearch((I + 1) (Max + 1) X $)
	 end
      else nil
      end
   end

   meth verticalSearch(I Min X Y $)
      case I =< @width
      then
	 Node = {Dictionary.get @items I}
	 Max  = (Min + {Node getYDim($)})
      in
	 case Y >= Min andthen Y =< Max
	 then {Node searchNode(coord(X (Y - Min)) $)}
	 else LabelTupleDrawObject, verticalSearch((I + 1) Max X Y $)
	 end
      else nil
      end
   end

   meth initMenu(Type)
      {@label initMenu(Type)}
   end

   meth updateMenu(Type Status)
      {@label updateMenu(Type Status)}
   end

   meth getMenu($)
      {@label getMenu($)}
   end

   meth setMenuStatus(Status)
      {@label setMenuStatus(Status)}
   end

   meth getMenuStatus($)
      {@label getMenuStatus($)}
   end

   meth menuHint(Index Status)
      Node = {Dictionary.get @items Index}
   in
      {Node setMenuStatus(Status)}
   end

   meth handleWidthExpansion(N Index)
      case N > 0
      then
	 Node = {Dictionary.get @items Index}
	 Type = {Node getType($)}
      in
	 case Type
	 of widthBitmap then
	    NewWidth = {Min ((@width - 1) + N) @widthLen}
	 in
	    LabelTupleDrawObject, eraseSingleNode(Index)
	    {self adjustWidth(NewWidth Index)}
	    LabelTupleDrawObject, notify
	 else skip
	 end
      elsecase N
      of 0 then skip
      else
	 WidthLen = @widthLen
	 Width    = @width
	Node      = {Dictionary.get @items Index}
	 Type     = {Node getType($)}
	 DelCount NewWidth NewIndex
      in
	 case Type
	 of widthBitmap then
	    NewWidth = {Max (@width - 1 + N) 0}
	    DelCount = {Min ({Abs N} + 1) Width}
	 else
	    NewWidth = {Max (@width + N) 0}
	    DelCount = {Min {Abs N} WidthLen}
	 end
	 NewIndex = {Max (Index - DelCount + 1) 1}
	 LabelTupleDrawObject, eraseNodes(Index DelCount)
	 {self adjustWidth(NewWidth NewIndex)}
	 LabelTupleDrawObject, notify
      end
   end

   meth eraseSingleNode(I)
      Node = {Dictionary.get @items I}
   in
      {Node undraw}
   end
   
   meth eraseNodes(Index N)
      LabelTupleDrawObject, eraseSingleNode(Index)
      case N > 1
      then LabelTupleDrawObject, eraseNodes((Index - 1) (N - 1))
      else skip
      end
   end

   meth handleDepthExpansion(N Value Index)
      case N < 0
      then {@parent up((N + 1) @index)}
      elsecase N
      of 0 then skip
      else
	 Items    = @items
	 Visual   = @visual
	 Node     = {Dictionary.get Items Index}
	 OldDepth = {Visual getDepth($)}
	 NewDepth = (@depth + N - 1)
	 NewNode
      in
	 {Visual setDepth(NewDepth)}
	 NewNode = {self replaceNormal(Node Value $)}
	 {Visual setDepth(OldDepth)}
	 {Node undraw}
	 {Dictionary.put Items Index NewNode}
	 {NewNode setParentData(self Index)}
	 LabelTupleDrawObject, notify
      end
   end
   
   meth up(N I)
      case N < 0
      then {@parent up((N + 1) @index)}
      else {self replace(I @value replaceDepth)}
      end
   end
end

%% LabelTupleCycleDrawObject

class LabelTupleCycleDrawObject
   from
      LabelTupleDrawObject

   meth draw(X Y)
      case @cycleCount
      of 0 then
	 LabelTupleDrawObject, draw(X Y)
      else
	 CycleNode = @cycleNode
	 XDim      = {CycleNode getXDim($)}
      in
	 {CycleNode draw(X Y)}
	 LabelTupleDrawObject, draw((X + XDim) Y)
      end
   end
   
   meth undraw
      case @cycleCount
      of 0 then skip
      else {@cycleNode undraw}
      end
      {@label undraw}
      {@brace undraw}
      LabelTupleDrawObject, performUndraw(1)
      dirty <- true
   end

   meth replaceNormal(OldNode Value $)
      OldStack = {OldNode getStack($)}
      CycleMan = @cycleMan
      Node
   in
      {CycleMan setStack(OldStack)}
      {CycleMan push}
      Node = {CycleCreate Value @visual CycleMan @depth}
      {CycleMan pop}
      {CycleMan tellStack(Node)}
      Node
   end

   meth replaceDepth(OldNode Value $)
      RValue   = {OldNode getValue($)}
      OldStack = {OldNode getStack($)}
      Node     = {New BitmapTreeNode create(depth @visual @depth)}
   in
      {Node setRescueValue(RValue)}
      {Node setStack(OldStack)}
      Node
   end
   
   meth moveNodeXY(X XF Y YF)
      case @dirty
      then skip
      else
	 case @cycleCount
	 of 0 then skip
	 else {@cycleNode moveNodeXY(X XF Y YF)}
	 end
	 {@label moveNodeXY(X XF Y YF)}
	 LabelTupleDrawObject, performMoveNodeXY(1 X XF Y YF)
      end
   end

   meth reDraw(X Y)
      case @cycleCount
      of 0 then
	 case @oldCycleCount
	 of 0 then skip
	 else {@cycleNode undraw}
	 end
	 LabelTupleDrawObject, reDraw(X Y)
      else
	 CycleNode = @cycleNode
	 XDim      = {CycleNode getXDim($)}
      in
	 {CycleNode reDraw(X Y)}
	 LabelTupleDrawObject, reDraw((X + XDim) Y)
      end
   end

   meth searchNode(Coord $)
      coord(X Y) = Coord
      Label      = @label
      XDim LabelNode
   in
      case @cycleCount
      of 0 then
	 XDim      = {Label getXDim($)}
	 LabelNode = {Label searchNode(Coord $)}
      else
	 RXDim = {@cycleNode getXDim($)}
      in
	 XDim      = ({Label getXDim($)} + RXDim) 
	 LabelNode = {Label searchNode(coord((X - RXDim) Y) $)}
      end
      case LabelNode
      of nil then
	 case @layoutMode
	 of horizontal then
	    LabelTupleDrawObject, horizontalSearch(1 XDim X $)
	 [] vertical   then
	    LabelTupleDrawObject, verticalSearch(1 0 (X - XDim) Y $)
	 end
      else LabelNode
      end
   end
end
