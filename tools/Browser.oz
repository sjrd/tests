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
%%%  very main browser's module;
%%%
%%%
%%%
%%%

%% 
%\define    DEBUG_OPEN
\undef     DEBUG_OPEN

declare 
Browse
BrowserModule
in

%%
\ifdef DEBUG_OPEN
declare 

\else 
local
\endif

   %%
   %% 
   %%  Local initial constants;
\insert 'browser/constants.oz'
\insert 'browser/setParameter.oz'

   %%
   %%
   %%  Various local procedures and modules;
   %%

   %%
   %%  from 'core.oz';
   IntToAtom      %
   IsVar	  %  
   IsFdVar        % is a FD variable? 
   IsRecordCVar   % is an OFS?
   IsMetaVar      % is a Meta variable?
   WatchMetaVar   % 
   MetaGetDataAsAtom % get the constraint data of the meta variable
   MetaGetNameAsAtom % get the name of the constraint system of a meta var
   MetaGetStrength   % get some measure of the informartion of meta var
   HasLabel       % non-monotonic test;
   EQ             % pointers equality;
   TermSize       % size of a term's representation;
   GetsTouched    % fires iff its argument is ever touched;
   DeepFeed       % 'feed', but also from local computation spaces;
   ChunkArity     % yields chunk arity;
   ChunkWidth     % ... its width;
   AddrOf         %
   OnToplevel     %

   %%
   %%  'XResources.oz';
   X11ResourceCacheClass

   %%
   %% The persistent X11 resources cache (an object);
   X11ResourceCache

   %%
   %%  'tcl-interface.oz';
   BrowserWindowClass
   MessageWindowClass
   AboutDialogClass
   BufferDialog
   RepresentationDialog
   DisplayDialog
   LayoutDialog

   %%
   %%  'termsStore.oz';
   TermsStoreClass

   %%
   %%  'store.oz';
   StoreClass

   %%
   %%  'errors.oz';
   BrowserMessagesFocus
   BrowserMessagesNoFocus
   BrowserError
   BrowserWarning

   %%
   %%  'reflect.oz';
   IsDeepGuard
   Reflect

   %%
   %% browser's buffers & streams;
   BrowserStreamClass
   BrowserBufferClass

   %%
   %% local - for the default browser;
   BrowserStream
   BrowserCell
   DefaultBrowserClass
   DefaultBrowser
   InternalBrowse

   %%
   %% "Browser term" module;
   BrowserTerm

   %%
   %% control part;
   MyClosableObject
   ControlObject
   CompoundControlObject
   %%
   GetRootTermObject

   %%
   %% representation manager;
   GetTargetObj
   RepManagerObject
   CompoundRepManagerObject

   %%
   %% Term object classes;
   AtomTermObject
   IntTermObject
   FloatTermObject
   NameTermObject
   ProcedureTermObject
   CellTermObject
   PrimChunkTermObject
   DictionaryTermObject
   ArrayTermObject
   ThreadTermObject
   SpaceTermObject
   PrimObjectTermObject
   PrimClassTermObject
   ListTermObject
   FConsTermObject
   TupleTermObject
   HashTupleTermObject
   RecordTermObject
   CompChunkTermObject
   CompObjectTermObject
   CompClassTermObject
   VariableTermObject
   FDVariableTermObject
   MetaVariableTermObject
   UnknownTermObject

   %%
   %% special term objects;
   RootTermObject
   ShrunkenTermObject
   ReferenceTermObject

   %%
   %%  non-public attributes and features of a browser object;
   IsDefaultBrowser = {NewName}
   IsView = {NewName}

   %%
   %%  (local) sub-classes for BrowserClass - from 'browserObject.oz';
   WindowManagerClass
   BrowserManagerClass

   %%
   %% Browser's exception type;
   BEx = {NewName}

   %%
   BrowserClass

   %%
   %% Local stuff - browser's pool;
   DoEquate
   DoSetParameter
   DoGetParameter
   DoAddProcessAction
   DoSetProcessAction
   DoRemoveProcessAction
   DoCreateWindow

   %%
   %%  Undocumented;
   DoThrowBrowser

   %%
   %% local emulation of job...end;
   While
   JobEnd

   %%
in

   %%
   %% Various builtins to support meta-(oz)kernel browser's
   %% functionality;
\insert 'browser/core.oz'

   %% 
\insert 'browser/errors.oz'

   %%
\insert 'browser/XResources.oz'

   %%
   %% The persistent X11 resources cache (an object);
   X11ResourceCache = {New X11ResourceCacheClass init}

   %%
