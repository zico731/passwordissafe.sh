import requests
import hashlib

password = input("Entrez un mot de passe ? ")

sha_password = hashlib.sha1(password.encode()).hexdigest()
sha_prefix = sha_password[0:5]
sha_postfix = sha_password[5:].upper()

url = "https://api.pwnedpasswords.com/range/"+ sha_prefix

payload = {}
headers = {}

response = requests.request("GET", url, headers=headers, data=payload)
pwnd_dict = {}
#print(response.text)
pwnd_list = response.text.split("\r\n")
for pwnd_pass in pwnd_list:
	pwnd_hash = pwnd_pass.split(":")
	pwnd_dict[pwnd_hash[0]] = pwnd_hash[1]
	
if sha_postfix in pwnd_dict.keys():
	print("Le mot de passe a été compromis {0} fois".format( \
        pwnd_dict[sha_postfix]))
else:
	print("Le mot de paase sûr")