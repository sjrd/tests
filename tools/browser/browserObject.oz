%  Programming Systems Lab, DFKI Saarbruecken,
%  Stuhlsatzenhausweg 3, D-66123 Saarbruecken, Phone (+49) 681 302-5337
%  Author: Konstantin Popov & Co. 
%  (i.e. all people who make proposals, advices and other rats at all:))
%  Last modified: $Date$ by $Author$
%  Version: $Revision$

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%
%%%
%%%  BrowserClass; 
%%%
%%%
%%%
%%%

class WindowPrimary from UrObject
   %% 
   %%  additionally to these attributes, 'store' and 'current' must be defined; 
   %% 
   attr 
      window: InitValue
      buttons: InitValue         % procedures; 
   %% menuButtons: InitValue     % procedures; 
   %% menus: InitValue           % procedures; 
      entries: InitValue         % procedures;
      tclVars: InitValue         % tcl variables in check&radio entries; 
   %%
   %% 
   %% 
   meth createWindow(?Sync)
\ifdef DEBUG_BO
      {Show 'WindowPrimary::createWindow is applied'}
\endif 
      case @window == InitValue then 
	 local Window AreMenus AreButtons in 
	    %%
	    %% 
	    Window = {New ProtoBrowserWindow 
		      init(window: {@store read(StoreOrigWindow $)}
			   screen: {@store read(StoreScreen $)}
			   browserObj: self
			   store: @store
			   standAlone: self.standAlone)}
	    %%
	    window <- Window
	    %%
	    %%
	    AreMenus = {@store read(StoreAreMenus $)}
	    case AreMenus then <<CreateMenus(_)>>
	    else true 
	    end 
	    %%
	    %%
	    AreButtons = {@store read(StoreAreButtons $)}
	    case AreButtons then <<CreateButtons(_)>>
	    else true 
	    end 
	    %%
	    %% 
	    {@window setMinSize}
	    <<sync(Sync)>>
	    %%
	    %%
	    {BrowserMessagesInit Window}
	 end 
      else Sync = ok
      end 
   end 

   %% 
   %% 
   meth !CreateButtons(Sync)
\ifdef DEBUG_BO
      {Show 'WindowPrimary::CreateButtons is applied'}
\endif 
      local
	 RebrowseButtonProc RedrawButtonProc ClearButtonProc
	 ClearButtonProcTmp DerefButtonProc ExpandButtonProc
	 ShrinkButtonProc ShowButtonProc ZoomButtonProc
	 UnzoomButtonProc TopButtonProc FirstButtonProc
	 FirstButtonProcTmp LastButtonProc LastButtonProcTmp
	 PreviousButtonProc PreviousButtonProcTmp NextButtonProc
	 NextButtonProcTmp AllButtonProc AllButtonProcTmp
      in

	 % 
	 {@window 
	  [createButtonsFrame
	   pushButton("rebrowse" proc {$} {self rebrowse} end RebrowseButtonProc)
	   pushButton("redraw" proc {$} {self redraw} end RedrawButtonProc)
	   pushButton("clear" proc {$} {self undraw} end ClearButtonProcTmp)
	   pushButton("expand" proc {$} {self SelExpand} end ExpandButtonProc)
	   pushButton("shrink" proc {$} {self SelShrink} end ShrinkButtonProc)
	   pushButton("show" proc {$} {self SelShow} end ShowButtonProc)
	   pushButton("zoom" proc {$} {self Zoom} end ZoomButtonProc)
	   pushButton("unzoom" proc {$} {self Unzoom} end UnzoomButtonProc)
	   pushButton("top" proc {$} {self Top} end TopButtonProc)
	   pushButton("deref" proc {$} {self Deref} end DerefButtonProc)
	   pushButton("first" proc {$} {self first} end FirstButtonProcTmp)
	   pushButton("last" proc {$} {self last} end LastButtonProcTmp)
	   pushButton("previous" proc {$} {self previous} end PreviousButtonProcTmp)
	   pushButton("next" proc {$} {self next} end NextButtonProcTmp)
	   pushButton("all" proc {$} {self all} end AllButtonProcTmp)
	   exposeButtonsFrame
	   sync(Sync)]}
	 %%
	 %%
	 case self.IsView then
	    ClearButtonProc = proc {$ _ _} true end
	    {ClearButtonProcTmp state disabled}
	 else
	    ClearButtonProc = ClearButtonProcTmp
	 end
	 %%
	 %% 
	 case @current == InitValue then 
	    {RebrowseButtonProc state disabled}
	    {RedrawButtonProc state disabled}
	    {ClearButtonProc state disabled}
	 else 
	    {RebrowseButtonProc state normal}
	    {RedrawButtonProc state normal}
	    {ClearButtonProc state normal}
	 end 

	 % expand/shrink/show/zoom/deref disabled simply; 
	 {ExpandButtonProc state disabled}
	 {ShrinkButtonProc state disabled}
	 {ShowButtonProc state disabled}
	 {ZoomButtonProc state disabled}
	 {DerefButtonProc state disabled}
	 %%
	 %% 
	 case self.IsView then
	    local DummyProc in 
	       DummyProc = proc {$ _ _} true end
	       %%
	       FirstButtonProc = DummyProc
	       LastButtonProc = DummyProc
	       NextButtonProc = DummyProc
	       PreviousButtonProc = DummyProc
	       AllButtonProc = DummyProc
	       %%
	       {FirstButtonProcTmp state disabled}
	       {LastButtonProcTmp state disabled}
	       {NextButtonProcTmp state disabled}
	       {PreviousButtonProcTmp state disabled}
	       {AllButtonProcTmp state disabled}
	    end
	 else
	    FirstButtonProc = FirstButtonProcTmp
	    LastButtonProc = LastButtonProcTmp
	    NextButtonProc = NextButtonProcTmp
	    PreviousButtonProc = PreviousButtonProcTmp
	    AllButtonProc = AllButtonProcTmp
	 end
	 %%
	 case @current == InitValue then
	    {FirstButtonProc state disabled}
	    {LastButtonProc state disabled}
	    {NextButtonProc state disabled}
	    {PreviousButtonProc state disabled}
	    {AllButtonProc state disabled}
	    {UnzoomButtonProc state disabled}
	    {TopButtonProc state disabled}
	 else 
	    %
	    case @zoomStack == nil then 
	       {UnzoomButtonProc state disabled}
	       {TopButtonProc state disabled}
	    else
	       {UnzoomButtonProc state normal}
	       {TopButtonProc state normal}
	    end 

	    % 
	    case @showAll then
	       {AllButtonProc state disabled}
	       {FirstButtonProc state normal}
	       {LastButtonProc state normal}
	       {PreviousButtonProc state disabled}
	       {NextButtonProc state disabled}
	    else
	       {AllButtonProc state normal}

	       % 
	       case @forward == nil then
		  {NextButtonProc state disabled}
		  {LastButtonProc state disabled}
	       else
		  {NextButtonProc state normal}
		  {LastButtonProc state normal}
	       end 

	       %
	       case @backward == nil then
		  {PreviousButtonProc state disabled}
		  {FirstButtonProc state disabled}
	       else
		  {PreviousButtonProc state normal}
		  {FirstButtonProc state normal}
	       end 
	    end 
	 end 

	 % 
	 buttons <- buttons(rebrowse: RebrowseButtonProc
			    redraw: RedrawButtonProc
			    clear: ClearButtonProc
			    expand: ExpandButtonProc
			    shrink: ShrinkButtonProc
			    show: ShowButtonProc
			    zoom: ZoomButtonProc
			    unzoom: UnzoomButtonProc
			    top: TopButtonProc
			    deref: DerefButtonProc
			    first: FirstButtonProc
			    last: LastButtonProc
			    previous: PreviousButtonProc
			    next: NextButtonProc
			    all: AllButtonProc)

	 % 
	 case {IsValue Sync} then 
	    <<nil>>
	 end
      end 
   end 

   %% 
   %% 
   meth !CreateMenus(Sync)
\ifdef DEBUG_BO
      {Show 'WindowPrimary::CreateMenus is applied'}
