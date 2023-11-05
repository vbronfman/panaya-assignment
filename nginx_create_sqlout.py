from mysql import connector
import pandas as pd
import argparse

#Process input if any

# Construct the argument parser
ap = argparse.ArgumentParser()

# Add the arguments to the parser
ap.add_argument("-u", "--mysqluser", default="report",
   help="MySQL read user")
ap.add_argument("-p", "--mysqluserpass", default="report",
   help="MySQL read user password")
ap.add_argument("-b", "--database", default="DB",
   help="MySQL databast name")
ap.add_argument("-d", "--dbhost", default="localhost",
   help="DB host. Try either localhost or host.docker.internal")
ap.add_argument("-o", "--out", default="nginx_static.html",
   help="Static output from database")

args = vars(ap.parse_args())

htmlfile = args.get("out","nginx_static.html")

#https://dev.mysql.com/doc/connector-python/en/connector-python-example-connecting.html
mydb =  connector.connect(
  #host="localhost",
  host = args.get("dbhost"), #"172.19.244.87",
  user=args.get("mysqluser"),
  #user="report",
  password=args.get("mysqluser"),
  database=args.get("database","DB")
)

mycursor = mydb.cursor()
# https://dataschool.com/how-to-teach-people-sql/sql-join-types-explained-visually/ 
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

# https://stackoverflow.com/questions/63487038/formatting-html-pandas-tables-in-python
df = pd.DataFrame(myresult,columns='Company_ID Company_Name Account_ID Account_Name Project_ID Project_Name Project_Status'.split())
 
html = """
    {table1}
    
    """.format( table1=df.to_html(index=False),
        )
with open(htmlfile, 'w') as _file:
    _file.write(html)
