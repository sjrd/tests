%%%  Programming Systems Lab, DFKI Saarbruecken,
%%%  Stuhlsatzenhausweg 3, D-66123 Saarbruecken, Phone (+49) 681 302-5312
%%%  Author: Christian Schulte
%%%  Email: schulte@dfki.uni-sb.de
%%%  Last modified: $Date$ by $Author$
%%%  Version: $Revision$

local

   class AboutDialog 
      from TkTools.dialog

      meth init(master:Master)
	 <<TkTools.dialog tkInit(master:  Master
				 title:   TitleName#': About'
				 buttons: ['Okay'#close]
				 focus:   1
				 pack:    False
				 default: 1)>>
	 Title = {New Tk.label tkInit(parent:     self
				      font:       AboutFont
				      text:       TitleName
				      foreground: ChooseTermColor)}

	 Author = {New Tk.label tkInit(parent: self
				       text: ('Christian Schulte\n' #
					      '(schulte@dfki.uni-sb.de)\n'))}
      in
	 {Tk.send pack(Title Author side:top expand:1 padx:BigPad pady:BigPad)}
	 <<AboutDialog pack>>
      end

   end


   class PostscriptDialog
      from TkTools.dialog
      
      meth init(master:M options:O)

	 proc {Okay}
	    SizeString={SizeEntry tkReturn(get $)}
	 in
	    case {Misc.check SizeString} of !False then true
	    elseof Size then
	       {Dictionary.put O size        SizeString}
	       {Dictionary.put O width       Size.width}
	       {Dictionary.put O height      Size.height}
	       {Dictionary.put O color       {ColorVar  tkReturnAtom($)}}
	       {Dictionary.put O orientation {OrientVar tkReturnAtom($)}}
	       {self close}
	    end
	 end

	 <<TkTools.dialog tkInit(master:  M
				 title:   TitleName#': Postscript'
				 buttons: ['Okay'#Okay 'Cancel'#close]
				 pack:    False
				 default: 1)>>
	 Color     = {New TkTools.textframe tkInit(parent: self
						   text:   'Color Mode')}
	 ColorVar  = {New Tk.variable tkInit({Dictionary.get O color})}

	 Orient    = {New TkTools.textframe tkInit(parent: self
						   text:   'Orientation')}
	 OrientVar = {New Tk.variable tkInit({Dictionary.get O orientation})}
	 
	 Size      = {New TkTools.textframe tkInit(parent: self
						   text:   'Size')}
	 SizeEntry = {New Tk.entry tkInit(parent: Size.inner
					  back:   EntryColor
					  width:  LargeEntryWidth)}
      in
	 {SizeEntry tk(insert 0 {Dictionary.get O size})}
	 {Tk.batch [pack({New Tk.radiobutton tkInit(parent:   Color.inner
						    value:    color
						    variable: ColorVar
						    text:     'Full color')}
			 {New Tk.radiobutton tkInit(parent:   Color.inner
						    value:    grey
						    variable: ColorVar
						    text:     'Grayscale')}
			 {New Tk.radiobutton tkInit(parent:   Color.inner
						    value:    mono
						    variable: ColorVar
						    text:     'Black & white')}
			 side:left pady:Pad)
		    pack({New Tk.radiobutton tkInit(parent:   Orient.inner
						    value:    False
						    variable: OrientVar
						    text:     'Portrait')}
			 {New Tk.radiobutton tkInit(parent:   Orient.inner
						    value:    True
						    variable: OrientVar
						    text:     'Landscape')}
			 side:left pady:Pad)
		    pack({New Tk.label tkInit(parent: Size.inner
					      text:   'Maximal size:')}
			 SizeEntry side:left pady:Pad)
		    pack(Color Orient Size side:top fill:x)
		    focus(SizeEntry)]}
	 <<PostscriptDialog pack>>
      end

   end


   class DrawingDialog
      from TkTools.dialog

      meth init(master:M options:O)

	 proc {Okay}
	    case {Tk.string.toInt {Filter {Update tkReturn(get $)}
				   Char.isDigit}}
	    of !False then true
	    elseof I then
	       {Dictionary.put O hide   {IsHide tkReturnInt($)}==1}
	       {Dictionary.put O scale  {IsScale tkReturnInt($)}==1}
	       {Dictionary.put O update I}
	       {self close}
	    end
	 end
	 
	 <<TkTools.dialog tkInit(master:  M
				 title:   TitleName#': Drawing'
				 default: 1
				 pack:    False
				 buttons: ['Okay'#Okay 'Cancel'#close])>>

	 Drawing  = {New TkTools.textframe tkInit(parent:self
						  text:  'Drawing')}
	 IsHide   = {New Tk.variable tkInit({Dictionary.get O hide})}
	 IsScale  = {New Tk.variable tkInit({Dictionary.get O scale})}

	 Update   = {New Tk.entry tkInit(parent: Drawing.inner
					 bg:     EntryColor
					 width:  SmallEntryWidth)}
      in
	 {Update tk(insert 0 {Dictionary.get O update})}
	 {Tk.batch [grid({New Tk.checkbutton
			  tkInit(parent:   Drawing.inner
				 anchor:   w
				 variable: IsHide
				 text:     'Hide failed subtrees')}
			 row:0 column:0 columnspan:3 sticky:ew)
		    grid({New Tk.checkbutton
			  tkInit(parent:   Drawing.inner
				 anchor:   w
				 variable: IsScale
				 text:     'Scale to fit')}
			 row:1 column:0 columnspan:3 sticky:ew)
		    grid({New Tk.label tkInit(parent: Drawing.inner
					      anchor: w
					      text:  'Update every ')}
			 row:3 column:0)
		    grid(Update row:3 column:1)
		    grid({New Tk.label tkInit(parent: Drawing.inner
					      anchor: w
					      text:  ' solutions')}
			 row:3 column:2) 
		    pack(Drawing)
		    focus(Update)]}
	 <<DrawingDialog pack>>
      end
      
   end

   
   local

      fun {DistS2I S}
	 case {Map {Filter S Char.isGraph} Char.toLower}
	 of "none" then 1
	 [] "full" then 0
	 elseof S then {Tk.string.toInt S}
	 end
      end
      
      fun {DistI2VS I}
	 case I<1 then full
	 elsecase I==1 then none
	 else I
	 end
      end
      
   in

      class SearchDialog
	 from TkTools.dialog

	 meth init(master:M options:O)

	    proc {Okay}
	       SD={DistS2I {Search tkReturn(get $)}}
	       ID={DistS2I {Info   tkReturn(get $)}}
	    in
	       case {IsInt SD} andthen {IsInt ID} then
		  {Dictionary.put O search      SD}
		  {Dictionary.put O information ID}
		  {Dictionary.put O order    {OrderVar tkReturnInt($)}==1}
		  {self close}
	       else true
	       end
	    end

	    <<TkTools.dialog tkInit(master:  M
				    title:   TitleName#': Search Options'
				    default: 1
				    pack:    False
				    buttons: ['Okay'#Okay 'Cancel'#close])>>
	    Recomp = {New TkTools.textframe tkInit(parent: self
						   text:   'Recomputation')}
	    Left   = {New Tk.frame tkInit(parent:Recomp.inner)}
	    Search = {New Tk.entry tkInit(parent:Left
					  back:  EntryColor
					  width: SmallEntryWidth)}
	    Info   = {New Tk.entry tkInit(parent:Left
					  back:  EntryColor
					  width: SmallEntryWidth)}
	    Right  = {New Tk.frame tkInit(parent:Recomp.inner)}
	    
	    proc {Enter S#I}
	       {Search tk(delete 0 'end')} {Search tk(insert 0 S)}
	       {Info   tk(delete 0 'end')} {Info   tk(insert 0 I)}
	    end

	    Order  = {New TkTools.textframe
		      tkInit(parent: self text:'Exploration Order')}
	    Only     = {New Tk.frame tkInit(parent:Order.inner)}
	    OrderVar = {New Tk.variable tkInit({Dictionary.get O order})}
	    Fixed    = {New Tk.checkbutton tkInit(parent:   Only
						  text:     'Fixed to left-to-right'
						  anchor:   w
						  variable: OrderVar)}
	 in
	    {Enter ({DistI2VS {Dictionary.get O search}} #
		    {DistI2VS {Dictionary.get O information}})}

	    {Tk.batch [grid({New Tk.label tkInit(parent:Left
						 text:  'Search:'
						 anchor:w)}
			    row:0 column:0 sticky:we)
		       grid(Search row:0 column:1 sticky:we)
		       grid({New Tk.label tkInit(parent:Left
						 text:  'Information:'
						 anchor:w)}
			    row:1 column:0 sticky:we)
		       grid(Info row:1 column:1 sticky:we)

		       pack({New Tk.button tkInit(parent: Right
						  text:   'Normal'
						  action: Enter # (none # 5))}
			    {New Tk.button tkInit(parent: Right
						  text:   'Large'
						  action: Enter # (5 # 25))}
			    {New Tk.button tkInit(parent: Right
						  text:   'Huge'
						  action: Enter # (25 # full))}
			    fill:x)

		       pack(Left side:left anchor:n)
		       pack({New Tk.frame tkInit(parent:Recomp.inner)}
			    side:left ipadx:1#c)
		       pack(Right side:right anchor:n)

		       pack(Fixed fill:x)
		       pack(Only  side:left anchor:n)

		       pack(Recomp Order side:top fill:x)]}
	    <<SearchDialog pack>>
	 end

      end

   end

in

   class DialogManager
      feat fileSelector options

      meth init
	 self.fileSelector =
	 {New TkTools.file init(master: self.toplevel
				title:  TitleName#': Select Postscript File')}
	 self.options =
	 {Record.map Options fun {$ O}
				D = {Dictionary.new}
			     in
				{Record.forAllInd O proc {$ F V}
						       {Dictionary.put D F V}
						    end}
				D
			     end}
      end

      meth guiOptions(What)
	 {Wait {New case What
		    of postscript then PostscriptDialog
		    [] search     then SearchDialog
		    [] drawing    then DrawingDialog
		    end
		    init(master:  self.toplevel
			 options: self.options.What)}.closed}
      end

      meth postscript
	 case {self.fileSelector select(file:$)} of !False then true
	 elseof Filename then O=self.options.postscript in
	    {self.canvas postscript(colormode: {Dictionary.get O color}
				    rotate:    {Dictionary.get O orientation}
				    file:      Filename
				    height:    {Dictionary.get O height}
				    width:     {Dictionary.get O width})}
	 end
	 touch
      end

      meth about
	 {Wait {New AboutDialog init(master:self.toplevel)}.closed}
	 touch
      end

      meth error(M)
	 {Wait {New TkTools.error
		tkInit(master:  self.toplevel
		       text:    M
		       title:   TitleName#': Error Message')}.closed}
	 touch
      end

      meth close
	 {self.fileSelector close}
      end
      
   end
end