\insert 'browser/browserTerm.oz'

   %%
   %% "protected" methods, features and attributes - which may not be
   %% used within slave term object sub-classes;
   local
      %% unfortunately, we have to write assignments explicitly
      %% because this case is optimized;
      %%
      %% control object:
      ParentObj = {NewName}
      IsPrimitive = {NewName}
      %%
      Make = {NewName}
      Close = {NewName}
      FastClose = {NewName}
      CheckTerm = {NewName}
      SizeChanged = {NewName}
      GenRefName = {NewName}
      UpdateSize = {NewName}
      ButtonsHandler = {NewName}
      DButtonsHandler = {NewName}
      ShowInOPI = {NewName}
      Rebrowse = {NewName}
      Shrink = {NewName}
      Expand = {NewName}
      ExpandWidth = {NewName}
      Deref = {NewName}
      PutSubterm = {NewName}
      ChangeDepth = {NewName}
      SubtermChanged = {NewName}
      SetRefName = {NewName}

      %%
      %% representation manager;
      WidgetObj = {NewName}
      %%
      MakeRep = {NewName}
      CloseRep = {NewName}
      FastCloseRep = {NewName}
      BeginUpdateSubterm = {NewName}
      EndUpdateSubterm = {NewName}
      CheckLayoutReq = {NewName}
      BeginUpdate = {NewName}
      EndUpdate = {NewName}
      IsEnc = {NewName}
      GetRefName = {NewName}
      PutRefName = {NewName}
      PutEncRefName = {NewName}
      SetCursorAt = {NewName}
      Highlight = {NewName}
      CheckLayout = {NewName}
      SubtermSizeChanged = {NewName}
      GetObjG = {NewName}
      ApplySubtermObjs = {NewName}

      %%
      %% browser object - hidden methods, to be used by Browser's
      %% window manager and tcl/tk interface;
      [Reset SetBufferSize ChangeBufferSize SetSelected UnsetSelected
       Pause Continue SelExpand SelShrink Process SelZoom SelDeref About
       SetDepth SetWidth ChangeWidth SetDInc ChangeDInc SetWInc
       ChangeWInc UpdateSizes SetTWWidth ScrollTo] = {ForAll $ NewName}

      %%
   in

      %%
\insert 'browser/store.oz'

      %%
      %% Representation manager (for text widgets);
\insert 'browser/repManager.oz'

      %%
      %% Control object;
\insert 'browser/termsStore.oz'
\insert 'browser/controlObject.oz'

      %% 
      %%  Tcl/Tk interface; 
\insert 'browser/tcl-interface.oz'

      %%
\insert 'browser/bufs&streams.oz'

      %%
      %% Browser manager;
\insert 'browser/windowManager.oz'
\insert 'browser/managerObject.oz'

      %%
      %% Browser itself;
\insert 'browser/browserObject.oz'

      %%  Reflection (deep browsing;)
\insert 'browser/reflect.oz'
   end

   %% 
   %% Term objects - on the top of that;
