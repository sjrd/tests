functor
export
   AdvancedListBox      
import
   Tk
define
   class AdvancedListBox  from Tk.frame
      prop
	 final locking
      feat
	 listbox
	 InternalHelpFun1
	 entryDict
	 entryTag
      attr
	 cy:1
	 width:30*8
	 height:17*8
	 action:proc{$ _} skip end
	 lineSize:14
	 nextFree:[0]
      meth tkInit(...)=M
	 LB SY
      in
	 Tk.frame, M
	 self.entryDict = {NewDictionary}
	 self.listbox=LB={New Tk.canvas tkInit(parent:self
					       bd:2
					       relief:sunken
					       bg:white
					       width:@width
					       height:@height)}
	 self.entryTag = {New Tk.canvasTag tkInit(parent:self.listbox)}
	 {self.listbox tkBind(event:'<1>' args: [ int(y)]
			      action: proc{$  CY}
					 Y={self.listbox tkReturnInt(canvasy CY $)}
					 Line
					 Found
				      in
					 Line = (Y -5)  div @lineSize
					 Found = {Filter {Dictionary.items self.entryDict}
						  fun{$ E}
						     E.line == Line
						  end}
					 case Found of [E] then
					    {self Action(E.key)}
					 else skip end 
				      end)}
	 
	 
	 SY={New Tk.scrollbar tkInit(parent:self
				     width:8)}
	 {Tk.addYScrollbar LB SY}
	 {Tk.batch [grid(LB row:0 column:0 sticky:news)
		    grid(SY row:0 column:1 sticky:ns)
		    grid(columnconfigure self 0 weight:1)
		    grid(rowconfigure self 0 weight:1)]}
      end
   
      meth getEntry($)
	 case @nextFree of
	    [A] then
	    nextFree <- [A+1]
	    A
	 elseof A|R then
	    nextFree <- R
	    A
	 end
      end
      
      meth putEntry(E)
	 nextFree <- E|@nextFree
      end
      
      meth setAction(P)
	 action<-P
      end

      meth Action(A)
	 {@action A}
      end
   
      meth addSite(Ks)
	 DC = self.listbox
	 
	 R = {Map Ks fun{$ K}
			Line = {self getEntry($)}
			S=site(text:K.text
			       key:K.key
			       fg:{CondSelect K fg black}
			       bg:{CondSelect K bg white}
			       line: Line 
			       fgtag:{New Tk.canvasTag tkInit(parent:DC)})
		     in
			self.entryDict.(K.key):=S
			S
		     end}
      in
	 if Ks \= nil then 
	    {self Draw(R)}
	 end
      end
      
      meth deleteSite(Ks)
	 {ForAll Ks proc{$ K}
		       if {Dictionary.member self.entryDict K} then
			  E = self.entryDict.K in
			  {E.fgtag tk(delete)}
			  {self putEntry(E.line)}
			  {Dictionary.remove self.entryDict K} 
		       end
		    end}
      end

      meth updateEntry(K T)
	 if {Dictionary.member self.entryDict K} then
	    E = self.entryDict.K in
	    {self.listbox tk(itemconfig E.fgtag text:T)}
	 end
      end
      
      meth Draw(Ss)
	 DC=self.listbox
	 Y1
      in
	 {ForAll Ss proc{$ X}
		       {DC tk(crea text 5 X.line * @lineSize + 5 
			      text:X.text anchor:nw fill:X.fg tags:X.fgtag)}
		    end}
	 Y1 = (({List.sort  @nextFree Value.'>'}.1)  +1) *  @lineSize 
	 {self.listbox tk(configure scrollregion:q(0 0 1000  Y1 + 5 ))}
      end

      
      meth setColour(key:K bg:_ fg:FG) = M 
	 if {Dictionary.member self.entryDict  K} then 
	    S = self.entryDict.K in
	    {self.listbox tk(itemconfig S.fgtag fill:FG)}
	    self.entryDict.K:={Record.adjoinAt S fg FG}
	 end
      end
   end 
end

