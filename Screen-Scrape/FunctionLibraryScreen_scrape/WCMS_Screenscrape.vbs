'Option Explicit

'Function Content_Validation(TableName)
'
'		   Dim RowCount,CurrentRow
'		   Dim RunTo,RunFrom
'		   Dim StartTime,EndTime,TimeIt
'		   Dim ColNumber 'TableName
'		   Dim dbDeleteRec
'		'''** Getting total no.of URLs		
'		   RowCount=Datatable.GetSheet("TestCase").GetRowCount
'		   RunTo=RowCount
'		  set conn=Createobject("ADODB.Connection")
'          SITConnectionStr = "***REMOVED***"
' 		  conn.open SITConnectionStr ' connecting to db	    
'		  dbDeleteRec = "Truncate table " & TableName
'          conn.execute(dbDeleteRec)		  
'
'		   For RunFrom=1 to RunTo
''				print "Current URLNumber = " & RunFrom & "/ Total URL Count = " &  RunTo
'				Datatable.GetSheet("TestCase").SetCurrentRow(RunFrom)
'				GoToPage=Datatable.Value("Old_DT_URL","TestCase")  'get URL from Excel
'				Browser("micclass:=browser").Navigate(GoToPage)
'				URL=GoToPage
'				If Browser("micclass:=browser", "CreationTime:=1").Dialog("regexpwndtitle:=File Download").WinButton("micclass:=WinButton","text:=Cancel").Exist(0)   then
'					Browser("micclass:=browser").Dialog("micclass:=Dialog").WinButton("micclass:=WinButton","text:=Cancel").Click
'				End If
'				'''get all contentID, SlotID,Slotname from each page and store into DB
'				Call InsertContentID_into_DB(URL,TableName,conn, strSelectFunction)
'					    	    
'		   Next
'		    Call CheckInDB(URL,TableName,RunFrom,conn)  ' getting conent ID  and storing into excel
'	   conn.Close
'      Set conn=Nothing 
'End Function


'Function CheckInDB(URL,TableName,RunFrom,conn)
'	Dim NotExistValue
'	Dim SQLQuery
'	Dim DB_Output
'	Dim i
'	i=1
'	On Error Resume Next
'
'	DataTable.GetSheet("DataSheet").SetCurrentRow RunFrom ' setting the current row in the excel 
'
'	Set RecordSet1 = CreateObject("ADODB.Recordset")
'	Set RecordSet2 = CreateObject("ADODB.Recordset")
'     '==== connecting to db               
'		SQLQuery= "exec comparedata '" & split(TableName,"_",-1,1)(0) & "_ref', '" & split(TableName,"_",-1,1)(0) & "_runtime' "
'        set RecordSet1=conn.execute(SQLQuery) 'executing the query
'		'''''set RecordSet1=conn.execute(SQLQuery) 'executing the query
'	    SQL_GetFailedRec = "select Distinct  URL From " & split(TableName,"_",-1,1)(0) & "_ref where status = 'u'" 
'        set RecordSet2=conn.execute(SQL_GetFailedRec) ''''executing the query
'		While Not RecordSet2.EOF
'			'''msgbox  RecordSet2.Fields(0)
'			DataTable.GetSheet("DataSheet").SetCurrentRow i
'			Datatable.Value("URL","DataSheet")= RecordSet2.Fields(0)
'		    Datatable.Value("Status","DataSheet")= "Doesn't Match with runtime data"
'			i=i+1
'		   RecordSet2.MoveNext
'	
'		Wend 
'
'        RecordSet1.close
'		Set RecordSet1=Nothing
'		RecordSet2.close
'		Set RecordSet2=Nothing
'
'End Function
'======================================================================================
' DescriptiveName:  InsertContentID_into_DB

'======================================================================================


Function InsertContentID_into_DB(strSiteName, URL,TableName,conn, strSelectFunction)
'		On error Resume next
	Dim x,i,j
	 Dim NumOfSlot
	 Dim p_count,strContentName,Contentlen
	 Dim DescSlotName,DescContentItem
	 Dim ChildContentCount
       URL=URL
      
