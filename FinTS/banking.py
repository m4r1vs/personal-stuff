import logging
import pprint
import getpass
import encrypter
import json
from datetime import date, timedelta
from fints.client import FinTS3PinTanClient

print('Getting transactions...')

pp = pprint.PrettyPrinter(indent=4)
logging.basicConfig(level=logging.DEBUG)

password = getpass.getpass("Your password: ")

client = FinTS3PinTanClient(
    '20050550', # Bank BLZ
    encrypter.decrypt("banking_login", password).decode(),
    encrypter.decrypt("banking_pin", password).decode(),
    'https://banking.haspa.de/OnlineBankingFinTS/pintan' # endpoint
)

accounts = client.get_sepa_accounts()
statement = client.get_statement(accounts[0], date.today() - timedelta(90), date.today())
balance = client.get_balance(accounts[0])

print('\n\nGot transactions from SEPA Account:', accounts)
print('h')

for transaction in statement:
    print('\n\n=============================')
    print('Transaction date:', transaction.data.get('date', 'Not given').strftime('%m/%d/%Y'))
    print('Applicant:', transaction.data.get('applicant_name', 'Not given'))
    print('Purpose:', transaction.data.get('purpose', 'Not given'))
    print('Amount:', transaction.data.get('amount', 'Not given').amount, transaction.data['amount'].currency)
    print('=============================')

print('\n\nAnd the balance is', balance.amount.amount, balance.amount.currency)

input("\n\nPress enter to exit..")
