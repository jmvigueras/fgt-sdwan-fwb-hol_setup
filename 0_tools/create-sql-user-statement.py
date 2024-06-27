####################################################################
# Script to generete sql statement with students data
#
# jvigueras@fortinet.com
####################################################################
import json
import ipaddress

#------------------------------------------------------------------------------
# VARIABLES
#------------------------------------------------------------------------------
FORTICLOUD_ACCOUNT_ID = "111111"  #(update with you Fortinet account ID)
FORTICLOUD_USERS_PWD  = "xxxxx"  #(update with password assigned to FortiCloudUsers)

#------------------------------------------------------------------------------
# READ FILES WITH USERS, EMAILS AND TERRAFORM STATES  
#------------------------------------------------------------------------------
# Users email
users_email_file = open('./users_email.txt.example')
users_email = users_email_file.readlines()
# Users forticloud id
users_forticloud_file = open('./users_forticloud.txt.example')
users_forticloud = users_forticloud_file.readlines()
# Terraform tfstate from deployments
fgts_tfstate  = open('../1_deploy_fortigates/terraform.tfstate')
srvs_tfstate = open('../2_deploy_servers/terraform.tfstate')
# Returns JSON object as a dictionary
users_fgt = json.load(fgts_tfstate)['outputs']['users_fgt']

#------------------------------------------------------------------------------
# CODE
#------------------------------------------------------------------------------
i = 0
sql = "USE students;\n"

# Generated INSERT sql statement per user in email list
for key in users_fgt['value'].keys():
  sql += "INSERT INTO students (`email`,`aws_user_id`,`accountid`,`forticloud_user`,`forticloud_password`,`fgt_ip`,`fgt_user`,`fgt_password`,`fgt_api_key`,`server_ip`) VALUES ("
  sql += "'"+users_email[i].strip()+"', "
  sql += "'"+key+"', "
  sql += "'"+FORTICLOUD_ACCOUNT_ID+"', "
  sql += "'"+users_forticloud[i].strip()+"', "
  sql += "'"+FORTICLOUD_USERS_PWD+"', "
  sql += "'"+users_fgt['value'][key]['fgt_public']+"', "
  sql += "'"+users_fgt['value'][key]['username']+"', "
  sql += "'"+users_fgt['value'][key]['password']+"', "
  sql += "'"+users_fgt['value'][key]['fgt_api_key']+"', "
  sql += "'"+users_fgt['value'][key]['fgt_public']+"'" 
  sql += ");\n"
  i+=1

ip = ""
# Generated list of user servers public ip
for key in users_fgt['value'].keys():
  ip += users_fgt['value'][key]['fgt_public']+"\n" 

app_list = open('./app_public_ips.txt','w')
app_list.writelines(ip)
app_list.close()

print("Generate app server list: app_public_ips.txt")

# Closing file
fgts_tfstate.close()
srvs_tfstate.close()
users_email_file.close()

insert_sql = open('./sql_insert_users.sql','w')
insert_sql.writelines(sql)
insert_sql.close()

print("Generate SQL query: sql_insert_users.sql")