%%% $Id$
%%% Benjamin Lorenz <lorenz@ps.uni-sb.de>

local
   
   TkVerbose             = {New Tk.variable tkInit(ConfigVerbose)}
   
   TkStepSystemProcedures= {New Tk.variable tkInit(ConfigStepSystemProcedures)}
   TkStepRecordBuiltin   = {New Tk.variable tkInit(ConfigStepRecordBuiltin)}
   TkStepDotBuiltin      = {New Tk.variable tkInit(ConfigStepDotBuiltin)}
   TkStepWidthBuiltin    = {New Tk.variable tkInit(ConfigStepWidthBuiltin)}
   TkStepNewNameBuiltin  = {New Tk.variable tkInit(ConfigStepNewNameBuiltin)}
   TkStepSetSelfBuiltin  = {New Tk.variable tkInit(ConfigStepSetSelfBuiltin)}
   
   TkEnvSystemVariables  = {New Tk.variable tkInit(ConfigEnvSystemVariables)}
   TkEnvProcedures       = {New Tk.variable tkInit(ConfigEnvProcedures)}

   TkScrollbar           = {New Tk.variable
			    tkInit(case ConfigScrollbar == emacsScrollbar
				   then false else true end)}
   
   C  = command
   MB = menubutton
   CB = checkbutton
   CC = cascade
   
in
   
   class Menu
      meth init
	 self.menuBar = 
	 {TkTools.menubar self.toplevel self.toplevel
	  [MB(text: 'Ozcar'
	      menu:
		 [C(label:   'About...'
		    action:  self # about
		    key:     ctrl(i))
		  separator
		  C(label:   'Status'
		    action:  self # checkMe
		    key:     ctrl(s))
		  C(label:   'Reset'
		    action:  self # action(' reset')
		    key:     ctrl(r))
		  separator
		  C(label:   'Close'
		    action:  self # off
		    key:     ctrl(x))]
	      feature: ozcar)
	   MB(text: 'Thread'
	      menu:
		 [C(label:  'Step'
		    action: self # action(' step')
		    key:    s)
		  C(label:  'Next'
		    action: self # action(' next')
		    key:    n)
		  C(label:  'Continue'
		    action: self # action(' cont')
		    key:    c)
		  C(label:  'Forget'
		    action: self # action(' forget')
		    key:    f)
		  C(label:  'Terminate'
		    action: self # action(' term')
		    key:    t)]
	      feature: thr)
	   MB(text: 'Stack'
	      menu:
		 [C(label:  'Previous Frame'
		    action: self # neighbourStackFrame(~1)
		    key:    'Up'
		    event:  '<Up>')
		  C(label:  'Next Frame'
		    action: self # neighbourStackFrame(1)
		    key:    'Down'
		    event:  '<Down>')
		  separator
		  C(label:  'Re-Calculate'
		    action: self # rebuildCurrentStack
		    key:    ctrl(l))
		  C(label:  'Browse'
		    action: self # action(' stack')
		    key:    ctrl(b))]
	      feature: stack)
	   MB(text: 'Options'
	      menu:
		 [CB(label:    'Use Oz Source Window'
		     variable: TkScrollbar
		     action:   Config # toggleScrollbar)
		  CB(label:    'Step on All System Procedures'
		     variable: TkStepSystemProcedures
		     action:   Config # toggle(stepSystemProcedures)
		     feature:  stepSystemProcedures)
		  CC(label:    'Step on Builtin'
		     menu:
			[CB(label:    '\'record\''
			    variable: TkStepRecordBuiltin
			    action:   Config # toggle(stepRecordBuiltin)
			    feature:  stepRecordBuiltin)
			 CB(label:    '\'.\''
			    variable: TkStepDotBuiltin
			    action:   Config # toggle(stepDotBuiltin)
			    feature:  stepDotBuiltin)
			 CB(label:    '\'width\''
			    variable: TkStepWidthBuiltin
			    action:   Config # toggle(stepWidthBuiltin)
			    feature:  stepWidthBuiltin)
			 CB(label:    '\'NewName\''
			    variable: TkStepNewNameBuiltin
			    action:   Config # toggle(stepNewNameBuiltin)
			    feature:  stepNewNameBuiltin)
			 CB(label:    '\'setSelf\''
			    variable: TkStepSetSelfBuiltin
			    action:   Config # toggle(stepSetSelfBuiltin)
			    feature:  stepSetSelfBuiltin)]
		     feature:  stepOnBuiltin)
		  separator
		  CB(label:   'Filter System Variables'
		     variable: TkEnvSystemVariables
		     action:   Config # toggle(envSystemVariables)
		     feature:  envSystemVariables)
		  CB(label:   'Filter Procedures'
		     variable: TkEnvProcedures
		     action:   Config # toggle(envProcedures)
		     feature:  envProcedures)
		  separator
		  CB(label:   'Messages in Emulator Buffer'
		     variable: TkVerbose
		     action:   Config # toggle(verbose)
		     feature:  verbose)]
	      feature: options)]
	  [MB(text: 'Help'
	      menu:
		 [C(label:   'Thread Tree'
		    state:   disabled)
		  C(label:   'Stack'
		    state:   disabled)
		  C(label:   'Environment'
		    state:   disabled)
		  CC(label:  'Breakpoints'
		     menu:
			[C(label:  'static'
			   action: self # helpBreakpointStatic)
			 C(label:  'dynamic'
			   action: self # helpBreakpointDynamic)]
		     feature: breakpoints)]
	      feature: help)
	  ]}

	 {ForAll [self.menuBar.ozcar.menu
		  self.menuBar.thr.menu
		  self.menuBar.stack.menu
		  self.menuBar.help.menu
		  self.menuBar.help.breakpoints.menu]
	  proc {$ M} {M tk(conf tearoff:false)} end}

	 {self.menuBar tk(conf borderwidth:1)}
      end
   end
end
