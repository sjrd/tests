%%%
%%% Authors:
%%%   Christian Schulte (schulte@dfki.de)
%%%
%%% Copyright:
%%%   Christian Schulte, 1997
%%%
%%% Last change:
%%%   $Date$ by $Author$
%%%   $Revision$
%%%
%%% This file is part of Mozart, an implementation
%%% of Oz 3
%%%    $MOZARTURL$
%%%
%%% See the file "LICENSE" or
%%%    $LICENSEURL$
%%% for information on usage and redistribution
%%% of this file, and for a DISCLAIMER OF ALL
%%% WARRANTIES.
%%%

local

   \insert layout-nodes.oz

   \insert search-nodes.oz

   \insert move-nodes.oz

   \insert stat-nodes.oz

   \insert hide-nodes.oz

   \insert action-nodes.oz

   class FailedNode
      from
	 LayoutNodes.failed
	 HideNodes.failed
	 MoveNodes.failed
	 SearchNodes.failed
	 StatNodes.failed
	 ActionNodes.failed
      feat
	 sentinel: false
	 kind:     failed
	 mom
	 
      meth init(Mom Depth)
	 self.mom = Mom
	 {self.status addFailed(Depth)}
      end
   end

   local
      fun {UnwrapBlocked UC}
	 case UC of blocked(C) then {UnwrapBlocked C} else UC end
      end
   in
      class BlockedNode
	 from
	    LayoutNodes.blocked
	    HideNodes.blocked
	    MoveNodes.blocked
	    SearchNodes.blocked
	    StatNodes.blocked
	    ActionNodes.blocked
	 feat
	    sentinel: false
	    kind:     blocked
	    mom
	    
	 meth init(Mom Depth Control)
	    Status         = self.status
	    UnwrapControl  = thread {UnwrapBlocked Control} end
	    KillFlag KillId
	 in
	    self.mom = Mom
	    {Status getKill(?KillFlag ?KillId)}
	    thread
	       {WaitOr UnwrapControl KillFlag}
	       case {IsDet UnwrapControl} then
		  {self.manager wake(self KillId)}
	       else skip
	       end
	    end
	    {Status addBlocked(Depth)}
	 end
      end
   end

   class SucceededNode
      from
	 LayoutNodes.succeeded
	 MoveNodes.succeeded
	 SearchNodes.succeeded
	 StatNodes.succeeded
	 HideNodes.succeeded
	 ActionNodes.succeeded
      feat
	 kind:     succeeded
	 sentinel: false
	 mom
      meth init(Mom Depth S AllocateCopy)
	 self.mom = Mom
	 copy <- case
		    case self.order==false then AllocateCopy
		    else persistent
		    end
		 of transient  then transient(S)
		 [] flushable  then flushable(S)
		 [] persistent then persistent(S)
		 else false
		 end
	 {self.status addSolution(Depth)}
      end
   end
   
   class ChooseNode
      from
	 HideNodes.choose
	 MoveNodes.choose
	 SearchNodes.choose
	 StatNodes.choose
	 LayoutNodes.choose
	 ActionNodes.choose
      feat
	 sentinel: false
	 kind:     choose
	 mom               % The mom of this node
      attr
	 isDirty:    true  % No layout computed
	 kids:       nil   % The list of nodes below
	 toDo:       nil   % What is to be done (nil if nothing)
	 isSolBelow: false % Is there a solution below
	 choices:    1     % unfinished choices below?
	 copy:       false
      
      meth init(Mom Depth PrevSol AllocateCopy S MaxAlt)
	 self.mom  = Mom
	 copy <- case AllocateCopy
		 of transient  then transient({Space.clone S})
		 [] flushable  then flushable({Space.clone S})
		 [] persistent then persistent({Space.clone S})
		 else false
		 end
	 toDo <- PrevSol # S # 1 # MaxAlt
	 {self.status addChoose(Depth)}
      end
      meth getKids($)
	 @kids
      end
   end

   class SentinelNode
      from
	 HideNodes.sentinel
	 MoveNodes.sentinel
	 SearchNodes.sentinel
      feat
	 sentinel: true
   end

in

   CombineNodes = m(sentinel:  SentinelNode
		    choose:    ChooseNode
		    succeeded: SucceededNode
		    failed:    FailedNode
		    blocked:   BlockedNode)
		    
end
