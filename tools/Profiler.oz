%%%
%%% Authors:
%%%   Benjamin Lorenz (lorenz@ps.uni-sb.de)
%%%
%%% Contributor:
%%%   Christian Schulte
%%%
%%% Copyright:
%%%   Benjamin Lorenz, 1997
%%%   Christian Schulte, 1998
%%%
%%% Last change:
%%%   $Date$ by $Author$
%%%   $Revision$
%%%
%%% This file is part of Mozart, an implementation
%%% of Oz 3
%%%    http://mozart.ps.uni-sb.de
%%%
%%% See the file "LICENSE" or
%%%    http://mozart.ps.uni-sb.de/LICENSE.html
%%% for information on usage and redistribution
%%% of this file, and for a DISCLAIMER OF ALL
%%% WARRANTIES.
%%%

functor $

import
   Profile.{mode reset getInfo}
      from 'x-oz://boot/Profile'

   Property.{get}
   
   OS.{time}
   
   Tk
   
   TkTools
   
   Emacs.{getOPI
	  condSend}

export
   'object':   Profiler

   'open':     OpenProfiler
   'close':    CloseProfiler
   
body
   \insert 'profiler/prof-config'
   \insert 'profiler/prof-prelude'

   \insert 'profiler/prof-menu'
   \insert 'profiler/prof-dialog'
   \insert 'profiler/prof-help'
   \insert 'profiler/prof-gui'
   \insert 'profiler/profiler'

   proc {OpenProfiler}
      {Profiler on}
   end
   
   proc {CloseProfiler}
      {Profiler off}
   end
   
end
