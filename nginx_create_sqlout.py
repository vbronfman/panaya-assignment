from mysql import connector
import pandas as pd
import argparse


htmlfile = "nginx_static.html"

#https://dev.mysql.com/doc/connector-python/en/connector-python-example-connecting.html
mydb =  connector.connect(
  host="localhost",
  user="report",
  password="report",
  database="DB")

mycursor = mydb.cursor()

mycursor.execute(
   '''
select 
      c.Id              as Company_id
,     c.Name            as Company_Name
,     a.Id              as Account_id
,     a.Name            as Account_Name
,     p.Id              as Project_Id
,     p.Name            as Project_Name
,     case  p.Status
        when 0 then 'Inactive'
        when 1 then 'Active'
        when 2 then 'Frozen'
        else        'UNKNOWN'
      end
                        as Project_Status
from  As_company        as c

join  As_account        as a
      on  a.Company_id  = c.Id
      
join  As_project        as p
      on  p.Account_id  = a.Id

''' 
)

myresult = mycursor.fetchall()

for x in myresult:
  print (f"DEBUG {x}")

# https://stackoverflow.com/questions/63487038/formatting-html-pandas-tables-in-python
df = pd.DataFrame(myresult,columns='Company_ID Company_Name Account_ID Account_Name Project_ID Project_Name Project_Status'.split())
 
html = """
    {table1}
    
    """.format( table1=df.to_html(index=False),
        )
with open(htmlfile, 'w') as _file:
    _file.write(html)
