%%%  Programming Systems Lab, DFKI Saarbruecken,
%%%  Stuhlsatzenhausweg 3, D-66123 Saarbruecken, Phone (+49) 681 302-5312
%%%  Author: Christian Schulte
%%%  Email: schulte@dfki.uni-sb.de
%%%  Last modified: $Date$ by $Author$
%%%  Version: $Revision$

local

   local
      local
	 fun {DoFind As SA Bs SB G}
	    case As of nil then G
	    [] A|Ar then
	       case Bs of nil then G
	       [] B|Br then NSA=SA+A.2 NSB=SB+B.1 in
		  {DoFind Ar NSA Br NSB {Max G NSA-NSB+HorSpaceI}}
	       end
	    end
	 end
      in
	 fun {FindGap As Bs}
	    %% Computes the minimal gap needed between two shapes
	    {DoFind As 0 Bs 0 HorSpaceI}
	 end
      end

      local
	 fun {DoMerge As Bs DL DR}
	    case As of nil then
	       case Bs of nil then nil
	       [] B|Br then BL|BR=!B in ((BL + DL)|BR)|Br
	       end
	    [] A|Ar then
	       case Bs of nil then AL|AR=!A in (AL|(AR + DR))|Ar
	       [] B|Br then AL|AR=!A BL|BR=!B in
		  (AL|BR)|{DoMerge Ar Br DL-AL+BL DR+AR-BR}
	       end
	    end
	 end
      in
	 fun {MergeShapes As Bs D}
	    %% Merges two shapes As and Bs where Bs is translated by D
	    (AL|AR)|Ar=!As (BL|BR)|Br=!Bs
	 in
	    (AL|(BR+D))|{DoMerge Ar Br BL-AL+D AR-BR-D}
	 end
      end

      local
	 fun {FindLeftGaps A Bs PrevGap ?Width}
	    case Bs of nil then Width=PrevGap nil
	    [] B|Br then Gap={FindGap A B} in
	       Gap-PrevGap|{FindLeftGaps {MergeShapes A B Gap} Br Gap ?Width}
	    end
	 end
      in
	 fun {GetLeftGaps As ?Width}
	    case As of nil then Width=0 nil
	    [] A|Ar then {FindLeftGaps A Ar 0 Width}
	    end
	 end
      end

      
      local
	 fun {FindRightGaps A B|Br}
	    case Br of nil then
	       A=B nil
	    else
	       RightA
	       Gr  = {FindRightGaps RightA Br}
	       Gap = {FindGap B RightA}
	    in
	       A = {MergeShapes B RightA Gap}
	       Gap|Gr
	    end
	 end
      in
	 fun {GetRightGaps As ?Shape}
	    {FindRightGaps ?Shape As}
	 end
      end

      local
	 fun {GetOffsets As Bs RelPos}
	    case As of nil then nil
	    [] A|Ar then
	       B|Br      = !Bs
	       NewRelPos = (A + B) div 2 + RelPos
	    in
	       NewRelPos|{GetOffsets Ar Br NewRelPos}
	    end
	 end
      in
	 fun {Offsets As Bs HalfWidth}
	    ~HalfWidth | {GetOffsets As Bs ~HalfWidth}
	 end
      end

   in
   
      proc {ComputeLayout Shapes ?AdjShape ?NewOffsets}
	 case Shapes of nil then
	    AdjShape   = nil
	    NewOffsets = nil
	 [] Shape1|Shaper then
	    case Shaper of nil then
	       AdjShape   = Shape1
	       NewOffsets = [0]
	    [] Shape2|Shaper then
	       case Shaper of nil then
		  Width          = {FindGap Shape1 Shape2}
		  (A|B)|NewShape = {MergeShapes Shape1 Shape2 Width}
		  HalfWidth      = Width div 2
	       in
		  AdjShape   = ((A - HalfWidth)|(B - Width + HalfWidth))
		               |NewShape 
		  NewOffsets = [~HalfWidth HalfWidth]
	       else
		  Width NewShape A B
		  LeftGaps  = {GetLeftGaps  Shapes ?Width}
		  RightGaps = {GetRightGaps Shapes (A|B)|NewShape}
		  HalfWidth = Width div 2
	       in
		  AdjShape   = ((A - HalfWidth)|(B - Width + HalfWidth))
		               |NewShape 
		  NewOffsets = {Offsets LeftGaps RightGaps HalfWidth}
	       end
	    end
	 end
      end
      
   end


   local
      proc {Box Ss CL CR ML MR CD ?L ?R ?D}
	 case Ss
	 of nil then L=ML R=MR D=CD
	 [] S|Sr then SL|SR=!S NL=CL+SL NR=CR+SR in
	    {Box Sr NL NR {Min NL ML} {Max NR MR} CD+1 ?L ?R ?D}
	 end
      end
   in
      fun {GetBoundingBox Shape}
	 L R D
      in
	 {Box Shape 0 0 0 0 0 ?L ?R ?D}
	 bounding(L-HalfHorSpaceI R+HalfHorSpaceI D*VerSpaceI)
      end
   end
   
   RootExtent  = 0|0
   RootShape   = [RootExtent]
   HiddenShape = [RootExtent ~!HalfHorSpaceI|!HalfHorSpaceI]

   Layout = {NewName}
   Adjust = {NewName}

   
   class LayoutLeaf
      attr
	 offset: 0

      meth layout(Break Scale Font)
	 Canvas = self.canvas
	 Suffix = self.suffix
      in
	 LayoutLeaf,Layout(_ 0)
	           ,Adjust(Break TreePrefix#Suffix RootX 0 RootY Scale Font)
	 %% move away root link
	 {Canvas tk(move LinkPrefix#Suffix 0 ~VerSpaceF * MaxScale)}
	 {Canvas bounding(~HalfHorSpaceI HalfHorSpaceI VerSpaceI)}
      end

      meth !Layout(?Shape Offset)
	 Shape  =  RootShape
	 offset <- Offset|@offset   
      end
      
      meth !Adjust(Break MomTree MomX MomByX MyY Scale Font)
	 NewOffset|OldOffset = @offset
      in
	 case @isDrawn then
	    MyX                 = MomX   + NewOffset
	    MyByX               = MomByX + NewOffset - OldOffset
	 in
	    self,moveNode(MomX MyX MyByX MyY Scale)
	    offset <- NewOffset
	 else
	    self,drawTree(Break MomTree MomX MyY Scale Font)
	 end
      end

   end


   fun {LayoutKids Ks ?Os}
      case Ks of nil then Os=nil nil
      [] K|Kr then O|Or=!Os in {K Layout($ O)} | {LayoutKids Kr Or}
      end
   end

   
   proc {AdjustKids Ks Break MomTree MyX MyByX KidsY Scale Font}
      case Ks of nil then skip
      [] K|Kr then
	 {K Adjust(Break MomTree MyX MyByX KidsY Scale Font)}
	 {AdjustKids Kr Break MomTree MyX MyByX KidsY Scale Font}
      end
   end

   
   class LayoutNode
      attr
	 shape:  RootShape
	 offset: 0
      
      meth layout(Break Scale Font)
	 Canvas = self.canvas
	 Suffix = self.suffix
	 Shape  = LayoutNode,Layout($ 0)
      in
	 {Canvas {GetBoundingBox Shape}}
	 LayoutNode,Adjust(Break TreePrefix#Suffix
			   RootX 0 RootY Scale Font)
	 {Canvas tk(move LinkPrefix#Suffix 0 ~VerSpaceF * MaxScale)}
      end

      meth !Layout(?Shape Offset)
	 Shape = case @isDirty then SubShapes SubOffsets in
		    shape <- Shape
		    case @isHidden then HiddenShape
		    else
		       {LayoutKids @kids SubOffsets SubShapes}
		       RootExtent|{ComputeLayout SubShapes $ ?SubOffsets}
		    end
		 else @shape
		 end
	 offset <- Offset|@offset
      end
      
      meth !Adjust(Break MomTree MomX MomByX MyY Scale Font)
	 NewOffset|OldOffset = @offset
	 MyX                 = MomX + NewOffset
	 MyByX               = MomByX + NewOffset - OldOffset
      in
	 case @isDirty then
	    case @isDrawn then
	       isDirty <- False
	       offset  <- NewOffset
	       self,moveNode(MomX MyX MyByX MyY Scale)
	       case @isHidden then skip else
		  Suffix = self.suffix
	       in
		  {AdjustKids @kids Break TreePrefix#Suffix
		   MyX MyByX MyY+VerSpaceI Scale Font}
		  {self.canvas tk(addtag MomTree withtag TreePrefix#Suffix)}
	       end
	    else self,drawTree(Break MomTree MomX MyY Scale Font)
	    end
	 else
	    offset <- NewOffset
	    case MyByX==0 then skip else
	       self,moveTree(MomX MyX MyByX MyY Scale)
	    end
	 end
      end
      
   end

in

   LayoutNodes = c(choose:    !LayoutNode
		   blocked:   !LayoutLeaf
		   failed:    !LayoutLeaf
		   succeeded: !LayoutLeaf
		   sentinel:  !EmptyClass)
   
end
