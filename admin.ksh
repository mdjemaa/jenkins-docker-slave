
from lxml import etree

tree = etree.parse("thefile.xml")
my_list = []
for user in tree.xpath("/map/entry[string='global']/list/string"):
    my_list.append(user.text)
print (my_list)

