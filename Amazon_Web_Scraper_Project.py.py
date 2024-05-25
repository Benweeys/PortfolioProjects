#!/usr/bin/env python
# coding: utf-8

# In[148]:


#import libraries

from bs4 import BeautifulSoup
import requests
import time
import datetime
import smtplib
import csv
import datetime
import pandas as pd


# In[150]:


# Connect to Website

URL = 'https://www.amazon.sg/Python-Nutshell-Desktop-Quick-Reference/dp/1098113551/'

headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0", "Accept-Encoding":"gzip, deflate", "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "DNT":"1","Connection":"close", "Upgrade-Insecure-Requests":"1"}

page = requests.get(URL, headers = headers)

soup1 = BeautifulSoup(page.content, "html.parser")

soup2 = BeautifulSoup(soup1.prettify(), "html.parser")

title = soup2.find(id='productTitle').get_text()
price = soup2.find('span', class_='a-price-whole').get_text()


# In[151]:


price = price.replace(".","").strip()
title = title.strip()
today = datetime.date.today()

print(title)
print(price)
print(today)

header = ['Date','Title','Price']
data = [today,title,price]

with open('AmazonWebScraperData.csv','w', newline = '', encoding='UTF8') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerow(data)


# In[152]:


df = pd.read_csv(r'C:\Users\Benja\Desktop\Projects\Data Analyst Bootcamp\Untitled Folder\AmazonWebScraperData.csv')

with open('AmazonWebScraperData.csv','a+', newline = '', encoding='UTF8') as f:
    writer = csv.writer(f)
    writer.writerow(data)

print(df)


# In[153]:


def send_mail():
 from email.message import EmailMessage
 import ssl
 import smtplib


 email_sender = 'benwee95@gmail.com'
 email_receiver = 'benwee95@gmail.com'
 email_password = 'obeg eiic qkad dnfe '

 subject = "The book you want is below $90! Now is your chance to buy!"
 body = "Go ahead and buy the book!"

 em = EmailMessage()
 em['From'] = email_sender
 em['To'] = email_receiver
 em['Subject'] = subject
 em.set_content(body)

 context = ssl.create_default_context()


# In[154]:


def check_price():
    URL = 'https://www.amazon.sg/Python-Nutshell-Desktop-Quick-Reference/dp/1098113551/'
    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0", "Accept-Encoding":"gzip, deflate", "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "DNT":"1","Connection":"close", "Upgrade-Insecure-Requests":"1"}
    page = requests.get(URL, headers = headers)
    soup1 = BeautifulSoup(page.content, "html.parser")
    soup2 = BeautifulSoup(soup1.prettify(), "html.parser")
    title = soup2.find(id='productTitle').get_text()
    price = soup2.find('span', class_='a-price-whole').get_text()
    
    import datetime
    today = datetime.date.today()
    
    import csv
    
    header = ['Date','Title','Price']
    data = [today,title,price]
    
    if len(title) != 0 and len(price) !=0:
        with open('AmazonWebScraperData.csv','a+', newline = '', encoding='UTF8') as f:
            writer = csv.writer(f)
            writer.writerow(data)
            
    if price < 90:
        send_mail()


# In[156]:


while(True):
    try:
        check_price()
    except:
        print("error encountered")
        
    time.sleep(5)
    
    


# In[ ]:


df = pd.read_csv(r'C:\Users\Benja\Desktop\Projects\Data Analyst Bootcamp\Untitled Folder\AmazonWebScraperData.csv')
print(df)


# 
# 

# In[146]:


from email.message import EmailMessage
import ssl
import smtplib


email_sender = 'benwee95@gmail.com'
email_receiver = 'benwee95@gmail.com'
email_password = 'obeg eiic qkad dnfe '

subject = "The book you want is below $90! Now is your chance to buy!"
body = "Go ahead and buy the book!"

em = EmailMessage()
em['From'] = email_sender
em['To'] = email_receiver
em['Subject'] = subject
em.set_content(body)

context = ssl.create_default_context()


# In[ ]:





# In[ ]:




