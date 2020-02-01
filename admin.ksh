
from lxml import etree

tree = etree.parse("thefile.xml")
my_list = []
for user in tree.xpath("/map/entry[string='global']/list/string"):
    my_list.append(user.text)
print (my_list)

import hudson.model.*
import jenkins.model.*
import jenkins.security.*
import jenkins.security.apitoken.*
import jenkins.model.*
import hudson.security.*
  
  println "--> creating admin user"

def adminUsername = "admin9"
def adminPassword = "admin9"
assert adminPassword != null : "No ADMIN_USERNAME env var provided, but required"
assert adminPassword != null : "No ADMIN_PASSWORD env var provided, but required"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(adminUsername, adminPassword)
Jenkins.instance.setSecurityRealm(hudsonRealm)
Jenkins.instance.save()
def tokenName = 'kb-token'
  
def user = User.get(adminUsername, false)
def apiTokenProperty = user.getProperty(ApiTokenProperty.class)
def result = apiTokenProperty.tokenStore.generateNewToken(tokenName)
user.save()

return result.plainValue

