%  Programming Systems Lab, University of Saarland,
%  Geb. 45, Postfach 15 11 50, D-66041 Saarbruecken.
%  Author: Konstantin Popov & Co. 
%  (i.e. all people who make proposals, advices and other rats at all:))
%  Last modified: $Date$ by $Author$
%  Version: $Revision$

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%
%%%  (Global) store for global parameters;
%%%
%%%
%%%
%%%

%%
%%  An object of this class is used for storing of all common
%% parameters for the Browser (such as actual sizes of windows, user
%% preferences and so on).

class StoreClass from UrObject
   %% 
   feat
      SDict

   %%
   meth init
      self.SDict = {Dictionary.new}
   end

   %% 
   %% Add (or replace) some value to store; 
   %% 
   meth store(What Value)
      %%
      {Dictionary.put self.SDict What Value}
   end 

   %% 
   %% Extract some value from store; 
   %% 
   meth read(What $)
\ifdef DEBUG_BO
      local DefValue in
	 DefValue = {NewName}

	 %%
	 case {Dictionary.condGet self.SDict What DefValue}
	 of !DefValue then
	    {BrowserError 'Attempt to read undefined parameter in store'}
	 else skip 
	 end
      end
\endif

      %%
      {Dictionary.get self.SDict What}
   end 

   %%
end 