\endif 
      local 
	 Store Window CycleCheckVar OnlyCyclesVar FillStyleVar
	 ArityTypeVar AreVSsVar SmallNamesVar AreInactiveVar
	 FlatListsVar ScrollingVar HeavyVarsVar FontVar ViewMB
	 ViewMenu FontMenu FontMenuProc FontMiscMenu FontMiscMenuProc
	 FontCourMenu FontCourMenuProc NavigateMB NavigateMenu
	 DepthMenu WidthMenu NodeNumberMenu DepthMenuProc
	 WidthMenuProc NodeNumberMenuProc IncDepthMenu IncWidthMenu
	 IncDepthMenuProc IncWidthMenuProc BufferMB BufferMenu
	 HistoryLengthMenu HLMProc BrowserMB BrowserMenu
	 CloseEntryProc CreateNewViewEntryProc RebrowseEntryProc
	 RedrawEntryProc ClearEntryProc ClearHistoryEntryProc
	 ClearHistoryEntryProcTmp ClearEntryProcTmp ExpandEntryProc
	 ShrinkEntryProc ShowEntryProc ZoomEntryProc ZoomEntryProc
	 UnzoomEntryProc TopEntryProc DerefEntryProc FirstEntryProc
	 FirstEntryProcTmp LastEntryProc LastEntryProcTmp
	 PreviousEntryProc PreviousEntryProcTmp NextEntryProc
	 NextEntryProcTmp AllEntryProc AllEntryProcTmp

	\ifdef FEGRAMED
	 FE_Menue FE_ShowSelectedProc
	 FE_Var FE_SubMenuProc
	 FE_MB FE_Menu
	\endif
	 
      in 
	 %% 
	 Store = @store
	 Window = @window
	 %%
	 %%  menus; 
	 {Window
	  [createMenusFrame
	   %%
	   %% 'Browser' menu; 
	   pushMenuButton("Browser" BrowserMB _)
	   defineMenu(BrowserMB True BrowserMenu)
	   addCommandEntry(BrowserMenu " Stop "#"ctl-s"
			   proc {$} {Store store(StoreNodeNumber 0)} end
			   _)
	   addSeparatorEntry(BrowserMenu)
	   addCommandEntry(BrowserMenu " Redraw "#"ctl-l"
			   proc {$} {self redraw} end 
			   RedrawEntryProc)
	   addCommandEntry(BrowserMenu " Rebrowse "#"ctl-b"
			   proc {$} {self rebrowse} end 
			   RebrowseEntryProc)
	   addCommandEntry(BrowserMenu " Show in OPI "
			   proc {$} {self SelShow} end 
			     ShowEntryProc)
	   addSeparatorEntry(BrowserMenu)
	   addCommandEntry(BrowserMenu " Help "#"ctl-h"
			   proc {$} {self Help} end
			   _)
	   addCommandEntry(BrowserMenu " Show/hide menus "#"ctl-alt-m"
			   proc {$} {self toggleMenus} end
			   _)
	   addCommandEntry(BrowserMenu " Show/hide buttons "#"ctl-alt-b"
			   proc {$} {self toggleButtons} end
			   _)
	   addCommandEntry(BrowserMenu " New view "#"ctl-n"
			   proc {$} {self createNewView} end
			   CreateNewViewEntryProc)
	   addSeparatorEntry(BrowserMenu)
	   addCommandEntry(BrowserMenu " Close "#"ctl-x"
			   proc {$} {self close} end 
			   CloseEntryProc)
	   %%
	   %% 'Buffer' menu; 
	   pushMenuButton("Buffer" BufferMB _)
	   defineMenu(BufferMB
		      proc {$}
			 local HistoryLength in 
			    HistoryLength = {Store read(StoreHistoryLength $)}

			    %
			    case HistoryLength == DInfinite then
			       {HLMProc label {List.flatten [" Size (infinite) "]}}
			    else 
			       {HLMProc label 
				{List.flatten
				 [" Size (" {Int.toString HistoryLength} ") "]}}
			    end 
			 end 
		      end 
		      BufferMenu)
	   %% createTkVar(case @isActive then TclTrue else TclFalse end 
	   %% proc {$ Val}
	   %%    local TrueValue in
	   %% 	 case {String.toAtom Val} == TclFalse then TrueValue = False
	   %% 	 else TrueValue = True
	   %% 	 end
	   %%          
	   %% 	 % 
	   %% 	 {self SetActiveState(TrueValue)}
	   %%    end
	   %%  end
	   %% 	       IsActiveVar)
	   %% addCheckEntry(BufferMenu " Follow " IsActiveVar TclTrue TclFalse _)
	   %% addSeparatorEntry(BufferMenu)
	   addCommandEntry(BufferMenu " Clear history "
			   proc {$} {self ClearHistory} end
			   ClearHistoryEntryProcTmp)
	   addCommandEntry(BufferMenu " Clear current "#"ctl-u"
			   proc {$} {self undraw} end 
			   ClearEntryProcTmp)
	   addSeparatorEntry(BufferMenu)
	   defineSubMenu(BufferMenu True HistoryLengthMenu)
	   addMenuEntry(BufferMenu " Size " HistoryLengthMenu HLMProc)
	   addCommandEntry(HistoryLengthMenu " 0 " 
			   proc {$} 
			      {Store store(StoreHistoryLength 0)}
			      {self CheckHistory}
			   end 
			   _)
	   addCommandEntry(HistoryLengthMenu " 5 "
			   proc {$}
			      {Store store(StoreHistoryLength 5)}
			      {self CheckHistory}
			   end 
			   _)
	   addCommandEntry(HistoryLengthMenu " 25 "
			   proc {$}
			      {Store store(StoreHistoryLength 25)}
			      {self CheckHistory}
			   end 
			   _)
	   addCommandEntry(HistoryLengthMenu " 50 "
			   proc {$}
			      {Store store(StoreHistoryLength 50)}
			      {self CheckHistory}
			   end 
			   _)
	   addCommandEntry(HistoryLengthMenu " infinite "
			   proc {$}
			      {Store store(StoreHistoryLength DInfinite)}
			      {self CheckHistory}
			   end 
			   _)
	   addCommandEntry(HistoryLengthMenu " + 1 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreHistoryLength $)}
				 {Store store(StoreHistoryLength (AD + 1))}
				 {self CheckHistory}
			      end 
			   end 
			   _)
	   addCommandEntry(HistoryLengthMenu " + 5 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreHistoryLength $)}
				 {Store store(StoreHistoryLength (AD + 5))}
				 {self CheckHistory}
			      end 
			   end 
			   _)
	   addCommandEntry(HistoryLengthMenu " + 25 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreHistoryLength $)}
				 {Store store(StoreHistoryLength (AD + 25))}
				 {self CheckHistory}
			      end 
			   end 
			   _)
	   addCommandEntry(HistoryLengthMenu " - 1 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreHistoryLength $)}
				 {Store store(StoreHistoryLength {Max 0 (AD - 1)})}
				 {self CheckHistory}
			      end 
			   end 
			   _)
	   addCommandEntry(HistoryLengthMenu " - 5 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreHistoryLength $)}
				 {Store store(StoreHistoryLength {Max 0 (AD - 5)})}
				 {self CheckHistory}
			      end 
			   end 
			   _)
	   addCommandEntry(HistoryLengthMenu " - 25 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreHistoryLength $)}
				 {Store store(StoreHistoryLength {Max 0 (AD - 25)})}
				 {self CheckHistory}
			      end 
			   end 
			   _)
	   %%
	   %% 'Navigate' menu;
	   pushMenuButton("Navigate" NavigateMB _)
	   defineMenu(NavigateMB True NavigateMenu)
	   addCommandEntry(NavigateMenu " All "#"   a"
			   proc {$} {self all} end 
			   AllEntryProcTmp)
	   addCommandEntry(NavigateMenu " Last "#"   l"
			   proc {$} {self last} end 
			   LastEntryProcTmp)
	   addCommandEntry(NavigateMenu " First "#"   f"
			   proc {$} {self first} end 
			   FirstEntryProcTmp)
	   addCommandEntry(NavigateMenu " Previous "#"   p"
			   proc {$} {self previous} end 
			   PreviousEntryProcTmp)
	   addCommandEntry(NavigateMenu " Next "#"   n"
			   proc {$} {self next} end 
			   NextEntryProcTmp)
	   addSeparatorEntry(NavigateMenu)
	   addCommandEntry(NavigateMenu " Zoom "#"   z"
			   proc {$} {self Zoom} end 
			   ZoomEntryProc)
	   addCommandEntry(NavigateMenu " Unzoom "#"   u"
			   proc {$} {self Unzoom} end 
			   UnzoomEntryProc)
	   addCommandEntry(NavigateMenu " Top "#"   t"
			   proc {$} {self Top} end 
			   TopEntryProc)
	   addSeparatorEntry(NavigateMenu)
	   addCommandEntry(NavigateMenu " Deref "#"   d"
			   proc {$} {self Deref} end 
			   DerefEntryProc)
	   addCommandEntry(NavigateMenu " Expand "#"   e"
			   proc {$} {self SelExpand} end 
			   ExpandEntryProc)
	   addCommandEntry(NavigateMenu " Shrink "#"   s"
			   proc {$} {self SelShrink} end 
			   ShrinkEntryProc)
	   %%
	   %%  'View' menu;
	   pushMenuButton("View" ViewMB _)
	   defineMenu(ViewMB 
		      proc {$}
			 local Depth Width NodeNumber DepthInc WidthInc in 
			    {Store [read(StoreDepth Depth)
				    read(StoreWidth Width)
				    read(StoreNodeNumber NodeNumber)
				    read(StoreDepthInc DepthInc)
				    read(StoreWidthInc WidthInc)]}

			    % 
			    {DepthMenuProc label 
			     {List.flatten [" Depth (" 
						     case Depth == DInfinite
						     then "infinite" 
						     else {Int.toString Depth} 
						     end 
						     ") "]}}
			    % 
			    {WidthMenuProc label 
			     {List.flatten [" Width (" 
						     case Width == DInfinite
						     then "infinite"
						     else {Int.toString Width}
						     end 
						     ") "]}}
			    % 
			    {NodeNumberMenuProc label 
			     {List.flatten [" Nodes (" 
						     case NodeNumber == DInfinite
						     then "infinite" 
						     else {Int.toString NodeNumber} 
						     end 
						     ") "]}}
			    % 
			    {IncDepthMenuProc label 
			     {List.flatten
			      [" Depth inc (" {Int.toString DepthInc} ") "]}}
			    % 
			    {IncWidthMenuProc label 
			     {List.flatten
			      [" Width inc (" {Int.toString WidthInc} ") "]}}
			 end 
		      end
		      ViewMenu)
	   createTkVar(case {Store read(StoreScrolling $)} then TclTrue
		       else TclFalse
		       end 
	   proc {$ Val}
	      local TrueValue in
		 case {String.toAtom Val} == TclFalse then TrueValue = False
		 else TrueValue = True
		 end

		 % 
		 {Store store(StoreScrolling TrueValue)}
	      end
	   end
		       ScrollingVar)
	   addCheckEntry(ViewMenu " Scrolling " ScrollingVar TclTrue TclFalse _)
	   addSeparatorEntry(ViewMenu)
	   createTkVar(case {Store read(StoreCheckStyle $)} then TclTrue
		       else TclFalse
		       end
	   proc {$ Val} 
	      local TrueValue in
		 case {String.toAtom Val} == TclFalse then TrueValue = False
		 else TrueValue = True
		 end

		 % 
		 {Store store(StoreCheckStyle TrueValue)}
		 case TrueValue then
		    % {Store store(StoreOnlyCycles False)}
		    {OnlyCyclesVar tkSet(TclFalse)}
		 else true
		 end 
	      end
	   end 
		       CycleCheckVar)
	   addCheckEntry(ViewMenu " Coreferences " CycleCheckVar TclTrue TclFalse _)
	   createTkVar(case {Store read(StoreOnlyCycles $)} then TclTrue
		       else TclFalse
		       end
	   proc {$ Val}
	      local TrueValue in
		 case {String.toAtom Val} == TclFalse then TrueValue = False
		 else TrueValue = True
		 end

		 % 
		 {Store store(StoreOnlyCycles TrueValue)}
		 case TrueValue then
		    % {Store store(StoreCheckStyle False)}
		    {CycleCheckVar tkSet(TclFalse)}
		 else true
		 end
	      end
	   end 
		       OnlyCyclesVar)
	   addCheckEntry(ViewMenu " Cycles " OnlyCyclesVar TclTrue TclFalse _)
	   createTkVar(case {Store read(StoreArityType $)} == TrueArity
		       then TclTrueArity
		       else TclAtomicArity
		       end
	   proc {$ Val} 
	      local TrueValue in
		 case {String.toAtom Val} == TclTrueArity then
		    TrueValue = TrueArity
		 else
		    TrueValue = AtomicArity
		 end

		 % 
		 {Store store(StoreArityType TrueValue)}
	      end
	   end 
		       ArityTypeVar)
	   addCheckEntry(ViewMenu " Private fields " ArityTypeVar
			 TclTrueArity TclAtomicArity _)
	   createTkVar(case {Store read(StoreAreVSs $)} then TclTrue
		       else TclFalse
		       end
	   proc {$ Val}
	      local TrueValue in
		 case {String.toAtom Val} == TclFalse then TrueValue = False
		 else TrueValue = True
		 end

		 % 
		 {Store store(StoreAreVSs TrueValue)}
	      end
	   end
		       AreVSsVar)
	   addCheckEntry(ViewMenu " Virtual strings " AreVSsVar TclTrue TclFalse _)
	   addSeparatorEntry(ViewMenu)
	   createTkVar(case {Store read(StoreHeavyVars $)} then TclTrue
		       else TclFalse
		       end
	   proc {$ Val}
	      local TrueValue in
		 case {String.toAtom Val} == TclFalse then TrueValue = False
		 else TrueValue = True
		 end

		 % 
		 {Store store(StoreHeavyVars TrueValue)}
	      end
	   end 
		       HeavyVarsVar)
	   addCheckEntry(ViewMenu " Variables aligned " HeavyVarsVar
			 TclTrue TclFalse _)
	   createTkVar(case {Store read(StoreFillStyle $)} == Filled then TclFilled
		       else TclExpanded
		       end
	   proc {$ Val} 
	      local TrueValue in
		 case {String.toAtom Val} == TclFilled then
		    TrueValue = Filled
		 else
		    TrueValue = Expanded
		 end

		 % 
		 {Store store(StoreFillStyle TrueValue)}
	      end
	   end 
		       FillStyleVar)
	   addCheckEntry(ViewMenu " Record fields aligned "
			 FillStyleVar TclExpanded TclFilled _)
	   createTkVar(case {Store read(StoreFlatLists $)} then TclTrue
		       else TclFalse
		       end
	   proc {$ Val}
	      local TrueValue in
		 case {String.toAtom Val} == TclFalse then TrueValue = False
		 else TrueValue = True
		 end

		 % 
		 {Store store(StoreFlatLists TrueValue)}
	      end
	   end
		       FlatListsVar)
	   addCheckEntry(ViewMenu " Lists flat " FlatListsVar TclTrue TclFalse _)
	   createTkVar(case {Store read(StoreSmallNames $)} then TclTrue
		       else TclFalse
		       end
	   proc {$ Val}
	      local TrueValue in
		 case {String.toAtom Val} == TclFalse then TrueValue = False
		 else TrueValue = True
		 end

		 % 
		 {Store store(StoreSmallNames TrueValue)}
	      end
	   end
		       SmallNamesVar)
	   addCheckEntry(ViewMenu " Names & Procs short " SmallNamesVar
			 TclTrue TclFalse _)
	   createTkVar(case {Store read(StoreAreInactive $)} then TclTrue
		       else TclFalse
		       end
	   proc {$ Val}
	      local TrueValue in
		 case {String.toAtom Val} == TclFalse then TrueValue = False
		 else TrueValue = True
		 end

		 % 
		 {Store store(StoreAreInactive TrueValue)}
	      end
	   end
		       AreInactiveVar)
	   addCheckEntry(ViewMenu " Primitive terms active " AreInactiveVar
			 TclFalse TclTrue _)
	   addSeparatorEntry(ViewMenu)
           defineSubMenu(ViewMenu True DepthMenu)
           defineSubMenu(ViewMenu True WidthMenu)
	   defineSubMenu(ViewMenu True NodeNumberMenu)
           defineSubMenu(ViewMenu True IncDepthMenu)
           defineSubMenu(ViewMenu True IncWidthMenu)
	   addMenuEntry(ViewMenu " Depth " DepthMenu DepthMenuProc)
	   addMenuEntry(ViewMenu " Width " WidthMenu WidthMenuProc)
	   addMenuEntry(ViewMenu " Nodes " NodeNumberMenu NodeNumberMenuProc)
	   addMenuEntry(ViewMenu " Depth inc " IncDepthMenu IncDepthMenuProc)
	   addMenuEntry(ViewMenu " Width inc " IncWidthMenu IncWidthMenuProc)
	   addCommandEntry(DepthMenu " 1 " 
			   proc {$}
			      {Store store(StoreDepth 1)}
			      {self UpdateSizes} 
			   end 
			   _)
	   addCommandEntry(DepthMenu " 2 "
			   proc {$}
			      {Store store(StoreDepth 2)}
			      {self UpdateSizes}
			   end 
			   _)
	   addCommandEntry(DepthMenu " 5 "
			   proc {$}
			      {Store store(StoreDepth 5)}
			      {self UpdateSizes}
			   end 
			   _)
	   addCommandEntry(DepthMenu " 10 "
			   proc {$}
			      {Store store(StoreDepth 10)}
			      {self UpdateSizes}
			   end 
			   _)
	   addCommandEntry(DepthMenu " 25 "
			   proc {$}
			      {Store store(StoreDepth 25)}
			      {self UpdateSizes}
			   end 
			   _)
	   addCommandEntry(DepthMenu " infinite "
			   proc {$}
			      {Store store(StoreDepth DInfinite)}
			      {self UpdateSizes}
			   end 
			   _)
	   addCommandEntry(DepthMenu " + 1 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreDepth $)}
				 {Store store(StoreDepth (AD + 1))}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(DepthMenu " + 2 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreDepth $)}
				 {Store store(StoreDepth (AD + 2))}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(DepthMenu " + 5 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreDepth $)}
				 {Store store(StoreDepth (AD + 5))}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(DepthMenu " - 1 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreDepth $)}
				 {Store store(StoreDepth {Max 1 (AD - 1)})}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(DepthMenu " - 2 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreDepth $)}
				 {Store store(StoreDepth {Max 1 (AD - 2)})}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(DepthMenu " - 5 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreDepth $)}
				 {Store store(StoreDepth {Max 1 (AD - 5)})}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(WidthMenu " 2 "
			   proc {$}
			      {Store store(StoreWidth 2)}
			      {self UpdateSizes}
			   end 
			   _)
	   addCommandEntry(WidthMenu " 5 "
			   proc {$}
			      {Store store(StoreWidth 5)}
			      {self UpdateSizes}
			   end 
			   _)
	   addCommandEntry(WidthMenu " 10 "
			   proc {$}
			      {Store store(StoreWidth 10)}
			      {self UpdateSizes}
			   end 
			   _)
	   addCommandEntry(WidthMenu " 25 "
			   proc {$}
			      {Store store(StoreWidth 25)}
			      {self UpdateSizes}
			   end 
			   _)
	   addCommandEntry(WidthMenu " 50 "
			   proc {$}
			      {Store store(StoreWidth 50)}
			      {self UpdateSizes}
			   end 
			   _)
	   addCommandEntry(WidthMenu " infinite "
			   proc {$}
			      {Store store(StoreWidth DInfinite)}
			      {self UpdateSizes}
			   end 
			   _)
	   addCommandEntry(WidthMenu " + 1 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidth $)}
				 {Store store(StoreWidth (AD + 1))}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(WidthMenu " + 2 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidth $)}
				 {Store store(StoreWidth (AD + 2))}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(WidthMenu " + 5 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidth $)}
				 {Store store(StoreWidth (AD + 5))}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(WidthMenu " + 10 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidth $)}
				 {Store store(StoreWidth (AD + 10))}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(WidthMenu " + 25 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidth $)}
				 {Store store(StoreWidth (AD + 25))}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(WidthMenu " - 1 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidth $)}
				 {Store store(StoreWidth {Max 2 (AD - 1)})}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(WidthMenu " - 2 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidth $)}
				 {Store store(StoreWidth {Max 2 (AD - 2)})}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(WidthMenu " - 5 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidth $)}
				 {Store store(StoreWidth {Max 2 (AD - 5)})}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(WidthMenu " - 10 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidth $)}
				 {Store store(StoreWidth {Max 2 (AD - 10)})}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(WidthMenu " - 25 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidth $)}
				 {Store store(StoreWidth {Max 2 (AD - 25)})}
				 {self UpdateSizes}
			      end 
			   end 
			   _)
	   addCommandEntry(NodeNumberMenu " 0 " 
			   proc {$} {Store store(StoreNodeNumber 0)} end 
			   _)
	   addCommandEntry(NodeNumberMenu " 100 "
			   proc {$} {Store store(StoreNodeNumber 100)} end 
			   _)
	   addCommandEntry(NodeNumberMenu " 500 "
			   proc {$} {Store store(StoreNodeNumber 500)} end 
			   _)
	   addCommandEntry(NodeNumberMenu " 1000 "
			   proc {$} {Store store(StoreNodeNumber 1000)} end 
			   _)
	   addCommandEntry(NodeNumberMenu " 5000 "
			   proc {$} {Store store(StoreNodeNumber 5000)} end 
			   _)
	   addCommandEntry(NodeNumberMenu " infinite "
			   proc {$} {Store store(StoreNodeNumber DInfinite)} end 
			   _)
	   addCommandEntry(NodeNumberMenu " + 100 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreNodeNumber $)}
				 {Store store(StoreNodeNumber (AD + 100))}
			      end 
			   end 
			   _)
	   addCommandEntry(NodeNumberMenu " + 500 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreNodeNumber $)}
				 {Store store(StoreNodeNumber (AD + 500))}
			      end 
			   end 
			   _)
	   addCommandEntry(NodeNumberMenu " + 1000 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreNodeNumber $)}
				 {Store store(StoreNodeNumber (AD + 1000))}
			      end 
			   end 
			   _)
	   addCommandEntry(NodeNumberMenu " - 100 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreNodeNumber $)}
				 {Store store(StoreNodeNumber {Max 0 (AD - 100)})}
			      end 
			   end 
			   _)
	   addCommandEntry(NodeNumberMenu " - 500 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreNodeNumber $)}
				 {Store store(StoreNodeNumber {Max 0 (AD - 500)})}
			      end 
			   end 
			   _)
	   addCommandEntry(NodeNumberMenu " - 1000 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreNodeNumber $)}
				 {Store store(StoreNodeNumber {Max 0 (AD - 1000)})}
			      end 
			   end 
			   _)
	   addCommandEntry(IncDepthMenu " 1 " 
			   proc {$} 
			      {Store store(StoreDepthInc 1)} 
			   end 
			   _)
	   addCommandEntry(IncDepthMenu " 2 "
			   proc {$}
			      {Store store(StoreDepthInc 2)}
			   end 
			   _)
	   addCommandEntry(IncDepthMenu " 5 "
			   proc {$}
			      {Store store(StoreDepthInc 5)}
			   end 
			   _)
	   addCommandEntry(IncDepthMenu " 10 "
			   proc {$}
			      {Store store(StoreDepthInc 10)}
			   end 
			   _)
	   addCommandEntry(IncDepthMenu " + 1 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreDepthInc $)}
				 {Store store(StoreDepthInc (AD + 1))}
			      end 
			   end 
			   _)
	   addCommandEntry(IncDepthMenu " + 2 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreDepthInc $)}
				 {Store store(StoreDepthInc (AD + 2))}
			      end 
			   end 
			   _)
	   addCommandEntry(IncDepthMenu " + 5 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreDepthInc $)}
				 {Store store(StoreDepthInc (AD + 5))}
			      end 
			   end 
			   _)
	   addCommandEntry(IncDepthMenu " - 1 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreDepthInc $)}
				 {Store store(StoreDepthInc {Max 1 (AD - 1)})}
			      end 
			   end 
			   _)
	   addCommandEntry(IncDepthMenu " - 2 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreDepthInc $)}
				 {Store store(StoreDepthInc {Max 1 (AD - 2)})}
			      end 
			   end 
			   _)
	   addCommandEntry(IncDepthMenu " - 5 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreDepthInc $)}
				 {Store store(StoreDepthInc {Max 1 (AD - 5)})}
			      end 
			   end 
			   _)
	   addCommandEntry(IncWidthMenu " 1 "
			   proc {$}
			      {Store store(StoreWidthInc 1)}
			   end 
			   _)
	   addCommandEntry(IncWidthMenu " 2 "
			   proc {$}
			      {Store store(StoreWidthInc 2)}
			   end 
			   _)
	   addCommandEntry(IncWidthMenu " 5 "
			   proc {$}
			      {Store store(StoreWidthInc 5)}
			   end 
			   _)
	   addCommandEntry(IncWidthMenu " 10 "
			   proc {$}
			      {Store store(StoreWidthInc 10)}
			   end 
			   _)
	   addCommandEntry(IncWidthMenu " 25 "
			   proc {$}
			      {Store store(StoreWidthInc 25)}
			   end 
			   _)
	   addCommandEntry(IncWidthMenu " + 1 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidthInc $)}
				 {Store store(StoreWidthInc (AD + 1))}
			      end 
			   end 
			   _)
	   addCommandEntry(IncWidthMenu " + 2 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidthInc $)}
				 {Store store(StoreWidthInc (AD + 2))}
			      end 
			   end 
			   _)
	   addCommandEntry(IncWidthMenu " + 5 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidthInc $)}
				 {Store store(StoreWidthInc (AD + 5))}
			      end 
			   end 
			   _)
	   addCommandEntry(IncWidthMenu " + 10 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidthInc $)}
				 {Store store(StoreWidthInc (AD + 10))}
			      end 
			   end 
			   _)
	   addCommandEntry(IncWidthMenu " - 1 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidthInc $)}
				 {Store store(StoreWidthInc {Max 1 (AD - 1)})}
			      end 
			   end 
			   _)
	   addCommandEntry(IncWidthMenu " - 2 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidthInc $)}
				 {Store store(StoreWidthInc {Max 1 (AD - 2)})}
			      end 
			   end 
			   _)
	   addCommandEntry(IncWidthMenu " - 5 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidthInc $)}
				 {Store store(StoreWidthInc {Max 1 (AD - 5)})}
			      end 
			   end 
			   _)
	   addCommandEntry(IncWidthMenu " - 10 "
			   proc {$} 
			      local AD in 
				 AD = {Store read(StoreWidthInc $)}
				 {Store store(StoreWidthInc {Max 1 (AD - 10)})}
			      end 
			   end 
			   _)
	   addSeparatorEntry(ViewMenu)
	   defineSubMenu(ViewMenu True FontMenu)
	   addMenuEntry(ViewMenu " Font " FontMenu FontMenuProc)
	   defineSubMenu(FontMenu True FontMiscMenu)
	   addMenuEntry(FontMenu " Misc " FontMiscMenu FontMiscMenuProc)
	   defineSubMenu(FontMenu True FontCourMenu)
	   addMenuEntry(FontMenu " Courier " FontCourMenu FontCourMenuProc)
	   createTkVar({Store read(StoreTWFont $)}.font
		       proc {$ Val} 
			  local FN in 
			     FN = {String.toAtom Val}
			     {ForAll
			      {Append IKnownMiscFonts IKnownCourFonts}
			      proc {$ Font} 
				 case Font.font == FN then 
				    {Store store(StoreTWFont Font)}
				    {Window setTWFont}
				 else true 
				 end 
			      end}
			  end 
		       end
		       FontVar)

\ifdef FEGRAMED
	   pushMenuButton("Fegramed" FE_MB _)
	   defineMenu(FE_MB True FE_Menu)
	   addCommandEntry(FE_Menu "Show in Fegramed"
			   proc {$} {self FE_Browse} end FE_ShowSelectedProc)
	   addSeparatorEntry(FE_Menu)
	   
	   createTkVar(off proc{$ X}
			      case X
			      of "off" then {self FE_SetShowCurrent(False)}
			      [] "on" then {self FE_SetShowCurrent(True)}
			      end
			   end ?FE_Var)
	  
	   addCheckEntry(FE_Menu "Top to Fegramed" FE_Var
			 on off
			 _)

	  
	   addSeparatorEntry(FE_Menu)
	   addCommandEntry(FE_Menu "Close Fegramed"
			   proc {$} {self FE_CloseFE} end
			   _)
	   addCommandEntry(FE_Menu "Start new Fegramed "
			   proc {$} {self FE_StartFE} end
			   _)
	   addSeparatorEntry(FE_Menu)
	   addCommandEntry(FE_Menu "Close all"
			   proc {$} {self FE_CloseAllFE} end
			   _)
\endif
	   
	   %%
	   exposeMenusFrame
	   sync(Sync)]}
	 %%
	 %% 
	 {ForAll IKnownMiscFonts 
	  proc {$ Font}
	     local CProc in 
		{Window 
		 addRadioEntry(FontMiscMenu 
			       {List.flatten
				[" " {Atom.toString Font.name} " "]} 
			       FontVar Font.font CProc)}
		%%
		%%
		case {Window tryFont(Font.font $)}
		then true	% font exists - ok;
		else {CProc state disabled}
		end
		%%
	     end
	  end}
	 {ForAll IKnownCourFonts 
	  proc {$ Font} 
	     local CProc in 
		{Window 
		 addRadioEntry(FontCourMenu 
			       {List.flatten
				[" " {Atom.toString Font.name} " "]} 
			       FontVar Font.font CProc)}
		%%
		%%
		case {Window tryFont(Font.font $)}
		then true	% font exists - ok;
		else {CProc state disabled}
		end
		%%
	     end
	  end}
	 %%
	 %%
	 case self.IsView then
	    local DummyProc in 
	       DummyProc = proc {$ _ _} true end
	       %% 
	       ClearEntryProc = DummyProc
	       ClearHistoryEntryProc = DummyProc
	       {ClearEntryProcTmp state disabled}
	       {ClearHistoryEntryProcTmp state disabled}
	       {HLMProc state disabled}
	    end
	 else
	    ClearEntryProc = ClearEntryProcTmp
	    ClearHistoryEntryProc = ClearHistoryEntryProcTmp
	 end
	 %%
	 %% 
	 case @current == InitValue then 
	    {RebrowseEntryProc state disabled}
	    {RedrawEntryProc state disabled}
	    {ClearEntryProc state disabled}
	    {ClearHistoryEntryProc state disabled}
	 else 
	    {RebrowseEntryProc state normal}
	    {RedrawEntryProc state normal}
	    {ClearEntryProc state normal}
	    {ClearHistoryEntryProc state normal}
	 end 

	 % expand/shrink/show/zoom/deref disabled simply; 
	 {ExpandEntryProc state disabled}
	 {ShrinkEntryProc state disabled}
	 {ShowEntryProc state disabled}
	 {ZoomEntryProc state disabled}
	 {DerefEntryProc state disabled}
	 
\ifdef FEGRAMED
	 {FE_ShowSelectedProc state disabled}
\endif
	 %%
	 %%
	 
	 case self.IsView then 
	    local DummyProc in 
	       DummyProc = proc {$ _ _} true end
	       %%
	       FirstEntryProc = DummyProc
	       LastEntryProc = DummyProc
	       NextEntryProc = DummyProc
	       PreviousEntryProc = DummyProc
	       AllEntryProc = DummyProc
	       %%
	       {FirstEntryProcTmp state disabled}
	       {LastEntryProcTmp state disabled}
	       {NextEntryProcTmp state disabled}
	       {PreviousEntryProcTmp state disabled}
	       {AllEntryProcTmp state disabled}
	    end
	 else
	    FirstEntryProc = FirstEntryProcTmp
	    LastEntryProc = LastEntryProcTmp
	    NextEntryProc = NextEntryProcTmp
	    PreviousEntryProc = PreviousEntryProcTmp
	    AllEntryProc = AllEntryProcTmp
	 end
	 %%
	 %% 
	 case @current == InitValue then
	    {FirstEntryProc state disabled}
	    {LastEntryProc state disabled}
	    {NextEntryProc state disabled}
	    {PreviousEntryProc state disabled}
	    {AllEntryProc state disabled}
	    {UnzoomEntryProc state disabled}
	    {CreateNewViewEntryProc state disabled}
	    {TopEntryProc state disabled}
	 else 
	    %
	    case @zoomStack == nil then 
	       {UnzoomEntryProc state disabled}
	       {TopEntryProc state disabled}
	    else
	       {UnzoomEntryProc state normal}
	       {TopEntryProc state normal}
	    end 

	    % 
	    case @showAll then
	       {AllEntryProc state disabled}
	       {FirstEntryProc state normal}
	       {LastEntryProc state normal}
	       {PreviousEntryProc state disabled}
	       {NextEntryProc state disabled}
	    else
	       {AllEntryProc state normal}

	       % 
	       case @forward == nil then
		  {NextEntryProc state disabled}
		  {LastEntryProc state disabled}
	       else
		  {NextEntryProc state normal}
		  {LastEntryProc state normal}
	       end 

	       %
	       case @backward == nil then
		  {PreviousEntryProc state disabled}
		  {FirstEntryProc state disabled}
	       else
		  {PreviousEntryProc state normal}
		  {FirstEntryProc state normal}
	       end 
	    end 
	 end 
	 %%
	 %%
	 %%
	 case self.standAlone then true
	 else {CloseEntryProc state disabled}
	 end	
	 %%
	 %% 
	 %% menuEntrys <- menuEntrys()
	 %%
	 %% 
	 %% menus <- menus()
	 %%
	 %% 
	 entries <- entries(createNewView: CreateNewViewEntryProc
			    depthMenu: DepthMenuProc
			    widthMenu: WidthMenuProc
			    incDepthMenu: IncDepthMenuProc
			    incWidthMenu: IncWidthMenuProc
			    fontMiscMenu: FontMiscMenuProc
			    fontCourMenu: FontCourMenuProc
			    rebrowse: RebrowseEntryProc
			    redraw: RedrawEntryProc
			    clear: ClearEntryProc
			    clearHistory: ClearHistoryEntryProc
			    expand: ExpandEntryProc
			    shrink: ShrinkEntryProc
			    show: ShowEntryProc
			    zoom: ZoomEntryProc
			    unzoom: UnzoomEntryProc
			    top: TopEntryProc
			    deref: DerefEntryProc
			    first: FirstEntryProc
			    last: LastEntryProc
			    previous: PreviousEntryProc
			    next: NextEntryProc
			    all: AllEntryProc
\ifdef FEGRAMED
			    fE_ShowSelected: FE_ShowSelectedProc
\endif
			   )

	 %%
	 tclVars <- variables(scrolling: ScrollingVar
			      cycleCheck: CycleCheckVar
			      onlyCycles: OnlyCyclesVar
			      arityType: ArityTypeVar
			      vss: AreVSsVar
			      heavyVars: HeavyVarsVar
			      fillStyle: FillStyleVar
			      flatLists: FlatListsVar
			      smallNames: SmallNamesVar
			      areInactive: AreInactiveVar
			      font: FontVar)

	 %%
	 %% 
	 case {IsValue Sync} then 
	    <<nil>>
	 end
      end 
   end 

   %% 
   %% 
   meth toggleButtons
\ifdef DEBUG_BO
      {Show 'WindowPrimary::toggleButtons is applied'}
\endif
      case @window == InitValue then true
      else 
	 local Sync in 
	    case @buttons == InitValue then 
	       <<CreateButtons(Sync)>>
	       {@store store(StoreAreButtons True)}
	    else 
	       <<closeButtons>>
	       {@store store(StoreAreButtons False)}
	       Sync = ok
	    end 

	    % 
	    case {IsValue Sync} then 
	       {@window setMinSize}
	    end
	 end
      end 
   end 

   %% 
   %% 
   meth toggleMenus
\ifdef DEBUG_BO
      {Show 'WindowPrimary::toggleMenus is applied'}
\endif 
      case @window == InitValue then true
      else 
	 local Sync in 
	    case @entries == InitValue then 
	       <<CreateMenus(Sync)>>
	       {@store store(StoreAreMenus True)}
	    else 
	       <<closeMenus>>
	       {@store store(StoreAreMenus False)}
	       Sync = ok 
	    end 

	    % 
	    case {IsValue Sync} then 
	       {@window setMinSize}
	    end
	 end
      end
   end 

   %%
   %%
   meth !ResetWindowSize()
      case @window == InitValue then true
      else 
	 local X Y in
	    {@store [read(StoreXSize X) read(StoreYSize Y)]}

	    % 
	    {@window [setXYSize(X Y) resetTW]}
	 end 
      end 
   end 

   %%
   %%
   meth focusIn
\ifdef DEBUG_BO
      {Show 'WindowPrimary::focusIn is applied'}
\endif 
      case @window == InitValue then true
      else {@window focusIn}
      end 
   end 
   
   %% 
   %%  Send the method 'updateSizes' on the shown term; 
   %% 
   meth !UpdateSizes()
\ifdef DEBUG_BO
      {Show 'WindowPrimary::UpdateSizes is applied'}
\endif 
      case @window == InitValue orelse @current == InitValue then true 
      else 
	 local Depth Sync in 
	    {@store read(StoreDepth Depth)}
	    case @showAll == False then
	       % relational!
	       if TermObject in {Subtree @current termObject} = TermObject then 
		  {TermObject updateSizes(Depth Sync)}
	       else 
		  {BrowserError ['termObject is not found for @curent (UpdateSizes)']}
	       fi 

	       % 
	       case {IsValue Sync} then 
		  <<nil>>
	       end
	    else
	       {Map @current|@backward    % reverse order;
		proc {$ TermRec Sync}
		   % relational!
		   if TermObject in {Subtree TermRec termObject} = TermObject then
		      {TermObject updateSizes(Depth Sync)}
		   else {BrowserError
			 ['termObject is not found for @curent (UpdateSizes)']}
		   fi
		end Sync}

	       %
	       case {All Sync IsValue} then
		  <<nil>>
	       end
	    end 
	 end 
      end 
   end 

   %% 
   %% 'ConfigureFalsetify' (X11 notion) handler; 
   %%  
   meth !SetTWWidth(Width)
\ifdef DEBUG_BO
      {Show 'WindowPrimary::SetTWWidth is applied'}
      case {IsValue Width} then {Show '... Width = '#Width} end
\endif
      case @current == InitValue then
	 case {IsValue Width} then
	    {@store store(StoreTWWidth Width)}
	 end
      else
	 case {Det Width} then Sync in
	    {@store store(StoreTWWidth Width)}

	    % 
	    case @showAll == False then
	       % relational!
	       if TermObject in {Subtree @current termObject} = TermObject then 
		  {TermObject checkLayout(Sync)}
	       else 
		  {BrowserError ['termObject is not found for @curent (SetTWWidth)']}
	       fi 

	       % 
	       case {IsValue Sync} then 
		  <<nil>>
	       end
	    else
	       local ListOf SyncList in 
		  case @zoomStack == nil then
		     ListOf = @current|@backward   % in reverse order, but ...

		     %
		     {Map
		      ListOf
		      proc {$ TermRec Sync}
			 % relational! 
			 if Obj in {Subtree TermRec termObject} = Obj then
			    {Obj checkLayout(Sync)}
			 else Sync = ok   % can be if a new screen is open;
			 fi
		      end
		      SyncList}

		     %
		     % relational; 
		     case {All SyncList IsValue} then
			<<nil>>
		     end
		  else
		     local Sync in
			% relational! 
			if TermObject in {Subtree @current termObject} = TermObject then 
			   {TermObject checkLayout(Sync)}
			else {BrowserError
			      ['termObject is not found for @curent (SetTWWidth)']}
			fi 

			% 
			case {IsValue Sync} then 
			   <<nil>>
			end
		     end
		  end 
	       end 
	    end 
	 end 
      end 
   end 

   %% 
   %% 
   meth !Iconify()
\ifdef DEBUG_BO
      {Show 'WindowPrimary::Iconify is applied'}
\endif
      case @window == InitValue then true 
      else {@window iconify}
      end
   end 

   %% 
   %% 
   meth closeWindows
\ifdef DEBUG_BO
      {Show 'WindowPrimary::closeWindows is applied'}
\endif 
      %
      local Window in
	 Window = @window
	 case Window == InitValue then true 
	 else
	    %%
	    case self.standAlone then
	       %% 
	       {Window close}
	       %%
	       %% 
	       window <- InitValue
	       buttons <- InitValue
	       % menuButtons <- InitValue
	       % menus <- InitValue
	       entries <- InitValue
	       tclVars <- InitValue
	       %%
	       %% 
	       case @current == InitValue then true 
	       else current <- InitValue
	       end 
	       %%
	       %% 
	       forward <- nil
	       backward <- nil
	       zoomStack <- nil
	       %%
	       %% 
	       {BrowserMessagesExit self}
	    else true
	    end
	 end 
      end
   end 

   %% 
   %% 
   meth closeMenus
\ifdef DEBUG_BO
      {Show 'WindowPrimary::closeMenus is applied'}
\endif 
      {@window closeMenusFrame}
      % menuButtons <- InitValue
      % menus <- InitValue
      entries <- InitValue
      tclVars <- InitValue
   end 

   %% 
   %% 
   meth closeButtons
\ifdef DEBUG_BO
      {Show 'WindowPrimary::closeButtons is applied'}
\endif 
      {@window closeButtonsFrame}
      buttons <- InitValue
   end 
end 

%% 
%% 
%%  'Basic' browser (without history, buffers, etc.); 
%% 
class BasicBrowser from UrObject 
   %% 
   %%  no additional attributes; 

   %% 
   %%  'Proper' browse method; 
   %%  Don't care ubout undraw, history, etc. 
   %% 
   meth !Bbrowse(TermRec ?NewTermRec)
\ifdef DEBUG_BO
      {Show 'BasicBrowser::Bbrowse is applied'#TermRec.term}
\endif 
      local WSync CheckStyle OnlyCycles Depth TermsStore TermObject Sync Tag in 
	 <<createWindow(WSync)>>
	 case {IsValue WSync} then 
	    %%
	    %% relational!
	    if TermObject in {Subtree TermRec termObject} = TermObject then
	       %%
	       %% simply draw; 
	       {TermObject draw(Sync)}
	       case {Det Sync} then IsScrolling in
		  %%
		  NewTermRec = termRec(term: TermRec.term
				       termObject: TermRec.termObject
				       termsStore: TermRec.termsStore)
		  <<nil>>
	       end
	    else 
	       %%
	       {@store [read(StoreCheckStyle CheckStyle)
			read(StoreOnlyCycles OnlyCycles)
			read(StoreDepth Depth)]}
	       %%
	       %%
	       TermsStore = {New ProtoTermsStore 
			     init(isChecking: case CheckStyle then True
					      else OnlyCycles
					      end
				  onlyCycles: OnlyCycles
				  store:      @store)}
	       %%
	       %% 
	       TermObject = {New PseudoTermObject
			     init(repType: In_Text_Widget
				  widgetObj: @window
				  depth: Depth
				  term: TermRec.term
				  store: @store
				  termsStore: TermsStore
				  browserObj: self)}
	       %%
	       %%
	       {TermObject draw(Sync)}
	       %%
	       {Wait Sync}
	       %%
	       NewTermRec = termRec(term: TermRec.term
				    termObject: TermObject
				    termsStore: TermsStore)
	       <<nil>>
	    fi 
	 end
      end 
   end 

   %% 
   %%  'Proper' undraw; 
   %% 
   meth !Bundraw(TermRec)
\ifdef DEBUG_BO
      {Show 'BasicBrowser::Undraw is applied'#TermRec.term}
\endif 
      local Sync in
	 % relational! 
	 if TermObject in {Subtree TermRec termObject} = TermObject then 
	    {TermObject undraw(Sync)}
	 else Sync = ok
	 fi 

	 % 
	 case {IsValue Sync} then <<nil>> end
      end 
   end 

end 

%% 
%% 
%%  BrowserClass; 
%% 
class BrowserClass from BasicBrowser WindowPrimary
   %% 
   feat
      standAlone
      !IsView
      !DefaultBrowser
   %%
   %% 
   attr 
      store: InitValue
      forward: nil
      backward: nil
      current: InitValue
      showAll: IShowAll
      selected: InitValue
      zoomStack: nil
   %%
   %% 
   meth init(areMenus: AreMenus <= False
	     areButtons: AreButtons <= False
	     origWindow: OrigWindow <= InitValue
	     standAlone: StandAlone <= True
	     screen: Screen <= InitValue
	     DefaultBrowser: IsDefaultBrowser <= False 
	     IsView: IsIsView <= False)
\ifdef DEBUG_BO
      {Show 'BrowserClass::init is applied'}
\endif
      %^
      self.standAlone = StandAlone
      self.DefaultBrowser = IsDefaultBrowser
      self.IsView = IsIsView
      %%
      %% 
      local Store in
	 Store = {New ProtoStore 
		  [store(StoreXSize IXSize)
		   store(StoreYSize IYSize)
		   store(StoreXMinSize IXMinSize)
		   store(StoreYMinSize IYMinSize)
		   store(StoreTWWidth 0)
		   store(StoreDepth IDepth)
		   store(StoreNodeNumber INodeNumber)
		   store(StoreWidth IWidth)
		   store(StoreFillStyle IFillStyle)
		   store(StoreArityType IArityType)
		   store(StoreHeavyVars IHeavyVars)
		   store(StoreFlatLists IFlatLists)
		   store(StoreScrolling IScrolling)
		   store(StoreSmallNames ISmallNames)
		   store(StoreAreInactive IAreInactive)
		   store(StoreAreVSs IAreVSs)
		   store(StoreDepthInc IDepthInc)
		   store(StoreWidthInc IWidthInc)
		   store(StoreCheckStyle ICheckStyle)
		   store(StoreOnlyCycles IOnlyCycles)
		   store(StoreTWFont ITWFontUnknown)  % first approximation;
		   store(StoreHistoryLength IHistoryLength)
		   store(StoreAreButtons case AreButtons then True else False end)
		   store(StoreAreMenus case AreMenus then True else False end)
		   store(StoreOrigWindow OrigWindow)
		   store(StoreScreen Screen)]}
	 %%
	 %% 
	 case {IsValue Store} then 
	    store <- Store
	 end
	 %%
      end 
   end 

   %% 
   meth close
\ifdef DEBUG_BO
      {Show 'BrowserClass::close is applied'}
\endif 
      %% 
      <<closeWindows>>
      %%
      %%
      %% 
      case self.DefaultBrowser then {BrowsersPool removeBrowser(self)}
      else true
      end
      %%
      %%  simple throw termsStore and termObject if any; 
      %%
      <<UrObject close>>
   end 

   %%
   %%
   meth setParameter(NameOf ValueOf)
\ifdef DEBUG_BO
      {Show 'BrowserClass::setParameter is applied'#NameOf}
\endif 
      case NameOf
      of !BrowserXSize                  then
	 case {IsInt ValueOf} andthen ValueOf > 1 then 
	    {@store store(StoreXSize ValueOf)}
	    <<ResetWindowSize>>
	 else {BrowserError ['Illegal value of parameter BrowserXSize']}
	 end
      [] !BrowserYSize                  then
	 case {IsInt ValueOf} andthen ValueOf > 1 then 
	    {@store store(StoreYSize ValueOf)}
	    <<ResetWindowSize>>
	 else {BrowserError ['Illegal value of parameter BrowserYSize']}
	 end
      [] !BrowserXMinSize               then
	 case {IsInt ValueOf} andthen ValueOf > 1 then 
	    {@store store(StoreXMinSize ValueOf)}
	 else {BrowserError ['Illegal value of parameter BrowserXMinSize']}
	 end
      [] !BrowserYMinSize               then
	 case {IsInt ValueOf} andthen ValueOf > 1 then 
	    {@store store(StoreYMinSize ValueOf)}
	 else {BrowserError ['Illegal value of parameter BrowserYMinSize']}
	 end
      [] !BrowserDepth                  then
	 case {IsInt ValueOf} andthen ValueOf > 0 then
	    {@store store(StoreDepth ValueOf)}
	    {self UpdateSizes}
	 else {BrowserError ['Illegal value of parameter BrowserDepth']}
	 end
      [] !BrowserWidth                  then
	 case {IsInt ValueOf} andthen ValueOf > 1 then
	    {@store store(StoreWidth ValueOf)}
	    {self UpdateSizes}
	 else {BrowserError ['Illegal value of parameter BrowserWidth']}
	 end
      [] !BrowserNodes                  then
	 case {IsInt ValueOf} then
	    {@store store(StoreNodeNumber ValueOf)}
	 else {BrowserError ['Illegal value of parameter BrowserNodes']}
	 end
      [] !BrowserDepthInc               then 
	 case {IsInt ValueOf} andthen ValueOf > 0 then
	    {@store store(StoreDepthInc ValueOf)}
	 else {BrowserError ['Illegal value of parameter BrowserDepthInc']}
	 end
      [] !BrowserWidthInc               then
	 case {IsInt ValueOf} andthen ValueOf > 0 then
	    {@store store(StoreWidthInc ValueOf)}
	 else {BrowserError ['Illegal value of parameter BrowserWidthInc']}
	 end
      [] !BrowserScrolling              then 
	 case ValueOf then
	    % relational! 
	    {@store store(StoreScrolling True)}
	    if V in {Subtree @tclVars scrolling} = V then
	       {V tkSet(TclTrue)}
	    else true
	    fi
	 else
	    case ValueOf == False then
	       % relational! 
	       {@store store(StoreScrolling False)}
	       if V in {Subtree @tclVars scrolling} = V then
		  {V tkSet(TclFalse)}
	       else true
	       fi
	    else
	       {BrowserError
		['Illegal value of parameter BrowserScrolling']}
	    end
	 end
      [] !BrowserCoreferences           then 
	 case ValueOf then
	    % relational! 
	    {@store store(StoreCheckStyle True)}
	    if V in {Subtree @tclVars cycleCheck} = V then
	       {V tkSet(TclTrue)}
	    else true
	    fi
	 else
	    case ValueOf == False then
	       % relational! 
	       {@store store(StoreCheckStyle False)}
	       if V in {Subtree @tclVars cycleCheck} = V then
		  {V tkSet(TclFalse)}
	       else true
	       fi
	    else
	       {BrowserError
		['Illegal value of parameter BrowserCoreferences']}
	    end
	 end
      [] !BrowserCycles                 then 
	 case ValueOf then
	    % relational! 
	    {@store store(StoreOnlyCycles True)}
	    if V in {Subtree @tclVars onlyCycles} = V then
	       {V tkSet(TclTrue)}
	    else true
	    fi
	 else
	    case ValueOf == False then
	       % relational! 
	       {@store store(StoreOnlyCycles False)}
	       if V in {Subtree @tclVars onlyCycles} = V then
		  {V tkSet(TclFalse)}
	       else true
	       fi
	    else
	       {BrowserError ['Illegal value of parameter BrowserCycles']}
	    end
	 end
      [] !BrowserPrivateFields          then 
	 case ValueOf then
	    % relational! 
	    {@store store(StoreArityType TrueArity)}
	    if V in {Subtree @tclVars arityType} = V then
	       {V tkSet(TclTrueArity)}
	    else true
	    fi
	 else
	    case ValueOf == False then
	       % relational! 
	       {@store store(StoreArityType AtomicArity)}
	       if V in {Subtree @tclVars arityType} = V then
		  {V tkSet(TclAtomicArity)}
	       else true 
	       fi
	    else
	       {BrowserError
		['Illegal value of parameter BrowserPrivateFields']}
	    end
	 end
      [] !BrowserVirtualStrings         then 
	 case ValueOf then
	    % relational! 
	    {@store store(StoreAreVSs True)}
	    if V in {Subtree @tclVars vss} = V then
	       {V tkSet(TclTrue)}
	    else true 
	    fi
	 else
	    case ValueOf == False then
	       % relational! 
	       {@store store(StoreAreVSs False)}
	       if V in {Subtree @tclVars vss} = V then
		  {V tkSet(TclFalse)}
	       else true
	       fi
	    else
	       {BrowserError
		['Illegal value of parameter BrowserVirtualStrings']}
	    end
	 end
      [] !BrowserVariablesAligned       then 
	 case ValueOf then
	    % relational! 
	    {@store store(StoreHeavyVars True)}
	    if V in {Subtree @tclVars heavyVars} = V then
	       {V tkSet(TclTrue)}
	    else true
	    fi
	 else
	    case ValueOf == False then
	       % relational! 
	       {@store store(StoreHeavyVars False)}
	       if V in {Subtree @tclVars heavyVars} = V then
		  {V tkSet(TclFalse)}
	       else true
	       fi
	    else
	       {BrowserError
		['Illegal value of parameter BrowserVariablesAligned']}
	    end
	 end
      [] !BrowserRecordFieldsAligned    then 
	 case ValueOf then
	    % relational! 
	    {@store store(StoreFillStyle Expanded)}
	    if V in {Subtree @tclVars fillStyle} = V then
	       {V tkSet(TclExpanded)}
	    else true 
	    fi
	 else
	    case ValueOf == False then
	       % relational! 
	       {@store store(StoreFillStyle Filled)}
	       if V in {Subtree @tclVars fillStyle} = V then
		  {V tkSet(TclFilled)}
	       else true
	       fi
	    else
	       {BrowserError
		['Illegal value of parameter BrowserRecordFieldsAligned']}
	    end
	 end
      [] !BrowserListsFlat              then 
	 case ValueOf then
	    % relational! 
	    {@store store(StoreFlatLists True)}
	    if V in {Subtree @tclVars flatLists} = V then
	       {V tkSet(TclTrue)}
	    else true
	    fi
	 else
	    case ValueOf == False then
	       % relational! 
	       {@store store(StoreFlatLists False)}
	       if V in {Subtree @tclVars flatLists} = V then
		  {V tkSet(TclFalse)}
	       else true
	       fi
	    else
	       {BrowserError ['Illegal value of parameter BrowserListsFlat']}
	    end
	 end
      [] !BrowserNamesAndProcsShort     then 
	 case ValueOf then
	    % relational! 
	    {@store store(StoreSmallNames True)}
	    if V in {Subtree @tclVars smallNames} = V then
	       {V tkSet(TclTrue)}
	    else true
	    fi
	 else
	    case ValueOf == False then
	       % relational! 
	       {@store store(StoreSmallNames False)}
	       if V in {Subtree @tclVars smallNames} = V then
		  {V tkSet(TclFalse)}
	       else true
	       fi
	    else
	       {BrowserError
		['Illegal value of parameter BrowserNamesAndProcsShort']}
	    end
	 end
      [] !BrowserPrimitiveTermsActive   then 
	 case ValueOf then
	    % relational! 
	    {@store store(StoreAreInactive False)}
	    if V in {Subtree @tclVars areInactive} = V then
	       {V tkSet(TclFalse)}  % reverse! 
	    else true
	    fi
	 else
	    case ValueOf == False then
	       % relational! 
	       {@store store(StoreAreInactive True)}
	       if V in {Subtree @tclVars areInactive} = V then
		  {V tkSet(TclTrue)}
	       else true
	       fi
	    else
	       {BrowserError
		['Illegal value of parameter BrowserPrimitiveTermsActive']}
	    end
	 end
      [] !BrowserFont                   then 
	 case {IsAtom ValueOf} then
	    local Window Fonts in
	       Fonts = {Filter
			{Append IKnownMiscFonts IKnownCourFonts}
			fun {$ F} F.font == ValueOf end}
	       if Font in Fonts = [Font] then
		  %%
		  if V in {Subtree @tclVars font} = V then
		     {V tkSet(Font.font)}
		  else
 		     {@store store(StoreTWFont Font)}
		     %%
		     Window = @window
		     case Window == InitValue then true
		     else {Window setTWFont}
		     end
		  fi 
	       else
		  {BrowserError ['Illegal value of parameter BrowserFont']}
	       fi
	    end
	 else
	    {BrowserError ['Illegal value of parameter BrowserFont']}
	 end
      [] !BrowserAreButtons             then 
	 case ValueOf then
	    case {@store read(StoreAreButtons $)} == False then
	       case @window == InitValue then
		  {@store store(StoreAreButtons True)}
	       else 
		  <<toggleButtons>>
	       end
	    else true
	    end
	 else
	    case ValueOf == False then
	       case {@store read(StoreAreButtons $)} then
		  case @window == InitValue then
		     {@store store(StoreAreButtons False)}
		  else
		     <<toggleButtons>>
		  end 
	       else true
	       end
	    else
	       {BrowserError
		['Illegal value of parameter BrowserAreButtons']}
	    end
	 end
      [] !BrowserAreMenus               then 
	 case ValueOf then
	    case {@store read(StoreAreMenus $)} == False then
	       case @window == InitValue then
		  {@store store(StoreAreMenus True)}
	       else
		  <<toggleMenus>>
	       end
	    else true
	    end
	 else
	    case ValueOf == False then
	       case {@store read(StoreAreMenus $)} then
		  case @window == InitValue then
		     {@store store(StoreAreMenus False)}
		  else
		     <<toggleMenus>>
		  end
	       else true
	       end
	    else
	       {BrowserError
		['Illegal value of parameter BrowserAreButtons']}
	    end
	 end
      [] !BrowserShowAll                then
	 case ValueOf then
	    case @showAll then true
	    else
	       case @current == InitValue then showAll <- True
	       else <<all>>  % or 'first';
	       end
	    end
	 else
	    case ValueOf == False then
	       case @showAll == False then true
	       else
		  case @current == InitValue then showAll <- False
		  else <<last>>
		  end
	       end
	    else
	       {BrowserError ['Illegal value of parameter BrowserShowAll']}
	    end
	 end
      [] !BrowserBufferSize             then
	 case {IsInt ValueOf} andthen 0 =< ValueOf then
	    {@store store(StoreHistoryLength ValueOf)}
	    {self CheckHistory}
	 else
	    {BrowserError ['Illegal value of parameter BrowserBufferSize']}
	 end
      else
	 {BrowserError ['Unknown parameter in setParameter']}
      end
   end

   %%
   %%
   meth getParameter(NameOf ?ValueOf)
\ifdef DEBUG_BO
      {Show 'BrowserClass::getParameter is applied'#NameOf}
\endif 
      case NameOf
      of !BrowserXSize                  then {@store read(StoreXSize ValueOf)}
      [] !BrowserYSize                  then {@store read(StoreYSize ValueOf)}
      [] !BrowserXMinSize               then {@store read(StoreXMinSize ValueOf)}
      [] !BrowserYMinSize               then {@store read(StoreYMinSize ValueOf)}
      [] !BrowserDepth                  then {@store read(StoreDepth ValueOf)}
      [] !BrowserWidth                  then {@store read(StoreWidth ValueOf)}
      [] !BrowserNodes                  then {@store read(StoreNodeNumber ValueOf)}
      [] !BrowserDepthInc               then {@store read(StoreDepthInc ValueOf)}
      [] !BrowserWidthInc               then {@store read(StoreWidthInc ValueOf)}
      [] !BrowserScrolling              then
	 ValueOf = {@store read(StoreScrolling $)} 
      [] !BrowserCoreferences           then
	 ValueOf = {@store read(StoreCheckStyle $)} 
      [] !BrowserCycles                 then
	 ValueOf = {@store read(StoreOnlyCycles $)}
      [] !BrowserPrivateFields          then
	 case {@store read(StoreArityType $)} == TrueArity then ValueOf = True
	 else ValueOf = False
	 end
      [] !BrowserVirtualStrings         then
	 ValueOf = {@store read(StoreAreVSs $)}
      [] !BrowserVariablesAligned       then
	 ValueOf = {@store read(StoreHeavyVars $)}
      [] !BrowserRecordFieldsAligned    then
	 case {@store read(StoreFillStyle $)} == Expanded then ValueOf = True
	 else ValueOf = False
	 end
      [] !BrowserListsFlat              then
	 ValueOf = {@store read(StoreFlatLists $)}
      [] !BrowserNamesAndProcsShort     then
	 ValueOf = {@store read(StoreSmallNames $)}
      [] !BrowserPrimitiveTermsActive   then
	 ValueOf = {@store read(StoreAreInactive $)}
      [] !BrowserFont                   then
	 ValueOf = {@store read(StoreTWFont $)}.font
      [] !BrowserAreButtons             then
	 ValueOf = {@store read(StoreAreButtons $)}
      [] !BrowserAreMenus               then 
	 ValueOf = {@store read(StoreAreMenus $)}
      [] !BrowserShowAll                then
	 case @window == InitValue then ValueOf = False 
	 else
	    ValueOf = @showAll
	 end
      [] !BrowserBufferSize             then
	 {@store read(StoreHistoryLength ValueOf)}
      else
	 {BrowserError ['Unknown parameter in setParameter']}
      end
   end 

   %% 
   %%
      /*
   %%  UNUSED & Out-Of-Date;
   %% 
   meth !SetActiveState(State)
\ifdef DEBUG_BO
      {Show 'BrowserClass::SetActiveState is applied'#State}
\endif 
      isActive <- State
   end
      */ 

   %% 
   %%  'browse' method (history maintaining); 
   %% 
   meth browse(Term)
\ifdef DEBUG_BO
      {Show 'BrowserClass::browse is applied'#Term}
\endif 
      %%
      %% 
      case @zoomStack == nil then
	 local TermRec HistoryLength in 
	    case @forward == nil then
	       %%
	       %% relational! 
	       case @current == InitValue then true 
	       else backward <- @current|@backward
	       end
	       %%
	       %% 
	       <<CheckHistory>>
	       %%
	       %%  ... iff don't show all terms; 
	       case @showAll then true 
	       else 
		  case @current == InitValue then true 
		  else <<Bundraw(@current)>>
		  end 
	       end 
	       %%
	       %% 
	       <<Bbrowse(termRec(term: Term) TermRec)>>
	       %%
	       %%
	       case @current == InitValue then 
		  case @buttons == InitValue then true 
		  else 
		     local Buttons = @buttons in 
			{Buttons.rebrowse state normal}
			{Buttons.redraw state normal}
			{Buttons.clear state normal}
			case @showAll then {Buttons.all state disabled}
			else {Buttons.all state normal}
			end 
		     end 
		  end 
		  %%
		  %% 
		  case @entries == InitValue then true 
		  else 
		     local Entries = @entries in 
			{Entries.rebrowse state normal}
			{Entries.redraw state normal}
			{Entries.clear state normal}
			{Entries.clearHistory state normal}
			case @showAll then {Entries.all state disabled}
			else {Entries.all state normal}
			end 
		     end 
		  end 
	       else true
	       end 
	       %%
	       %% 
	       current <- TermRec
	       %%
	       %% 
	       <<HistoryButtonsUpdate>>
	    else 
	       forward <- {Append @forward [termRec(term: Term)]}
	       <<HistoryButtonsUpdate>>
	    end 
	 end 
      else
	 %%%
	 % in 'zoom' modus; 
	 forward <- {Append @forward [termRec(term: Term)]}
	 <<HistoryButtonsUpdate>>
      end 
      %% else
      %%  forward <- {Append @forward [termRec(term: Term)]}
      %%  <<HistoryButtonsUpdate>>
      %% end 
   end 

   %%
   %%  
      /*
   %%  UNUSED and Out-Of-Date;
   %%
   %%  Make the copy of history for this browser; 
   %% 
   meth !GetHistory(?List)
\ifdef DEBUG_BO
      {Show 'BrowserClass::GetHistory is applied'}
\endif 
      %
      case @current == InitValue then List = nil
      else 
	 local ListOf in 
	    case @zoomStack == nil then 
	       ListOf = {Append {Reverse @current|@backward} @forward}
	    else
	       local OEl BTermRec in 
		  case @showAll == False then 
		     % 
		     OEl = {Nth @zoomStack {Length @zoomStack}}
		     % relational; 
		     if OEl = s(_) then OEl = s(BTermRec)
		     else {BrowserError 
			   ['non-singleton is found in zoom stack by "getHistory"']}
		     fi 

		     % 
		     ListOf = {Append {Reverse BTermRec|@backward} @forward}
		  else
		     local OEl in
			% 
			OEl = {Nth @zoomStack {Length @zoomStack}}
			% relational; 
			if OEl = a(_) then OEl = a(ListOf)
			else {BrowserError 
			      ['singleton is found in zoom stack by "getHistory"']}
			fi 
		     end 
		  end 
	       end 
	    end 

	    %
	    {Map ListOf proc {$ El NewEl} NewEl = termRec(term: El.term) end List}
	 end
      end 
   end
      */

   %%
   %%  
      /*
   %%  UNUSED and Out-Of-Date;
   %%
   %%  Impose a history for a child; 
   %%  Don't consider the actual forward, backward, etc.
   %% 
   meth !SetHistory(List)
\ifdef DEBUG_BO
      {Show 'BrowserClass::SetHistory is applied'}
\endif
      % relational; 
      if @forward = nil
	 @backward = nil
	 @current = InitValue
      then
	 case List == nil then true
	 else
	    case @showAll then
	       <<[DrawAll(List) HistoryButtonsUpdate]>>

	       %
	       case @buttons == InitValue then true 
	       else 
		  local Buttons = @buttons in 
		     {Buttons.rebrowse state normal}
		     {Buttons.redraw state normal}
		     {Buttons.clear state normal}
		     case @showAll then {Buttons.all state disabled}
		     else {Buttons.all state normal}
		     end 
		  end 
	       end 

	       % 
	       case @entries == InitValue then true 
	       else 
		  local Entries = @entries in 
		     {Entries.rebrowse state normal}
		     {Entries.redraw state normal}
		     {Entries.clear state normal}
		     {Entries.clearHistory state normal}
		     case @showAll then {Entries.all state disabled}
		     else {Entries.all state normal}
		     end  
		  end 
	       end 
	    else 
	       local RList in
		  RList = {Reverse List}

		  %
		  backward <- RList.2
		  <<browse(RList.1.term)>>
	       end
	    end 
	 end 
      else {BrowserError ['SetHistory for an browser object with a history']}
      fi 
   end
      */ 
   %%
   %%
   %%
   meth !CheckHistory()
\ifdef DEBUG_BO
      {Show 'BrowserClass::CheckHistory is applied'}
\endif 
      local HistoryLength ALength RestList in 
	 HistoryLength = {@store read(StoreHistoryLength $)}
	 ALength = {Length @backward}
	 %%
	 %%
	 case HistoryLength < ALength then
	    %%
	    case @showAll andthen @zoomStack == nil then
	       RestList = {Tail @backward (HistoryLength + 1)}
	       <<UndrawAll(RestList)>>
	    else true
	    end
	    %%
	    %%
	    backward <- {Head @backward HistoryLength}
	    <<HistoryButtonsUpdate>>
	 else true
	 end 
      end
   end

   %%
   %%
      /*
   %%  UNUSED & Out-Of-Date;
   %%  Replaced by the new 'createNewScreen' (beneath); 
   meth createNewScreen
\ifdef DEBUG_BO
      {Show 'BrowserClass::createNewScreen is applied'}
\endif 
      local NewBrowser History in
	 %
	 % relational! 
	 if {Subtree self inPool} = True then {BrowsersPool addNewBrowser(NewBrowser)}
	 else true
	 fi 

	 %
	 create NewBrowser
	    from BrowserClass
	    feat
	       standAlone: True   % even from embedded browser; 
	       inPool: if {Subtree self inPool} = True then True else False fi
	    % ^^^ relational! 
	    with init(areMenus:   {@store read(StoreAreMenus $)}
		      areButtons: {@store read(StoreAreButtons $)})
	 end

	 %
	 <<GetHistory(History)>>
	 {NewBrowser SetHistory(History)}
	 case History == nil then {NewBrowser createWindow(_)}
	 else true 
	 end 
      end
   end
      */ 
	    
   %%
   %%
   meth createNewView
\ifdef DEBUG_BO
      {Show 'BrowserClass::createNewView is applied'}
\endif 
      case @selected == InitValue then true
      else 
	 local NewBrowser Selection in
	    %%
	    NewBrowser = create $ from  BrowserClass
\ifdef FEGRAMED
				     FE_BrowserClass
\endif
			    with init(areMenus: {@store read(StoreAreMenus $)}
				      areButtons: {@store read(StoreAreButtons $)}
				      standAlone: True    % even from embedded browser;
				      IsView: True        % protected feature;
				     )
			 end
	    %%
	    %%
	    {NewBrowser browse(@selected.term)}
	 end
      end
   end
	    
   %% 
   %%  Simulate a sequence of 'browse' ops, but no buttons, etc.; 
   %% 
   meth DrawAll(List)
\ifdef DEBUG_BO
      {Show 'BrowserClass::DrawAll is applied'}
\endif 
      case List == nil then forward <- nil
      else 
	 local TermRec Rest NewTermRec in 
	    List = TermRec|Rest

	    %
	    % relational! 
	    case @current == InitValue then true 
	    else backward <- @current|@backward
	    end

	    % 
	    <<Bbrowse(TermRec NewTermRec)>>
	    current <- NewTermRec

	    % 
	    <<DrawAll(Rest)>>
	 end 
      end 
   end 

   %% 
   %%  ... simply undraw all terms from the 'List'; 
   %% 
   meth UndrawAll(List)
\ifdef DEBUG_BO
      {Show 'BrowserClass::UndrawAll is applied'}
\endif 
      case List == nil then true 
      else 
	 local TermRec Rest in 
	    List = TermRec|Rest

	    % 
	    <<Bundraw(TermRec)>>

	    % 
	    <<UndrawAll(Rest)>>
	 end 
      end 
   end 

   %% 
   %%  Draw-undraw; 
   %% 
   meth redraw
\ifdef DEBUG_BO
      {Show 'BrowserClass::redraw is applied'}
\endif 
      case @current == InitValue then true 
      else 
	 case @showAll then
	    local ListOf in 
	       case @zoomStack == nil then 
		  ListOf = {Reverse @current|@backward}

		  %
		  <<UndrawAll(ListOf)>>
		  backward <- nil
		  current <- InitValue
		  case @forward == nil then true
		  else {BrowserError ['not empty "forward" list by empty zoomStack']}
		  end 

		  <<DrawAll(ListOf)>>
	       else
		  local TermRec in 
		     <<Bundraw(@current)>>
		     <<Bbrowse(termRec(term: @current.term) TermRec)>>
		     current <- TermRec
		  end
	       end 
	    end 
	 else 
	    local TermRec in 
	       <<Bundraw(@current)>>
	       <<Bbrowse(@current TermRec)>>
	       current <- TermRec
	    end 
	 end 
      end 
   end 

   %% 
   %%  ... but force to generate a new internal representation; 
   %% 
   meth rebrowse
\ifdef DEBUG_BO
      {Show 'BrowserClass::rebrowse is applied'}
\endif 
      case @current == InitValue then true 
      else 
	 case @showAll then
	    local ListOf NewList in 
	       case @zoomStack == nil then 
		  ListOf = {Reverse @current|@backward}

		  % 
		  <<UndrawAll(ListOf)>>
		  backward <- nil
		  current <- InitValue
		  case @forward == nil then true
		  else {BrowserError ['not empty "forward" list by empty zoomStack']}
		  end 

		  % 
		  {Map
		   ListOf 
		   proc{$ TermRec RTermRec} 
		      RTermRec = termRec(term: TermRec.term)
		   end 
		   NewList}

		  %
		  <<DrawAll(NewList)>>
	       else
		  local TermRec in 
		     <<Bundraw(@current)>>
		     <<Bbrowse(termRec(term: @current.term) TermRec)>>
		     current <- TermRec
		  end
	       end 
	    end 
	 else 
	    local TermRec in 
	       <<Bundraw(@current)>>
	       <<Bbrowse(termRec(term: @current.term) TermRec)>>
	       current <- TermRec
	    end 
	 end 
      end 
   end 

   %% 
   %%  Undraw method, maintaining the history; 
   %% 
   meth undraw
\ifdef DEBUG_BO
      {Show 'BrowserClass::undraw is applied'}
\endif 
      %%
      case self.IsView then true
      else 
	 case @current == InitValue then true 
	 else 
	    case @showAll then 
	       local ListOf in 
		  ListOf = {Reverse @current|@backward}
		  %%
		  %% 
		  <<UndrawAll(ListOf)>>
		  current <- InitValue
		  forward <- nil
		  backward <- nil
	       end 
	    else 
	       <<Bundraw(@current)>>
	    end 
	    %%
	    %% 
	    zoomStack <- nil
	    %%
	    %% 
	    case @buttons == InitValue then true
	    else
	       local Buttons = @buttons in 
		  {Buttons.unzoom state disabled}
		  {Buttons.top state disabled}
	       end 
	    end
	    %%
	    %% 
	    case @entries == InitValue then true
	    else
	       local Entries = @entries in 
		  {Entries.unzoom state disabled}
		  {Entries.top state disabled}
	       end 
	    end 
	    %%
	    %% 
	    <<UnsetSelected>>
	    %%
	    %% 
	    case @forward == nil then 
	       case @backward == nil then 
		  current <- InitValue
		  %%
		  %% 
		  case @buttons == InitValue then true 
		  else 
		     local Buttons = @buttons in 
			{Buttons.rebrowse state disabled}
			{Buttons.redraw state disabled}
			{Buttons.clear state disabled}
			{Buttons.all state disabled}
		     end 
		  end 
		  %%
		  %%
		  case @entries == InitValue then true 
		  else 
		     local Entries = @entries in 
			{Entries.rebrowse state disabled}
			{Entries.redraw state disabled}
			{Entries.clear state disabled}
			{Entries.clearHistory state disabled}
			{Entries.all state disabled}
		     end 
		  end 
	       else 
		  local TermRec NewTermRec in 
		     TermRec = @backward.1
		     backward <- @backward.2
		     <<Bbrowse(TermRec NewTermRec)>>
		     current <- NewTermRec
		  end 
	       end 
	    else 
	       local TermRec NewTermRec in 
		  TermRec = @forward.1
		  forward <- @forward.2
		  <<Bbrowse(TermRec NewTermRec)>>
		  current <- NewTermRec
	       end 
	    end 
	    <<HistoryButtonsUpdate>>
	 end
      end
   end 

   %% 
   %%  SetSelected ('<1>' event for a term); 
   %% 
   meth !SetSelected(Obj AreCommas)
\ifdef DEBUG_BO
      {Show 'BrowserClass::SetSelected is applied'#Obj.term#Obj.type}
\endif 
      selected <- Obj

      % 
      case @buttons == InitValue then true 
      else 
	 local Buttons = @buttons in 
	    {Buttons.show state normal}
	    {Buttons.zoom state normal}

	    % 
	    case Obj.type == T_Shrunken then 
	       {Buttons.expand state normal}
	       {Buttons.shrink state disabled}
	       {Buttons.deref state disabled}
	    else
	       case AreCommas then 
		  {Buttons.expand state normal}
		  {Buttons.shrink state normal}
		  {Buttons.deref state disabled}
	       else 
		  case Obj.type == T_Reference then 
		     {Buttons.expand state disabled}
		     {Buttons.shrink state disabled}
		     {Buttons.deref state normal}
		  else 
		     {Buttons.expand state disabled}
		     {Buttons.shrink state normal}
		     {Buttons.deref state disabled}
		  end 
	       end 
	    end 
	 end 
      end 

      % 
      case @entries == InitValue then true 
      else 
	 local Entries = @entries in 
	    {Entries.show state normal}
	    {Entries.zoom state normal}
	    {Entries.createNewView state normal}
\ifdef FEGRAMED
	    {Entries.fE_ShowSelected state normal}
\endif
	    % 
	    case Obj.type == T_Shrunken then 
	       {Entries.expand state normal}
	       {Entries.shrink state disabled}
	       {Entries.deref state disabled}
	    else
	       case AreCommas then 
		  {Entries.expand state normal}
		  {Entries.shrink state normal}
		  {Entries.deref state disabled}
	       else 
		  case Obj.type == T_Reference then 
		     {Entries.expand state disabled}
		     {Entries.shrink state disabled}
		     {Entries.deref state normal}
		  else 
		     {Entries.expand state disabled}
		     {Entries.shrink state normal}
		     {Entries.deref state disabled}
		  end 
	       end 
	    end 
	 end 
      end 
   end 

   %% 
   %%  
   meth !UnsetSelected()
\ifdef DEBUG_BO
      {Show 'BrowserClass::UnsetSelected is applied'}
\endif 
      selected <- InitValue

      % 
      case @buttons == InitValue then true 
      else 
	 local Buttons = @buttons in 
	    {Buttons.expand state disabled}
	    {Buttons.shrink state disabled}
	    {Buttons.show state disabled}
	    {Buttons.zoom state disabled}
	    {Buttons.deref state disabled}
	 end 
      end  

      % 
      case @entries == InitValue then true 
      else 
	 local Entries = @entries in 
	    {Entries.expand state disabled}
	    {Entries.shrink state disabled}
	    {Entries.show state disabled}
	    {Entries.zoom state disabled}
	    {Entries.deref state disabled}
	    {Entries.createNewView state disabled}
\ifdef FEGRAMED
	    {Entries.fE_ShowSelected state disabled}
\endif
	 end 
      end 
   end 

   %% 
   %% 
   meth !SelExpand()
\ifdef DEBUG_BO
      {Show 'BrowserClass::SelExpand is applied'}
\endif 
      case @selected == InitValue then true
      else 
	 {@selected expand}
	 <<UnsetSelected>>
      end 
   end 

   %% 
   %% 
   meth !SelShrink()
\ifdef DEBUG_BO
      {Show 'BrowserClass::SelShrink is applied'}
\endif 
      case @selected == InitValue then true
      else 
	 {@selected shrink}
	 <<UnsetSelected>>
      end 
   end 

   %% 
   %% 
   meth !SelShow()
\ifdef DEBUG_BO
      {Show 'BrowserClass::SelShow is applied'}
\endif 
      case @selected == InitValue then true
      else 
	 {@selected show}
      end 
   end 

   %% 
   %% 
   meth !SelectAndZoom(Obj)
\ifdef DEBUG_BO
      {Show 'BrowserClass::SelectAndZoom is applied'#Obj.term}
\endif 
      <<UnsetSelected>>
      selected <- Obj
      <<Zoom>>
   end 

   %% 
   %%  zoom (i.e. replace the shown term with the selected term); 
   %% 
   meth !Zoom()
\ifdef DEBUG_BO
      {Show 'BrowserClass::Zoom is applied'}
\endif 
      case @selected == InitValue then true 
      else 
	 local NewTermRec in 
	    case @showAll then 
	       local ListOf in 
		  ListOf = {Reverse @current|@backward}

		  % 
		  <<UndrawAll(ListOf)>>
		  current <- InitValue
		  forward <- nil
		  backward <- nil

		  % the tuple with label 'a' for 'all' modus; 
		  zoomStack <- a(ListOf)|@zoomStack
	       end 
	    else 
	       <<Bundraw(@current)>>

	       % 
	       zoomStack <- s(@current)|@zoomStack
	    end 

	    % 
	    case @buttons == InitValue then true 
	    else
	       local Buttons = @buttons in 
		  {Buttons.unzoom state normal}
		  {Buttons.top state normal}
	       end 
	    end 

	    % 
	    case @entries == InitValue then true 
	    else
	       local Entries = @entries in 
		  {Entries.unzoom state normal}
		  {Entries.top state normal}
	       end 
	    end 

	    % 
	    <<Bbrowse(termRec(term: @selected.term) NewTermRec)>>
	    current <- NewTermRec 

	    % 
	    <<UnsetSelected>>
	 end 
      end 
   end 

   %% 
   %% 
   meth !Deref()
\ifdef DEBUG_BO
      {Show 'BrowserClass::Deref is applied'}
\endif 
      case @selected == InitValue then true 
      else 
	 {@selected deref}
	 <<UnsetSelected>>
      end 
   end 

   %% 
   %% 
   meth !Unzoom()
\ifdef DEBUG_BO
      {Show 'BrowserClass::Unzoom is applied'}
\endif 
      case @zoomStack == nil then true 
      else 
	 local NewEl RestEls in 
	    <<Bundraw(@current)>>

	    % 
	    @zoomStack = NewEl|RestEls
	    zoomStack <- RestEls

	    % 
	    case RestEls == nil then 
	       % 
	       case @buttons == InitValue then true 
	       else
		  local Buttons = @buttons in 
		     {Buttons.unzoom state disabled}
		     {Buttons.top state disabled}
		  end 
	       end 

	       % 
	       case @entries == InitValue then true 
	       else
		  local Entries = @entries in 
		     {Entries.unzoom state disabled}
		     {Entries.top state disabled}
		  end 
	       end 
	    else 
	       true 
	    end 

	    % 
	    <<UnsetSelected>>

	    %
	    % relational! 
	    if List in NewEl = a(List) then 
	       case @forward == nil then
		  backward <- nil
		  current <- InitValue
		  <<DrawAll(List)>>
	       else 
		  local NewList in 
		     NewList = {Append List @forward}
		     forward <- nil
		     backward <- nil
		     current <- InitValue

		     % 
		     <<DrawAll(NewList)>>
		  end 
	       end 
	    elseif TermRec NewTermRec in NewEl = s(TermRec) then 
	       <<Bbrowse(TermRec NewTermRec)>>
	       current <- NewTermRec
	    else {BrowserError ['Unknown type of element in zoom stack']}
	    fi
	 end 
      end 
   end 

   %% 
   %% 
   meth !Top()
\ifdef DEBUG_BO
      {Show 'BrowserClass::Top is applied'}
\endif 
      case @zoomStack == nil then true 
      else 
	 local NewEl in 
	    <<Bundraw(@current)>>

	    % 
	    NewEl = {Reverse @zoomStack}.1
	    zoomStack <- nil

	    % 
	    case @buttons == InitValue then true 
	    else
	       local Buttons = @buttons in 
		  {Buttons.unzoom state disabled}
		  {Buttons.top state disabled}
	       end 
	    end 

	    % 
	    case @entries == InitValue then true 
	    else
	       local Entries = @entries in 
		  {Entries.unzoom state disabled}
		  {Entries.top state disabled}
	       end 
	    end 

	    % 
	    <<UnsetSelected>>

	    %
	    % relational! 
	    if List in NewEl = a(List) then 
	       case @forward == nil then
		  backward <- nil
		  current <- InitValue
		  <<DrawAll(List)>>
	       else 
		  local NewList in 
		     NewList = {Append List @forward}
		     forward <- nil
		     backward <- nil
		     current <- InitValue

		     % 
		     <<DrawAll(NewList)>>
		  end 
	       end 
	    elseif TermRec NewTermRec in NewEl = s(TermRec) then 
	       <<Bbrowse(TermRec NewTermRec)>>
	       current <- NewTermRec
	    else {BrowserError ['Unknown type of element in zoom stack']}
	    fi 
	 end 
      end 
   end 

   %% 
   meth first
\ifdef DEBUG_BO
      {Show 'BrowserClass::first is applied'}
\endif 
      % relational!
      case self.IsView then true
      else 
	 %% 
	 case @current == InitValue then true 
	 else 
	    case @showAll then 
	       showAll <- False
	       %%
	       %% relational! 
	       if AllButton in AllButton = {Subtree @buttons all} then
		  {AllButton state normal}
	       else true 
	       fi 
	       if AllEntry in AllEntry = {Subtree @entries all} then 
		  {AllEntry state normal}
	       else true 
	       fi 
	       %%
	       %% 
	       <<UnsetSelected>>
	       %%
	       %% 
	       case @zoomStack == nil then 
		  local ListOf TermRec in 
		     %% 
		     ListOf = {Append {Reverse @current|@backward} @forward}
		     %%
		     %% 
		     <<UndrawAll(@current|@backward)>>
		     %%
		     %% 
		     forward <- ListOf.2
		     backward <- nil
		     <<HistoryButtonsUpdate>>
		     %%
		     %% 
		     <<Bbrowse(ListOf.1 TermRec)>>
		     current <- TermRec
		  end 
	       else 
		  local OList OEl List TermRec in 
		     <<Bundraw(@current)>>
		     %%
		     %% 
		     case @buttons == InitValue then true 
		     else
			local Buttons = @buttons in 
			   {Buttons.unzoom state disabled}
			   {Buttons.top state disabled}
			end 
		     end 
		     case @entries == InitValue then true 
		     else
			local Entries = @entries in 
			   {Entries.unzoom state disabled}
			   {Entries.top state disabled}
			end 
		     end 
		     %%
		     %% 
		     OEl = {Nth @zoomStack {Length @zoomStack}}
		     %%
		     %% relational; 
		     if OEl = a(_) then 
			a(OList) = OEl
		     else {BrowserError ['unknown type of element in zoom stack']}
		     fi 
		     zoomStack <- nil
		     %%
		     %% 
		     List = {Append OList @forward}
		     forward <- List.2
		     backward <- nil
		     <<HistoryButtonsUpdate>>
		     %%
		     %%
		     <<Bbrowse(List.1 TermRec)>>
		     current <- TermRec
		  end 
	       end 
	    else 
	       case @backward == nil then true 
	       else 
		  case @zoomStack == nil then 
		     local TermRec RevBList in 
			<<Bundraw(@current)>>
			%%
			RevBList = {Reverse @backward}
			forward <- {Append RevBList.2 @current|@forward}
			backward <- nil
			%%
			%% 
			<<HistoryButtonsUpdate>>
			%%
			%% 
			<<Bbrowse(RevBList.1 TermRec)>>
			current <- TermRec
		     end 
		  else 
		     local TermRec RevBList OEl BTermRec in 
			<<Bundraw(@current)>>
			%%
			%% 
			case @buttons == InitValue then true 
			else
			   local Buttons = @buttons in 
			      {Buttons.unzoom state disabled}
			      {Buttons.top state disabled}
			   end 
			end 
			case @entries == InitValue then true 
			else
			   local Entries = @entries in 
			      {Entries.unzoom state disabled}
			      {Entries.top state disabled}
			   end 
			end 
			%%
			%% 
			OEl = {Nth @zoomStack {Length @zoomStack}}
			%%
			%% relational; 
			if OEl = s(_) then OEl = s(BTermRec)
			else {BrowserError 
			      ['non-singleton is found in zoom stack by "previous" op']}
			fi 
			zoomStack <- nil
			%%
			RevBList = {Reverse @backward}
			forward <- {Append RevBList.2 BTermRec|@forward}
			backward <- nil
			%%
			%% 
			<<HistoryButtonsUpdate>>
			%%
			%% 
			<<Bbrowse(RevBList.1 TermRec)>>
			current <- TermRec
		     end 
		  end 
	       end 
	    end 
	 end
      end
   end 

   %% 
   meth last
\ifdef DEBUG_BO
      {Show 'BrowserClass::last is applied'}
\endif 
      % relational!
      case self.IsView then true
      else 
	 %% 
	 case @current == InitValue then true 
	 else 
	    case @showAll then 
	       showAll <- False
	       %%
	       %% relational!
	       if AllButton in AllButton = {Subtree @buttons all} then
		  {AllButton state normal}
	       else true 
	       fi 
	       if AllEntry in AllEntry = {Subtree @entries all} then 
		  {AllEntry state normal}
	       else true 
	       fi 
	       %%
	       %% 
	       <<UnsetSelected>>
	       %%
	       %% 
	       case @zoomStack == nil then 
		  local NewListOf TermRec in 
		     %% 
		     NewListOf = {Append {Reverse @forward} @current|@backward}
		     %%
		     %%
		     <<UndrawAll(@current|@backward)>>
		     %%
		     %% 
		     forward <- nil
		     backward <- NewListOf.2
		     <<HistoryButtonsUpdate>>
		     %%
		     %% 
		     <<Bbrowse(NewListOf.1 TermRec)>>
		     current <- TermRec
		  end 
	       else 
		  local OList OEl List TermRec in 
		     <<Bundraw(@current)>>
		     %%
		     %% 
		     case @buttons == InitValue then true 
		     else
			local Buttons = @buttons in 
			   {Buttons.unzoom state disabled}
			   {Buttons.top state disabled}
			end 
		     end 
		     case @entries == InitValue then true 
		     else
			local Entries = @entries in 
			   {Entries.unzoom state disabled}
			   {Entries.top state disabled}
			end 
		     end 
		     %%
		     %% 
		     OEl = {Nth @zoomStack {Length @zoomStack}}
		     %%
		     %% relational; 
		     if OEl = a(_) then a(OList) = OEl
		     else {BrowserError ['unknown type of element in zoom stack']}
		     fi 
		     zoomStack <- nil
		     %%
		     %% 
		     List = {Append {Reverse @forward} {Reverse OList}}
		     forward <- nil
		     backward <- List.2
		     <<HistoryButtonsUpdate>>
		     %%
		     %% 
		     <<Bbrowse(List.1 TermRec)>>
		     current <- TermRec
		  end 
	       end 
	    else 
	       case @forward == nil then true 
	       else 
		  case @zoomStack == nil then 
		     local TermRec RevFList in 
			<<Bundraw(@current)>>
			%%
			RevFList = {Reverse @forward}
			backward <- {Append RevFList.2 @current|@backward}
			forward <- nil
			%%
			%% 
			<<HistoryButtonsUpdate>>
			%%
			%% 
			<<Bbrowse(RevFList.1 TermRec)>>
			current <- TermRec
		     end 
		  else 
		     local TermRec RevFList OEl BTermRec in 
			<<Bundraw(@current)>>
			%%
			%% 
			case @buttons == InitValue then true 
			else
			   local Buttons = @buttons in 
			      {Buttons.unzoom state disabled}
			      {Buttons.top state disabled}
			   end 
			end 
			case @entries == InitValue then true 
			else
			   local Entries = @entries in 
			      {Entries.unzoom state disabled}
			      {Entries.top state disabled}
			   end 
			end 
			%%
			%% 
			OEl = {Nth @zoomStack {Length @zoomStack}}
			%%
			%% relational; 
			if OEl = s(_) then OEl = s(BTermRec)
			else {BrowserError 
			      ['non-singleton is found in zoom stack by "previous" op']}
			fi 
			zoomStack <- nil
			%%
			RevFList = {Reverse @forward}
			backward <- {Append RevFList.2 BTermRec|@backward}
			forward <- nil
			%%
			%% 
			<<HistoryButtonsUpdate>>
			%%
			%% 
			<<Bbrowse(RevFList.1 TermRec)>>
			current <- TermRec
		     end 
		  end 
	       end 
	    end 
	 end
      end
   end 
   %%
   %% 
   meth previous
\ifdef DEBUG_BO
      {Show 'BrowserClass::previous is applied'}
\endif 
      % relational!
      case self.IsView then true
      else
	 %%
	 case @current == InitValue then true 
	 else 
	    %% 
	    <<UnsetSelected>>
	    %%
	    case @showAll then true 
	    else 
	       case @backward == nil then true 
	       else 
		  case @zoomStack == nil then 
		     local TermRec NewTermRec in 
			<<Bundraw(@current)>>
			%%
			TermRec = @backward.1
			backward <- @backward.2
			forward <- @current|@forward
			%%
			%% 
			<<HistoryButtonsUpdate>>
			<<Bbrowse(TermRec NewTermRec)>>
			current <- NewTermRec
		     end 
		  else 
		     local OEl BTermRec TermRec NewTermRec List in
			<<Bundraw(@current)>>
			%%
			%% 
			case @buttons == InitValue then true 
			else 
			   local Buttons = @buttons in 
			      {Buttons.unzoom state disabled}
			      {Buttons.top state disabled}
			   end 
			end 
			case @entries == InitValue then true 
			else
			   local Entries = @entries in 
			      {Entries.unzoom state disabled}
			      {Entries.top state disabled}
			   end 
			end 
			%%
			%% 
			OEl = {Nth @zoomStack {Length @zoomStack}}
			%%
			%% relational; 
			if OEl = s(_) then OEl = s(BTermRec)
			else {BrowserError 
			      ['non-singleton is found in zoom stack by "previous" op']}
			fi 
			zoomStack <- nil
			%%
			TermRec = @backward.1
			backward <- @backward.2
			forward <- BTermRec|@forward
			%%
			%% 
			<<HistoryButtonsUpdate>>
			<<Bbrowse(TermRec NewTermRec)>>
			current <- NewTermRec
		     end 
		  end 
	       end 
	    end 
	 end
      end
   end 
   %%
   %% 
   meth next
\ifdef DEBUG_BO
      {Show 'BrowserClass::next is applied'}
\endif 
      %%
      case self.IsView then true
      else
	 %%
	 case @current == InitValue then true 
	 else 
	    %% 
	    <<UnsetSelected>>
	    %%
	    case @showAll then true 
	    else 
	       case @forward == nil then true 
	       else 
		  case @zoomStack == nil then 
		     local TermRec NewTermRec in 
			<<Bundraw(@current)>>
			%%
			TermRec = @forward.1
			forward <- @forward.2
			backward <- @current|@backward
			%%
			%% 
			<<HistoryButtonsUpdate>>
			<<Bbrowse(TermRec NewTermRec)>>
			current <- NewTermRec
		     end 
		  else 
		     local OEl BTermRec TermRec NewTermRec List in
			<<Bundraw(@current)>>
			%%
			%% 
			case @buttons == InitValue then true 
			else
			   local Buttons = @buttons in 
			      {Buttons.unzoom state disabled}
			      {Buttons.top state disabled}
			   end 
			end 
			case @entries == InitValue then true 
			else 
			   local Entries = @entries in 
			      {Entries.unzoom state disabled}
			      {Entries.top state disabled}
			   end 
			end 
			%%
			%% 
			OEl = {Nth @zoomStack {Length @zoomStack}}
			%%
			%% relational; 
			if OEl = s(_) then OEl = s(BTermRec)
			else {BrowserError 
			      ['non-singleton is found in zoom stack by "previous" op']}
			fi 
			zoomStack <- nil
			%%
			TermRec = @forward.1
			forward <- @forward.2
			backward <- BTermRec|@backward
			%%
			%%
			<<HistoryButtonsUpdate>>
			<<Bbrowse(TermRec NewTermRec)>>
			current <- NewTermRec
		     end 
		  end 
	       end 
	    end 
	 end
      end
   end 
   %%
   %% 
   meth all
\ifdef DEBUG_BO
      {Show 'BrowserClass::all is applied'}
\endif
      %%
      case self.IsView then true
      else 
	 case @current == InitValue then true 
	 else
	    case @showAll then 
	       {BrowserError ['trying to switch to "all" mode second time']}
	    else 
	       local ListOf in 
		  %%
		  <<UnsetSelected>>
		  %%
		  showAll <- True
		  case @buttons == InitValue then true
		  else
		     local Buttons = @buttons in 
			{Buttons.first state normal}
			{Buttons.last state normal}
			{Buttons.previous state disabled}
			{Buttons.next state disabled}
			{Buttons.all state disabled}
		     end 
		  end 
		  case @entries == InitValue then true
		  else
		     local Entries = @entries in 
			{Entries.first state normal}
			{Entries.last state normal}
			{Entries.previous state disabled}
			{Entries.next state disabled}
			{Entries.all state disabled}
		     end
		  end 
		  %%
		  %% 
		  <<Bundraw(@current)>>
		  case @zoomStack == nil then 
		     ListOf = {Append {Reverse @current|@backward} @forward}
		  else 
		     local OEl BTermRec in 
			%% 
			case @buttons == InitValue then true 
			else
			   local Buttons = @buttons in 
			      {Buttons.unzoom state disabled}
			      {Buttons.top state disabled}
			   end 
			end 
			case @entries == InitValue then true 
			else
			   local Entries = @entries in 
			      {Entries.unzoom state disabled}
			      {Entries.top state disabled}
			   end 
			end 
			%%
			%% 
			OEl = {Nth @zoomStack {Length @zoomStack}}
			%%
			%% relational; 
			if OEl = s(_) then OEl = s(BTermRec)
			else {BrowserError 
			      ['non-singleton is found in zoom stack by "previous" op']}
			fi 
			zoomStack <- nil
			%%
			%% 
			ListOf = {Append {Reverse BTermRec|@backward} @forward}
		     end 
		  end 
		  %%
		  %%
		  backward <- nil
		  current <- InitValue
		  <<DrawAll(ListOf)>>
	       end
	    end 
	 end
      end
   end 

   %%
   %% 
   meth equate(Term)
\ifdef DEBUG_BO
      {Show 'BrowserClass::equate is applied'#Term}
\endif
      local ArityType in
	 ArityType = {@store read(StoreArityType $)}

	 %
	 case ArityType == AtomicArity then 
	    case @selected == InitValue then true 
	    else @selected.term = Term
	    end
	 else
	    {BrowserWarning ['cannot equate: the private fields are shown']}
	 end
      end
   end

   %% 
   meth !Help()
\ifdef DEBUG_BO
      {Show 'BrowserClass::Help is applied'}
\endif 
      local HF Desc HelpWindow in
	 HF = {New Open.file init(name: IHelpFile flags: [read])}
	 %%
	 Desc = {HF [read(list: $ size: all) close]}
	 %%
	 %%
	 HelpWindow = {New ProtoHelpWindow
		       createHelpWindow(screen: {@store read(StoreScreen $)})}
	 %%
	 %%
	 case {VirtualString.is Desc} then 
	    %% 
	    {HelpWindow showIn(Desc)}
	 else
	    {BrowserError ['Falsen-virtual-string is read from a help.txt file?']}
	 end
      end
   end

   %% 
   %% 	 
   meth !ClearHistory()
\ifdef DEBUG_BO
      {Show 'BrowserClass::ClearHistory is applied'}
\endif 
      case @backward == nil then true
      else
	 case @showAll then <<UndrawAll(@backward)>>
	 else true
	 end 

	 % 
	 backward <- nil
	 <<HistoryButtonsUpdate>>
      end 
   end

   %% 
   %% 
   meth !HistoryButtonsUpdate()
\ifdef DEBUG_BO
      {Show 'BrowserClass::HistoryButtonsUpdate is applied'}
\endif
      case @current == InitValue then
	 case @buttons == InitValue then true
	 else
	    local Buttons = @buttons in 
	       {Buttons.first state disabled}
	       {Buttons.last state disabled}
	       {Buttons.previous state disabled}
	       {Buttons.next state disabled}
	       {Buttons.all state disabled}
	    end 
	 end 
	 case @entries == InitValue then true
	 else
	    local Entries = @entries in 
	       {Entries.first state disabled}
	       {Entries.last state disabled}
	       {Entries.previous state disabled}
	       {Entries.next state disabled}
	       {Entries.all state disabled}
	    end
	 end 
      else 	 
	 case @showAll then 
	    case @buttons == InitValue then true
	    else
	       local Buttons = @buttons in 
		  {Buttons.first state normal}
		  {Buttons.last state normal}
		  {Buttons.previous state disabled}
		  {Buttons.next state disabled}
		  {Buttons.all state disabled}
	       end 
	    end 
	    case @entries == InitValue then true
	    else
	       local Entries = @entries in 
		  {Entries.first state normal}
		  {Entries.last state normal}
		  {Entries.previous state disabled}
		  {Entries.next state disabled}
		  {Entries.all state disabled}
	       end
	    end 
	 else 
	    case @forward == nil then
	       % relational; 
	       if Next Last in 
		  Next = {Subtree @entries next}
		  Last = {Subtree @entries last} then 
		  {Next state disabled}
		  {Last state disabled}
	       else true 
	       fi
	       % relational; 
	       if Next Last in 
		  Next = {Subtree @buttons next}
		  Last = {Subtree @buttons last} then 
		  {Next state disabled}
		  {Last state disabled}
	       else true 
	       fi 
	    else
	       % relational; 
	       if Next Last in 
		  Next = {Subtree @entries next}
		  Last = {Subtree @entries last} then 
		  {Next state normal}
		  {Last state normal}
	       else true 
	       fi
	       % relational; 
	       if Next Last in 
		  Next = {Subtree @buttons next}
		  Last = {Subtree @buttons last} then 
		  {Next state normal}
		  {Last state normal}
	       else true 
	       fi 
	    end 
	    
	    % 
	    case @backward == nil then
	       % relational; 
	       if Previous First in 
		  Previous = {Subtree @entries previous} 
		  First = {Subtree @entries first} then 
		  {Previous state disabled}
		  {First state disabled}
	       else true 
	       fi
	       % relational; 
	       if Previous First in 
		  Previous = {Subtree @buttons previous}
		  First = {Subtree @buttons first} then 
		  {Previous state disabled}
		  {First state disabled}
	       else true 
	       fi 
	    else
	       % relational; 
	       if Previous First in 
		  Previous = {Subtree @entries previous}
		  First = {Subtree @entries first} then 
		  {Previous state normal}
		  {First state normal}
	       else true 
	       fi
	       % relational; 
	       if Previous First in 
		  Previous = {Subtree @buttons previous} 
		  First = {Subtree @buttons first} then 
		  {Previous state normal}
		  {First state normal}
	       else true 
	       fi 
	    end
	 end
      end 
   end 

end 

