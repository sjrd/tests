%%%
%%% Author:
%%%   Leif Kornstaedt <kornstae@ps.uni-sb.de>
%%%
%%% Copyright:
%%%   Leif Kornstaedt, 1996-1998
%%%
%%% Last change:
%%%   $Date$ by $Author$
%%%   $Revision$
%%%
%%% This file is part of Mozart, an implementation of Oz 3:
%%%   http://mozart.ps.uni-sb.de
%%%
%%% See the file "LICENSE" or
%%%   http://mozart.ps.uni-sb.de/LICENSE.html
%%% for information on usage and redistribution
%%% of this file, and for a DISCLAIMER OF ALL
%%% WARRANTIES.
%%%

%%
%% Predefined Production Templates
%%

%-----------------------------------------------------------------------
% Parenthesization

prod ( A )
   A
end

prod $=( A )
   A($)
end

%-----------------------------------------------------------------------
% Option

prod [ A ]
   skip [] A
end

prod $=[ A ]
   skip => nil [] A($)
end

%-----------------------------------------------------------------------
% Mandatory Repetition

prod ( A )+
   syn X
      A [] X A
   end
in
   X
end
prod A+ ( A )+ end
prod { A }+ ( A )+ end

prod $=( A )+
   syn X(Hd Tl)
      A(Elem) => Hd = Elem|Tl
   [] X(!Hd Tl0) A(Elem) => Tl0 = Elem|Tl
   end
in
   X(Hd Tl) => Tl = nil Hd
end
prod $=A+ ( A($) )+ end
prod $={ A }+ ( A($) )+ end

%-----------------------------------------------------------------------
% Optional Repetition

prod ( A )*
   syn X
      skip [] X A
   end
in
   X
end
prod A* ( A )* end
prod { A } ( A )* end
prod { A }* ( A )* end

prod $=( A )*
   syn X(Hd Tl)
      skip => Hd = Tl
   [] X(!Hd Tl0) A(Elem) => Tl0 = Elem|Tl
   end
in
   X(Hd Tl) => Tl = nil Hd
end
prod $=A* ( A($) )* end
prod $={ A } ( A($) )* end
prod $={ A }* ( A($) )* end

%-----------------------------------------------------------------------
% Mandatory Separated Repetition

prod ( A // B )+
   syn X
      A [] X B A
   end
in
   X
end
prod ( A // B ) ( A // B )+ end
prod { A // B } ( A // B )+ end
prod { A // B }+ ( A // B )+ end

prod $=( A // B )+
   syn X(Hd Tl)
      A(Elem) => Hd = Elem|Tl
   [] X(!Hd Tl0) B A(Elem) => Tl0 = Elem|Tl
   end
in
   X(Hd Tl) => Tl = nil Hd
end
prod $=( A // B ) ( A($) // B )+ end
prod $={ A // B } ( A($) // B )+ end
prod $={ A // B }+ ( A($) // B )+ end

%-----------------------------------------------------------------------
% Optional Separated Repetition

prod ( A // B )*
   [ ( A // B )+ ]
end
prod { A // B }* ( A // B )* end

prod $=( A // B )*
   [ ( A($) // B )+ ]
end
prod $={ A // B }* ( A($) // B )* end