\insert 'browser/termObject.oz'

   %%
   %%
   proc {While Cond Body}
      case {Cond} then {Body} {While Cond Body} else skip end
   end
   proc {JobEnd Proc}
      local MyThr JobThr in
	 MyThr = {Thread.this}

	 %%
	 thread
	    JobThr = {Thread.this}
	    {Proc}
	 end

	 %%
	 {While
	  fun {$} {Thread.state JobThr} == 'runnable' end
	  proc {$} {Thread.preempt MyThr} end}
	 %% now, the 'JobThr' is either terminated or blocked;
      end
   end

   %%
   %% DefaultBrowser: provides the passing of terms to be browsed;
   class DefaultBrowserClass from Object.base
      attr
	 browserObj: InitValue

      %%
      %%
      meth browse(Term)
	 local Browser HasCrashed CrashProc in 
	    %%
	    DefaultBrowserClass , createBrowser
	    Browser = @browserObj

	    %%
	    proc {CrashProc E T D}
	       {Show '*********************************************'}
	       {Show 'Exception occured in browser:'#E}
	       HasCrashed = unit
	    end

	    %%
	    try
	       %%  Actually, this might block the thread
	       %% (for instance, if the browser's buffer is full);
	       {Browser browse(Term)}
	    catch failure(debug:D) then {CrashProc failure unit D}
	    [] error(T debug:D) then {CrashProc error T D}
	    [] system(T debug:D) then {CrashProc system T D}
	    end

	    %%
	    %% Fairly to say, there are few things that can be caught
	    %% this way: a browser object has an internal
	    %% asynchronous worker which does the actual job ...
	    case {IsVar HasCrashed} then skip
	    else Pl Hl in
	       %%
 	       try
		  %%
		  %% this can block forever...
		  {JobEnd proc {$}
			     {Browser close} % try to give up gracefully;
			  end}

		  %%
		  %% ignore faults in the current thread;
 	       catch failure(debug:_) then skip
	       [] error(_ debug:_) then skip
	       [] system(_ debug:_) then skip
 	       end

	       %%
	       %% .. and just throw it away;
	       %% Note that the state must be freed already;
	       {self removeBrowser}
	    end
	 end
      end

      %%
      %%
      meth equate(Term)
	 case @browserObj == InitValue then skip
	 else {@browserObj equate(Term)}
	 end
      end

      %%
      %%
      meth setPar(Par Val)
	 case @browserObj == InitValue then skip
	 else {@browserObj setParameter(Par Val)}
	 end
      end

      %%
      %%
      meth getPar(Par ?Val)
	 case @browserObj == InitValue then skip
	 else {@browserObj getParameter(Par Val)}
	 end
      end

      %%
      %%
      meth addProcessAction(Action Label)
	 case @browserObj == InitValue then skip
	 else {@browserObj addProcessAction(action:Action label:Label)}
	 end
      end

      %%
      %%
      meth setProcessAction(Action)
	 case @browserObj == InitValue then skip
	 else {@browserObj setProcessAction(action:Action)}
	 end
      end

      %%
      %%
      meth setProcessAction(Action)
	 case @browserObj == InitValue then skip
	 else {@browserObj setProcessAction(action:Action)}
	 end
      end

      %%
      %%
      meth removeProcessAction(Action)
	 case @browserObj == InitValue then skip
	 else {@browserObj removeProcessAction(action:Action)}
	 end
      end

      %%
      %%
      meth removeBrowser
	 browserObj <- InitValue
      end

      %%
      %%
      meth createBrowser
	 case @browserObj == InitValue then Browser in 
	    Browser = {New BrowserClass
		       init(withMenus:        IWithMenus
			    IsDefaultBrowser: true)}

	    %%
	    browserObj <- Browser
	    {Browser createWindow}
	 else skip
	 end
      end

      %%
   end

   %%
   %%
   DefaultBrowser = {New DefaultBrowserClass noop}

   %%
   %% Browser's cell for deep browsing;
   BrowserCell = {NewCell BrowserStream}

   %%
   %% Internal browser - used for deep browsing;
   proc {InternalBrowse S}
      case S
      of Cmd|Tail then
         {DefaultBrowser Cmd}
	 {InternalBrowse Tail}
      else {BrowserError 'Browser channel is closed?'}
      end
   end

   %%
   %% always running; 
   thread
      {InternalBrowse BrowserStream}
   end 

   %%
   %% Pre-defined 'Browse' procedure - either through 'DeepFeed'
   %% (asynchronously, no flow control) or directly to
   %% 'DefaultBrowser';
   proc {Browse Term}
      case {IsDeepGuard} then {DeepFeed BrowserCell browse({Reflect Term})}
      else {DefaultBrowser browse(Term)}
      end
   end

   %%
   proc {DoEquate Term}
      case {IsDeepGuard} then
	 {Show 'BrowserModule.equate from a deep guard?'}
      else {DefaultBrowser equate(Term)}
      end
   end

   %%
   proc {DoSetParameter Par Val}
      case {IsDeepGuard} then
	 {Show 'BrowserModule.setParameter from a deep guard?'}
      else {DefaultBrowser setPar(Par Val)}
      end
   end

   %% 
   proc {DoGetParameter Par ?Val}
      case {IsDeepGuard} then
	 {Show 'BrowserModule.getParameter from a deep guard?'}
      else {DefaultBrowser getPar(Par Val)}
      end
   end

   %%
   proc {DoAddProcessAction Action Label}
      case {IsDeepGuard} then
	 {Show 'BrowserModule.addProcessAction from a deep guard?'}
      else {DefaultBrowser addProcessAction(Action Label)}
      end
   end

   %%
   proc {DoSetProcessAction Action}
      case {IsDeepGuard} then
	 {Show 'BrowserModule.setProcessAction from a deep guard?'}
      else {DefaultBrowser setProcessAction(Action)}
      end
   end

   %%
   proc {DoRemoveProcessAction Action}
      case {IsDeepGuard} then
	 {Show 'BrowserModule.removeProcessAction from a deep guard?'}
      else {DefaultBrowser removeProcessAction(Action)}
      end
   end

   %%
   proc {DoCreateWindow}
      case {IsDeepGuard} then
	 {Show 'BrowserModule.createWindow from a deep guard?'}
      else {DefaultBrowser createBrowser}
      end
   end

   %%
   proc {DoThrowBrowser}
      case {IsDeepGuard} then
	 {Show 'BrowserModule.createWindow from a deep guard?'}
      else {DefaultBrowser removeBrowser}
      end
   end

   %%
   %% 'Browse' module;
   BrowserModule = browse(equate:              DoEquate
			  setParameter:        DoSetParameter
			  getParameter:        DoGetParameter
			  addProcessAction:    DoAddProcessAction
			  setProcessAction:    DoSetProcessAction
			  removeProcessAction: DoRemoveProcessAction
			  createWindow:        DoCreateWindow
			  browserClass:        BrowserClass
			  throwBrowser:        DoThrowBrowser
			  browse:              Browse)

   %%
   %%
\ifndef DEBUG_OPEN 
end 
\endif 

\insert 'browser/undefs.oz'
