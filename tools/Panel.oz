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
%%%    http://mozart.ps.uni-sb.de
%%%
%%% See the file "LICENSE" or
%%%    http://mozart.ps.uni-sb.de/LICENSE.html
%%% for information on usage and redistribution
%%% of this file, and for a DISCLAIMER OF ALL
%%% WARRANTIES.
%%%

functor $ prop once

import
   Property.{get
	     put}
   
   System.{gcDo
	   valueToVirtualString
	   exit}

   Error.{formatGeneric
	  format
	  dispatch}
   
   ErrorRegistry.{put}

   Open.{file}

   Tk
   
   TkTools.{error
	    dialog
	    note
	    notebook
	    scale
	    textframe
	    numberentry
	    menubar}
   
export
   'class': PanelClass
   'panel': Panel

   'Panel': Panel

body
   \insert 'panel/errors.oz'
   \insert 'panel/main.oz'

   Panel = {New PanelClass init}
end
