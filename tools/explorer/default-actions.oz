%%%
%%% Authors:
%%%   Christian Schulte <schulte@ps.uni-sb.de>
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
%%%    http://www.mozart-oz.org
%%%
%%% See the file "LICENSE" or
%%%    http://www.mozart-oz.org/LICENSE.html
%%% for information on usage and redistribution
%%% of this file, and for a DISCLAIMER OF ALL
%%% WARRANTIES.
%%%

ExplorerClass,add(information proc {$ N X} {System.show N#X} end
		  label: 'Show')

ExplorerClass,add(information proc {$ N X} {Browser.browse N#X} end
		  label: 'Browse')

ExplorerClass,add(compare proc {$ N1 X1 N2 X2} {System.show N1#N2#X1#X2} end
		  label: 'Show')

ExplorerClass,add(compare proc {$ N1 X1 N2 X2} {Browser.browse N1#N2#X1#X2} end
		  label: 'Browse')

ExplorerClass,add(statistics proc {$ N S}
				{System.show N#{Record.subtract S shape}}
			     end
		  label: 'Show')

ExplorerClass,add(statistics proc {$ N S}
				{Browser.browse N#{Record.subtract S shape}}
			     end
		  label: 'Browse')
