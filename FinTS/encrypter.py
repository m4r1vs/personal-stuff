import os
import base64
import getpass
from cryptography.fernet import Fernet
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import json

# Get (or generate if first time) salt and then add together with password to get key
def password_to_key(password):

	if os.path.isfile("DO_NOT_DELETE_ME.bin"):

		# open binary file containing salt
		raw = open("DO_NOT_DELETE_ME.bin", "rb")
		salt = raw.read()

		# generate key
		kdf = PBKDF2HMAC(
			algorithm=hashes.SHA256(),
			length=32,
			salt=salt,
			iterations=100000,
			backend=default_backend()
		)
		key = base64.urlsafe_b64encode(kdf.derive(password))

		return key

	# no salt:
	else:

		# generate salt
		salt = os.urandom(16)

		# write salt to binary file
		f = open("DO_NOT_DELETE_ME.bin", "wb")
		f.write(salt)
		f.close()

		# notify
		print("Generated salt for your encryption:")
		print(salt)

		# return salt
		return password_to_key(password)

# decrypt json content with password
def decrypt(entry, password):

	password = password.encode()

	# init crypto
	crypter = Fernet(password_to_key(password))

	# open json
	with open("credentials.json") as raw:
		credentials = json.load(raw)
	
	# get data
	data = credentials[entry]

	# decrypt string with password
	string = crypter.decrypt(data.encode())

	return string

# dialogue to encrypt data in credentials.json file
def encrypt():

	password = getpass.getpass("(Choose) Your password: ").encode()

	# init crypto
	crypter = Fernet(password_to_key(password))

	# encrypt input
	token = crypter.encrypt(input("Your data: ").encode())

	# open json
	with open("credentials.json") as raw:
		credentials = json.load(raw)

	# replace or add new content to chosen entry
	credentials[str(input("data entry: "))] = token.decode()

	# open json again, but with write permissions
	f = open("credentials.json", "w")

	# write newly encrypted data
	f.write(json.dumps(credentials))

if __name__ == "__main__":
	encrypt()