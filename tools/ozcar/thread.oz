%%% $Id$
%%% Benjamin Lorenz <lorenz@ps.uni-sb.de>

local

   proc {ReadLoop S}
      case S
      of H|T then
	 {OzcarMessage 'readloop:'} {OzcarShow H}
	 {Ozcar readStreamMessage(H)}
	 {ReadLoop T}
      end
   end

in
   
   class ThreadManager
      feat
	 Stream                %% info stream of the emulator
	 ThreadDic             %% dictionary that holds various information
                               %% about debugged threads
	 ReadLoopThread        %% we need to kill it when closing the manager

      attr
	 currentThread : undef
	 SkippedProcs  : nil
	 SkippedThread : nil
      
      meth init
	 self.Stream    = {Dbg.stream}
	 self.ThreadDic = {Dictionary.new}
	 thread
	    self.ReadLoopThread = {Thread.this}
	    {ReadLoop self.Stream}
	 end
      end

      meth getCurrentThread($)
	 @currentThread
      end
      
      meth getThreadDic($)
	 self.ThreadDic
      end
      
      meth readStreamMessage(M)
	 case {Label M}
	    
	 of step then
	    T          = M.thr.1
	    I          = M.thr.2
	    File       = M.file
	    Line       = M.line
	    IsBuiltin  = M.builtin
	    Time       = M.time
	    FrameId    = M.frame
	    Name = case {Value.hasFeature M name} then M.name else nil end
	    Args = case {Value.hasFeature M args} then M.args else nil end
	 in
	    case {Thread.is T} then
	       Ok =
	       ({Cget stepRecordBuiltin}  orelse Name \= 'record')
	       andthen
	       ({Cget stepDotBuiltin}     orelse Name \= '.')
	       andthen
	       ({Cget stepWidthBuiltin}   orelse Name \= 'Width')
	       andthen
	       ({Cget stepNewNameBuiltin} orelse Name \= 'NewName')
	       andthen
	       ({Cget stepSetSelfBuiltin} orelse Name \= 'setSelf')
	       andthen
	       ({Cget stepSystemProcedures} orelse
		Name == ''       orelse
		Name == '`,`'    orelse
		Name == '`send`' orelse
		{Atom.toString Name}.1 \= 96)
	    in
	       case Ok then
		  case {Dmember self.ThreadDic I} then skip else
		     {OzcarMessage WaitForThread}
		     {Delay 700} % thread should soon be added
		  end
		  ThreadManager,step(file:File line:Line thr:T id:I
				     name:Name args:Args frame:FrameId
				     builtin:IsBuiltin time:Time)
	       else
		  SkippedProcs <- FrameId # I | @SkippedProcs
		  {OzcarMessage 'Skipping procedure \'' # Name # '\''}
		  {OzcarShow @SkippedProcs}
		  {Thread.resume T}
	       end
	    else
	       {OzcarMessage InvalidThreadID}
	    end

	 [] exit then
	    T       = M.thr.1
	    I       = M.thr.2
	    Frame   = M.frame
	    Found   = {Member Frame.1 # I @SkippedProcs}
	 in
	    {OzcarShow @SkippedProcs # (Frame.1 # I) # Found}
	    case Found orelse @SkippedThread == T then
	       {OzcarMessage 'ignoring exit message'}
	       SkippedProcs  <- {Filter @SkippedProcs
				 fun {$ F} F \= Frame.1 # I end}
	       SkippedThread <- nil
	       {Thread.resume T}
	    else
	       Ack F L
	       Stack   = {Dget self.ThreadDic I}
	    in
	       {ForAll [exit(Frame) getPos(file:F line:L)] Stack}
	       SourceManager,scrollbar(file:'' line:0 color:undef what:stack)
	       thread
		  SourceManager,scrollbar(file:F line:L ack:Ack
					  color:ScrollbarApplColor what:appl)
	       end
	       thread Gui,loadStatus(F Ack) end
	       thread {Stack printTop} end
	    end
	    
	 [] thr then
	    T = M.thr.1
	    I = M.thr.2
	    Q = case {Value.hasFeature M par} then
		   M.par.2  %% id of parent thread
		else
		   0        %% parent unknown (threads of tk actions...)
		end
	    E = {Ozcar exists(I $)}
	 in
	    case E then
	       Stack = {Dget self.ThreadDic I}
	    in
	       {OzcarMessage KnownThread # {ID I}}
	       {Stack rebuild(true)}
	    else
	       {OzcarMessage NewThread   # {ID I}}
	       case Q == 1 andthen      %% toplevel query?
		  {self.tkRunChildren tkReturnInt($)} == 0 then
		  {OzcarMessage 'child of root thread will do one step'}
		  thread
		     SkippedThread <- T %% yes, so we want T to make
		     {Thread.resume T}  %% the first step automatically
		     {Delay 500}        %% short living threads which produce
		                        %% no step messages are uninteresting
		     SkippedThread <- nil
		     case
			{Thread.state T} == terminated then
			{OzcarMessage EarlyThreadDeath}
		     else
			ThreadManager,add(T I Q)
		     end
		  end
	       else
		  ThreadManager,add(T I Q)
	       end
	    end
	    
	 [] term then
	    T = M.thr.1  %% just terminated thread
	    I = M.thr.2  %% ...with it's id
	    E = {Ozcar exists(I $)}
	 in
	    case E then
	       ThreadManager,remove(T I noKill)
	    else
	       %{OzcarMessage UnknownTermThread}
	       skip
	    end
	    
	 [] block then
	    T    = M.thr.1  %% just blocking thread
	    I    = M.thr.2  %% ...with it's id
	    F    = M.file
	    L    = M.line
	    N    = M.name
	    A    = M.args
	    B    = M.builtin
	    Time = M.time
	    E = {Ozcar exists(I $)}
	 in
	    case E then
	       ThreadManager,block(thr:T id:I file:F line:L name:N args:A
				   builtin:B time:Time)
	    else
	       {OzcarMessage UnknownSuspThread}
	    end
	    
	 [] cont then
	    T = M.thr.1  %% woken thread
	    I = M.thr.2  %% ...with it's id
	    E = {Ozcar exists(I $)}
	 in
	    case E then
	       case T == @currentThread andthen
		  {self.tkRunChildren tkReturnInt($)} == 0 then
		  Gui,status(I runnable)
	       else skip end
	       Gui,markNode(I runnable)
	    else
	       {OzcarMessage UnknownWokenThread}
	    end
	    
	 else
	    {OzcarMessage UnknownMessage}
	 end
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      meth exists(I $)
	 {Dmember self.ThreadDic I}
      end

      meth removeSkippedProcs(I)
	 %{OzcarMessage 'removing all skipped procedures for thread #' # I}
	 %{OzcarShow 'before:' # @SkippedProcs}
	 SkippedProcs <- {Filter @SkippedProcs
			  fun {$ F} F.2 \= I end}
	 %{OzcarShow 'after :' # @SkippedProcs}
      end
      
      meth add(T I Q)
	 {Dput self.ThreadDic I {New StackManager init(thr:T id:I)}}
	 Gui,addNode(I Q)
	 case Q == 0 orelse Q == 1 then 
	    ThreadManager,switch(I)       %% does Gui,displayTree
	 else
	    Gui,displayTree
	 end
      end

      meth remove(T I Mode)
	 {OzcarMessage 'removing thread #' # I # ' with mode ' # Mode}
	 ThreadManager,removeSkippedProcs(I)
	 case Mode == kill then
	    Gui,killNode(I)
	    {Dremove self.ThreadDic I}
	 else
	    Gui,removeNode(I)
	 end
	 case T == @currentThread then
	    SourceManager,scrollbar(file:'' line:undef color:undef what:both)
	    case Mode == kill then
	       currentThread <- undef
	       Gui,status(0)
	    else
	       Gui,status(I terminated)
	    end
	    Gui,printStack(id:I frames:nil depth:0)
	 else skip end
	 case {Dkeys self.ThreadDic} == nil then
	    {OzcarMessage 'no more threads to debug.'}
	    currentThread <- undef
	    Gui,status(0)
	    Gui,selectNode(0)
	    Gui,displayTree
	 else skip end
      end

      meth kill(T I)
	 {Dbg.trace T false}
	 {Thread.terminate T}
	 ThreadManager,remove(T I kill)
      end

      meth killAll
	 E = {Ditems self.ThreadDic}
      in
	 {ForAll E
	  proc {$ S}
	     I = {S getId($)}
	     T = {S getThread($)}
	  in
	     ThreadManager,kill(T I)
	  end}
      end
      
      meth forget(T I)
	 {Dbg.trace T false}      %% thread is not traced anymore
	 {Dbg.stepmode T false}   %% no step mode, run as you like!
	 {Thread.resume T}        %% run, run to freedom!! :-)
	 ThreadManager,remove(T I kill)
      end

      meth step(file:F line:L thr:T id:I name:N args:A
		builtin:B time:Time frame:FrameId)
	 Stack = {Dget self.ThreadDic I}
      in
	 {Stack step(name:N args:A builtin:B file:F line:L
		     time:Time frame:FrameId)}
	 case T == @currentThread then
	    case {UnknownFile F} then
	       {OzcarMessage NoFileInfo # I}
	       SourceManager,scrollbar(file:'' line:0 color:undef what:both)
	       case F == '' andthen A.1 == off then
	          % should(!) only happen when sending
                  % Ozcar the 'off' message from within Emacs
		  {OzcarMessage ByeBye}
		  ThreadManager,forget(T I)
	       else
		  {Thread.resume T}
	       end
	    else Ack in
	       SourceManager,scrollbar(file:'' line:0 color:undef what:stack)
	       thread
		  SourceManager,scrollbar(file:F line:L ack:Ack
					  color:ScrollbarApplColor what:appl)
	       end
	       thread Gui,loadStatus(F Ack) end
	       thread {Stack printTop} end
	    end
	 else skip end
      end

      meth block(thr:T id:I file:F line:L name:N args:A builtin:B time:Time)
	 Stack = {Dget self.ThreadDic I}
      in
	 {Stack rebuild(true)}
	 Gui,markNode(I blocked)
	 case T == @currentThread andthen
	    {self.tkRunChildren tkReturnInt($)} == 0 then
	    Gui,status(I blocked)
	    case {UnknownFile F} then
	       {OzcarMessage 'Thread #' # I # NoFileBlockInfo}
	       SourceManager,scrollbar(file:'' line:0 color:undef what:both)
	    else Ack in
	       SourceManager,scrollbar(file:'' line:0 color:undef what:stack)
	       thread
		  SourceManager,scrollbar(file:F line:L ack:Ack
					  color:ScrollbarBlockedColor
					  what:appl)
	       end
	       thread Gui,loadStatus(F Ack) end
	    end
	    thread {Stack printTop} end
	 else skip end
      end
      
      meth switch(I)
	 F L N A B Time
      in
	 case I == 1 then
	    Gui,status(0)
	 else
	    Stack = {Dget self.ThreadDic I}
	    T     = {Stack getThread($)}
	    S     = {Thread.state T}
	 in
	    currentThread <- T
	    
	    Gui,status(I S)
	    Gui,selectNode(I)
	    Gui,displayTree
	    
	    case S == terminated then
	       SourceManager,scrollbar(file:'' line:0 color:undef what:appl)
	       Gui,printStack(id:I frames:nil depth:0)
	    else Ack in
	       {ForAll [print getPos(file:F line:L)] Stack}
	       thread
		  SourceManager,
		  scrollbar(file:F line:L ack:Ack
			    color:
			       case S
			       of runnable then ScrollbarApplColor
			       [] blocked  then ScrollbarBlockedColor
			       end
			    what:appl)
	       end
	       thread Gui,loadStatus(F Ack) end
	    end
	    SourceManager,scrollbar(file:'' line:0 color:undef what:stack)
	 end
      end

      meth suspend(TkV)
	 Value = {TkV tkReturnInt($)}
	 Arg   = case Value == 0 then false else true end
      in
	 {OzcarMessage 'Dbg.suspend called with argument ' # Value}
	 {Dbg.suspend Arg}
      end

      meth runChildren(TkV)
	 Value = {TkV tkReturnInt($)}
	 Arg   = case Value == 0 then false else true end
      in
	 {OzcarMessage 'Dbg.runChildren called with argument ' # Value}
	 {Dbg.runChildren Arg}
      end
      
      meth close
	 skip
      end
      
   end
end
