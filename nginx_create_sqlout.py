from mysql import connector
import pandas as pd
import argparse


#https://dev.mysql.com/doc/connector-python/en/connector-python-example-connecting.html
mydb =  connector.connect(
  #host="localhost",
  #host="host.docker.internal",
  host = args.get("dbhost"), #"172.19.244.87",
  #host = "172.19.244.87",
  #user="root",
  user=args.get("mysqluser"),
  #user="report",
  password="report",
 #password="YjdkZjhjMjJmMDVkZDBjZTkzOGIyM2Y0",
  database=args.get("database","DB")
)

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


# Next to remove! html in favor of pandas
html_table_template = """<table>
{}
</table>"""
row_template = "<tr><td>{}</td><td>{}</td><td>{}</td></tr>"

col_names = "ID", "Name", "Email"
html_rows = [row_template.format(*col_names)]
for record in myresult:
    html_rows.append(row_template.format(*record))

html_table = html_table_template.format('\n  '.join(html_rows))

print(html_table)
