import pandas as pd
from sqlalchemy import create_engine

conn_string='mysql+pymysql://root:************@localhost:3306/music'  #to connect mysql database to python
db=create_engine(conn_string)
conn=db.connect()


#print(df.info)
files=['artist','canvas_size','image_link','museum','museum_hours','product_size','subject','work']
for file in files:
   df=pd.read_csv(f'path of files/{file}.csv')
   df.to_sql(file,con=conn, if_exists='replace',index=False)
