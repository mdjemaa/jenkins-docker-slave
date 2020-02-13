
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


$JENKINS_URL="https://jenkins.intra"
$JENKINS_USER="admin"
$JENKINS_API_TOKEN="admin123"
$NODE_NAME="testnode-ps"

# https://stackoverflow.com/questions/27951561/use-invoke-webrequest-with-a-username-and-password-for-basic-authentication-on-t
$bytes = [System.Text.Encoding]::ASCII.GetBytes("${JENKINS_USER}:${JENKINS_API_TOKEN}")
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
$headers = @{ Authorization = $basicAuthValue;  }

$jnlpLocal="C:\jenkins_home\slave-agent.jnlp"
Invoke-WebRequest -Headers $headers -Method Get -Uri "http://localhost:8080/computer/windows01/slave-agent.jnlp" -OutFile $jnlpLocal

[xml]$jnlpFile = Get-Content $jnlpLocal
$secret = Select-Xml "//jnlp/application-desc/argument[1]/text()" $jnlpFile

Write-Output "secret content $secret" 

