rm /tmp/Report.html;sed -e 's/$/<br>/' -i /tmp/AppzillonTest.html;echo '</p></body></html>' >> /tmp/AppzillonTest.html;echo '<html><head><title>Appzillon Test Logs</title></head><body><h1 style="background-color:Yellow;" align="center" ><font color="SlateBlue">Appzillon Testcase Log</font></h1> <p style="background-color:LightGreen;"><button type="button" onclick="window.location.href='/tmp/test.html'" style="float: right;">Report</button>' | cat - /tmp/AppzillonTest.html > temp && mv temp /tmp/AppzillonTest.html;
cat /tmp/AppzillonTest.html  |sed -n '/Results for Microapp:DataBinding/,/Results for Microapp:DataBinding<br>/p' >input.csv;while read INPUT ; do echo "<tr><td>${INPUT//;/</td><td>}</td></tr>" ; done < input.csv >/tmp/Report.html;
cat /tmp/AppzillonTest.html  |sed -n '/Results for Microapp:Designer<br>/,/Results for Microapp:Designer<br>/p' >input.csv;while read INPUT ; do echo "<tr><td>${INPUT//;/</td><td>}</td></tr>" ; done < input.csv >>/tmp/Report.html;
cat /tmp/AppzillonTest.html  |sed -n '/Results for Microapp:Infra<br>/,/Results for Microapp:Infra<br>/p' >input.csv;while read INPUT ; do echo "<tr><td>${INPUT//;/</td><td>}</td></tr>" ; done < input.csv >>/tmp/Report.html;
echo '<html><head><style>table, th, td {border: 1px solid black;border-collapse: collapse;}th, td {    padding: 1px;    text-align: left;    color:white;}table#t01 {    background-color: #3b3a30;}tr:nth-child(even) {background-color: #686256;}</style><body style="background-color:powderblue;"><h2 style="color:#4c4949;" align="center" ><img src="./i-exceed-logo.png" alt="logo" height="42" width="84"/>Appzillon Testcase Results</h2><br><table id="t01" align="center">' | cat - /tmp/Report.html > temp && mv temp /tmp/Report.html;echo "</table></body></head><footer><p align="center"><br>Posted by: Appzillon IDE Team <br>Contact information: <a href="mailto:appzillondevops@i-exceed.com">appzillondevops@i-exceed.com</a>.</p></footer></html>" >> /tmp/Report.html;sed -i 's/\[com.iexceed.utc.Appzillon.main()] INFO//g' /tmp/Report.html;sed -i 's/TestReport/\<button type="button" onclick="window.location.href='192.168.1.6'" style="float\: center\;"\>logs\<\/button\>/g' /tmp/Report.html;p='<tr><td>FunctionId</td><td>Description</td><td>TestCaseNo</td><td>SubCaseNo</td><td>Result<br></td></tr>';q="<tr><td bgcolor='\#FFA500'>FunctionId</td><td bgcolor='\#FFA500'>Description</td><td bgcolor='\#FFA500'>TestCaseNo</td><td bgcolor='\#FFA500'>SubCaseNo</td><td bgcolor='\#FFA500'>Result<br></td></tr>";sed -i "s#$p#$q#g" /tmp/Report.html

