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

   \insert 'tk-nodes.oz'

   class FailedNode
      from CombineNodes.failed TkNodes.failed
      prop final
   end

   class BlockedNode
      from CombineNodes.blocked TkNodes.blocked
      prop final
   end

   class EntailedNode
      from CombineNodes.succeeded TkNodes.entailed
      prop final
   end

   class SuspendedNode
      from CombineNodes.succeeded TkNodes.suspended
      prop final
   end
   
   class ChooseNode
      from CombineNodes.choose TkNodes.choose
      prop final
   end

   class SentinelNode
      from CombineNodes.sentinel TkNodes.sentinel
      prop final
   end

in

   fun {MakeRoot Manager Query Order}
      Sentinel={New SentinelNode dirtyUp}
      Features=f(classes:   Classes
		 canvas:    Manager.canvas
		 order:     Order
		 status:    Manager.status
		 manager:   Manager)
      Classes =c(failed:    {Class.extendFeatures FailedNode Features nil}
		 blocked:   {Class.extendFeatures BlockedNode Features nil}
		 entailed:  {Class.extendFeatures EntailedNode Features nil}
		 suspended: {Class.extendFeatures SuspendedNode Features nil}
		 choose:    {Class.extendFeatures ChooseNode Features nil})
      S = {Space.new Query}
   in   
      case thread {Space.askVerbose S} end
      of failed then
	 {New Classes.failed init(Sentinel 1)}
      [] succeeded(SA) then
	 {New Classes.SA init(Sentinel 1 S persistent)}
      [] alternatives(MaxAlt) then
	 {New Classes.choose  init(Sentinel 1 false persistent S MaxAlt)}
      [] blocked(Ctrl) then
	 {New Classes.blocked init(Sentinel 1 Ctrl)}
      end
   end
			
end
