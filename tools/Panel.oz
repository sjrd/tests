%%%
%%% Authors:
%%%   Author's name (Author's email address)
%%%
%%% Contributors:
%%%   optional, Contributor's name (Contributor's email address)
%%%
%%% Copyright:
%%%   Organization or Person (Year(s))
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
%%%  Programming Systems Lab, DFKI Saarbruecken,
%%%  Stuhlsatzenhausweg 3, D-66123 Saarbruecken, Phone (+49) 681 302-5312
%%%  Author: Christian Schulte
%%%  Email: schulte@dfki.uni-sb.de
%%%  Last modified: $Date$ by $Author$
%%%  Version: $Revision$

declare

fun
\ifdef NEWCOMPILER
   instantiate
\endif
   {NewPanel IMPORT}
   \insert 'SP.env'
       = IMPORT.'SP'
   \insert 'OP.env'
       = IMPORT.'OP'
   \insert 'WP.env'
       = IMPORT.'WP'
in
   local
      \insert 'panel/main.oz'
      Panel = {New PanelClass init}
   in
      \insert 'Panel.env'
   end
end
