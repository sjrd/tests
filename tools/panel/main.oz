%%%  Programming Systems Lab, DFKI Saarbruecken,
%%%  Stuhlsatzenhausweg 3, D-66123 Saarbruecken, Phone (+49) 681 302-5312
%%%  Author: Christian Schulte
%%%  Email: schulte@dfki.uni-sb.de
%%%  Last modified: $Date$ by $Author$
%%%  Version: $Revision$

local

   PanelTopClosed = {NewName}

   \insert configure.oz

   \insert discrete-scale.oz
   
   \insert runtime-bar.oz

   \insert load.oz

   \insert dialogs.oz
   
   \insert make-notes.oz
   
   \insert top.oz

in

   class PanelManager
      from UrObject

      attr ThisPanelTop: unit
      
      meth open
	 case @ThisPanelTop==unit then
	    ThisPanelTop <- thread
			       {New PanelTop init(manager:self)}
			    end
	 else skip
	 end
      end

      meth !PanelTopClosed
	 ThisPanelTop <- unit
      end

      meth close
	 UrObject,close
	 case @ThisPanelTop of unit then skip elseof T then
	    thread {T close} end
	 end
      end
      
   end

end
