%%%
%%% Author:
%%%   Benjamin Lorenz <lorenz@ps.uni-sb.de>
%%%
%%% Copyright:
%%%   Benjamin Lorenz, 1997
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

local

   MessageWidth = 380
   HelpTitle    = 'Ozcar Help'
   OkButtonText = 'Ok'
   NoTopic      = 'No Help Available'
   NoHelp       = ('Feel free to ask the author.\n' #
		   'Send a mail to ' # EmailOfBenni)

   HelpDict     = {Dictionary.new}

   {ForAll
    [
     nil #
     ('The Ozcar Help System' #
      ('Information about important topics can be found' #
      ' in the Help menu you' #
       ' just activated. Furthermore, there\'s some help' #
       ' available for most of the widgets in the GUI; just click' #
       ' with the right mouse button over them.'))

     StatusHelp #
     ('The Status Line' #
      ('Important events like reaching a breakpoint or raising ' #
       'an exception are reported here.'))

     AddQueriesBitmap #
     ('Attach Queries' #
      ('Deactivate this checkbutton if you want to feed some code ' #
       'from Emacs without Ozcar taking over control.'))

     AddSubThreadsBitmap #
     ('Attach Subthreads' #
      ('Deactivate this checkbutton if you don\'t want Ozcar ' #
       'to attach any subthreads of your initial query thread.'))

     ValuesHelp #
     ('Access to Values' #
      ('All bold printed Oz values in the stack and the environment' #
       ' windows can be examined by clicking' #
       ' on them. This will activate the Browser. Moreover, by feeding' #
       ' the expression' #
       '\n\n    {Ozcar lastClickedValue($)},' #
       '\n\n you get access to the last clicked value from the OPI.'))

     BreakpointStaticHelp #
     ('Static Breakpoints' #
      ('You can set a static breakpoint by inserting' #
       '\n\n    {Debug.breakpoint}\n\ninto ' #
       'your code, just before the line where you want ' #
       'the thread to stop.' #
       '\n\nYou probably have to load the Debug module first:' #
       '\n\n    declare [Debug] = {Module.link [\'x-oz://boot/Debug\']}\n'))

     BreakpointDynamicHelp #
     ('Dynamic Breakpoints' #
      ('You can set a dynamic breakpoint at the current line of ' #
       'an Emacs buffer by entering (in Emacs)\n\n' #
       '    C-x SPC.\n\n ' #
       'To delete a breakpoint, use\n\n' #
       '    C-0 C-x SPC\n\n' #
       'Alternatively, click with the left / right mouse button ' #
       'on the line where you wish to set / delete a breakpoint, while ' #
       'holding down the `Shift\' and `Meta\' keys.'))

     TreeTitle #
     ('The Thread Tree' #
      ('Threads are added to the tree when they run into a breakpoint ' #
       'or when they are created by Emacs queries and the ' #
       '\'Attach\' entry in the \'Queries\' popup menu is selected. ' #
       '\n\nYou can select a thread by clicking on it or by walking ' #
       'to it with the `Left\' and `Right\' (cursor) keys.\n' #
       '\nThe different colors correspond to the ' #
       'following thread states:\n' #
       'green: runnable, yellow: blocked, red: exception, grey: terminated\n' #
       '\nA thread can be removed from the tree either by ' #
       'killing it (action `terminate\') or by detaching it ' #
       '(action `detach\').'))

     StackTitle #
     ('The Stack' #
      ('You can navigate through the stack either by clicking on a ' #
       'specific line or by using the `Up\' and `Down\' (cursor) keys.\n' #
       '\nYou can browse a variable by clicking ' #
       'on its type information.'))

     LocalEnvTitle #
     ('The Local Environment' #
      ('You can browse a local variable by clicking ' #
       'on its type information.'))

     GlobalEnvTitle #
     ('The Global Environment' #
      ('You can browse a global variable by clicking ' #
       'on its type information.'))

     StepButtonBitmap #
     ('Step Into' #
      ('Let the current thread continue to run until ' #
       'it reaches the next steppoint.'))

     NextButtonBitmap #
     ('Step Over' #
      ('Let the current thread continue to run until ' #
       'it reaches the next steppoint in the current stack frame.'))

     UnleashButtonBitmap #
     ('Unleash' #
      ('Let the current thread continue to run until ' #
       'the selected stack frame is discarded or the thread blocks, ' #
       'reaches a breakpoint or raises an unhandled exception.'))

     StopButtonBitmap #
     ('Stop' #
      ('Stop the current thread as soon as it reaches the next ' #
       'steppoint. Note that blocked threads need to be stopped ' #
       'in order to get updated stack and environment windows.'))

     DetachButtonBitmap #
     ('Detach' #
      ('Do not trace the current thread anymore, let it ' #
       'continue to run, and remove it ' #
       'from the thread tree. It will come back when it reaches ' #
       'a breakpoint or raises an unhandled exception.'))

     TermButtonBitmap #
     ('Terminate' #
      ('Terminate current thread and detach it.'))

    ]
    proc {$ S}
       {Dictionary.put HelpDict S.1 S.2}
    end}

   class HelpDialog from TkTools.dialog
      feat
	 topic help
      meth init(master:Master)
	 TkTools.dialog,tkInit(master:  Master
			       root:    master # 143 # 77
			       title:   HelpTitle % self.topic
			       buttons: [OkButtonText # tkClose]
			       bg:      DefaultBackground
			       pack:    false
			       default: 1)
	 Title = {New Tk.label tkInit(parent: self
				      bg:     DefaultBackground
				      text:   self.topic
				      font:   HelpTitleFont)}
	 Help = {New Tk.message
		 tkInit(parent: self
			font:   HelpFont
			bg:     DefaultBackground
			width:  MessageWidth
			text:   self.help)}
      in
	 {Tk.send pack(Title Help side:top expand:1 pady:3 fill:x)}
	 HelpDialog,tkPack
      end
   end

   class OzcarHelp from HelpDialog
      meth init(master:Master topic:Topic)
	 self.topic # self.help =
	 {Dictionary.condGet HelpDict Topic NoTopic # NoHelp}
	 HelpDialog,init(master:Master)
      end
   end

in

   class Help

      meth help(Topic)
	 {Wait {New OzcarHelp init(master:self.toplevel topic:Topic)}.tkClosed}
      end

   end
end