'		DataTable.GetSheet("DataSheet").SetCurrentRow 1
'		NumOfSlot=DataTable.GetSheet("DataSheet").GetRowCount ' getting slot count from testdata colm
		'#########################################################
		Dim arrSlots(300)
		Set DescSlotName = Description.Create()
		DescSlotName("micclass").Value="WebElement"
		DescSlotName("html tag").Value= "DIV" 
		strSiteName = Ucase(strSiteName)
		Select Case strSiteName
			Case "CGOV", "CGOV1","CGOV2"
				DescSlotName("html id").Value= "cgv.*|nvcg.*"
			Case "MOBILE"
				DescSlotName("html id").Value= "cgvMobile.*"
			Case "TCGA"
				DescSlotName("html id").Value= "tcgaSlot.*"
			Case "PROTEOMICS", "CCOP", "IMG", "DCEG"
				DescSlotName("html id").Value= "genSlot.*"
		End Select
		   
		Set SlotItemList = Browser("micclass:=browser").Page("micclass:=Page").ChildObjects(DescSlotName)
		NumOfSlot =  SlotItemList.count
		For i1 = 0 To NumOfSlot-1
			If SlotItemList(i1).GetRoProperty("html id") <> "" Then
				arrSlots(i1) = SlotItemList(i1).GetRoProperty("html id")
			End If
			
		Next
		NumOfSlot = i1-1
		'#########################################################
		
		For x=0 to NumOfSlot-1
        ' get child object for slotname
		SlotName = arrSlots(x)
		IF SlotName = "" then
				 Exit For
		End IF
		Set DescSlotName = Description.Create()
		   DescSlotName("micclass").Value="WebElement"
		   DescSlotName("html tag").Value= "DIV" 
		   DescSlotName("html id").Value=SlotName
		  Set SlotItemList = Browser("micclass:=browser").Page("micclass:=Page").ChildObjects(DescSlotName)
			SlotItemListCount=SlotItemList.Count()
			For i=0 to SlotItemListCount-1
				 ' '''''getting the content id with in the childobject
		         SlotID = SlotItemList(i).GetRoProperty("class")
				 strContentName = SlotItemList(i).GetRoProperty("innertext") ' getting the content name
				 Contentlen=Len(strContentName) 'getting conent name length 
				 set DescContentItem=Description.Create()
					DescContentItem("micclass").Value="WebElement"
					DescContentItem("html tag").Value= "DIV" ' "DIV"
					DescContentItem("class").Value=".*contentid-.*"
					DescContentItem("class").RegularExpression = True 
					Set Content_List=SlotItemList(i).ChildObjects(DescContentItem)
					ChildContentCount=Content_List.Count()
				  p_count=1
				For j=0 to ChildContentCount-1
					ContentID= Content_List(j).GetRoproperty("class") ' getting content id textt
					ContentIDNumval=split (ContentID,"-")(1) ' getting Contentid num
					ContentIDNum = split(ContentIDNumval," ")(0)
					Priority=p_count
					p_count=p_count+1
					' Check Slot ID is NULL
					If SlotID = "" Then
						SlotID="NULL"
					End If
					' Check ContentLen is NULL
					If  ContentLen =""  Then
						ContentLen="NULL"
					End If
					If strSelectFunction = 1 Then
						SQLQuery= "Insert  into "& TableName &" Values('" & URL & "' ,"  &  " '"  & SlotID &   "', "   &  " '"   &  SlotName &  "',"   &   ContentIDNum   &  ","  &  Priority &  ","  &  Contentlen  &   ", '"  & status & " ')"
					Else
						SQLQuery= "Insert  into "& TableName &" Values('" & URL & "' ,"  &  " '"  & SlotID &   "', "   &  " '"   &  SlotName &  "',"   &   ContentIDNum   &  ","  &  Priority &  ","  &  Contentlen  &   ")"
					End If
					
			
					conn.execute(SQLQuery) 'executing the query
				Next					
			Next
		Next
		' Closing all the connection						

End Function

Function InsertLinksAndHrefs_into_DB(strSiteName, URL,TableName,conn, strSelectFunction, CurrentDataRow)
		Dim SQLDictLinks, SQLDictImgs
		Set SQLDictLinks = CreateObject("Scripting.Dictionary")
		Set SQLDictImgs = CreateObject("Scripting.Dictionary")
		Dim oSQLQuery, oLinkName, oLinkHref, oImgName, oImgSrc
		Set oSQLQuery = Dotnetfactory.CreateInstance("System.Text.StringBuilder")
		Set oLinkName = Dotnetfactory.CreateInstance("System.Text.StringBuilder")
		Set oLinkHref = Dotnetfactory.CreateInstance("System.Text.StringBuilder")
		Set oImgName = Dotnetfactory.CreateInstance("System.Text.StringBuilder")
		Set oImgSrc = Dotnetfactory.CreateInstance("System.Text.StringBuilder")
			
		'Capture all image information from the page
		Set oImageDesc = Description.Create()
		oImageDesc("html tag").Value="IMG"
		   
		Set oImgCollection = Browser("micclass:=browser").Page("micclass:=Page").ChildObjects(oImageDesc)
		NumOfImgs =  oImgCollection.count
		
		'Capture all link information from the page
		Set oLinkDesc = Description.Create()
		oLinkDesc("micclass").Value="Link"
		   
		Set oLinkCollection = Browser("micclass:=browser").Page("micclass:=Page").ChildObjects(oLinkDesc)
		NumOfLinks =  oLinkCollection.count
		
		
		URL = "'" & URL & "'"
		For i = 0 To NumOfLinks-1
			If instr(strLinkHref, "www.youtube.com") = 0 Then
				index = 0
				strLinkName = Replace(oLinkCollection(i).GetRoProperty("name"), "'","''")
				strLinkHref = Replace(oLinkCollection(i).GetRoProperty("href"), "'","''")
				
				oLinkName.Appendformat "::({0})", strLinkName
				oLinkHref.Appendformat "::({0}, {1})", strLinkName, strLinkHref
'			Else
'				msgbox "Found youtube!!!!!!"
			End If

		Next
		strLinkName = "'" & cstr(NumOfLinks) & oLinkName.ToString() & "'"
		strLinkHref = "'" & oLinkHref.ToString() & "'"
		status =  "Null" 
'==========================================================================================================================
		'Write all Links and Images to the database
		For i = 0 To NumOfImgs-1
			index = 0
			strImgName = Replace(oImgCollection(i).GetRoProperty("file name"), "'","''")
			strImgSrc = Replace(oImgCollection(i).GetRoProperty("src"), "'","''")
			
			oImgName.Appendformat "::({0})", strImgName
			oImgSrc.Appendformat "::({0}, {1})", strImgName, strImgSrc
		Next
		
		strImgName = "'" & cstr(NumOfImgs) & oImgName.ToString() & "'"
		strImgSrc = "'" & oImgSrc.ToString() & "'"
				
		If strSelectFunction = 1 Then
			oSQLQuery.Appendformat ",({0}, {1},{2},{3},{4},{5})" , URL, strLinkName, strLinkHref, strImgName, strImgSrc, status
		Else
			oSQLQuery.Appendformat ",({0}, {1},{2},{3},{4})" , URL, strLinkName, strLinkHref, strImgName, strImgSrc
		End If
		SqlQuerryString = oSQLQuery.ToString()
		If NumOfImgs>0 Or NumOfLinks>0 Then
			CallSQLQuery SqlQuerryString, TableName, strSelectFunction, conn
		End If
		
		oSQLQuery.Clear
		oLinkName.Clear
		oLinkHref.Clear
		oImgName.Clear
		oImgSrc.Clear
		SqlQuerryString = ""
		strLinkName = ""
		strLinkHref = ""
		strImgName = ""
		strImgSrc = ""
'==========================================================================================================================	
		
End Function



'##########################################################################################################
Function CallSQLQuery (SQLQuery, TableName, strSelectFunction, conn)

	SQLQuery = Right(SQLQuery, Len(SQLQuery) - 1) 'Remove the first comma
	If strSelectFunction = 1 Then
		SQLQueryFinal = "Insert  into " &TableName & "(URL, LinkName, LinkHref, ImgName, ImgSrc, status)" & " Values" & SQLQuery
	Else
		SQLQueryFinal = "Insert  into " &TableName & "(URL, LinkName, LinkHref, ImgName, ImgSrc)" & " Values" & SQLQuery
	End If	
		conn.execute(SQLQueryFinal) 'executing the query
		SQLQueryFinal = "" 'Initialize
		SQLQuery = ""
End Function
